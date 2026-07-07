#!/usr/bin/env python3
"""Generate JSON payload for the VMS network page.

Usage:
    python3 build_app/python/generate_vmsnetwork_json.py \
        --person-index data/indices/listperson.xml \
        --place-index data/indices/listplace.xml \
        --work-index data/indices/listbibl.xml \
        --traktat-editions-dir data/traktat/editions \
        --out html/data/vms-network-data.json
"""

from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path
import re
import xml.etree.ElementTree as ET

NS = {"tei": "http://www.tei-c.org/ns/1.0"}
XML_ID = "{http://www.w3.org/XML/1998/namespace}id"


def text_content(node: ET.Element | None) -> str:
    if node is None:
        return ""
    return " ".join("".join(node.itertext()).split())


def first(node: ET.Element, *xpaths: str) -> ET.Element | None:
    for xpath in xpaths:
        candidate = node.find(xpath, NS)
        if candidate is not None:
            return candidate
    return None


def write_json(out_path: Path, payload: dict) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def parse_edition_label(root: ET.Element) -> str:
    edition_node = root.find(".//tei:sourceDesc//tei:edition", NS)
    if edition_node is None:
        return ""

    label = text_content(edition_node)
    if label:
        return label
    return (edition_node.get("n") or "").strip()


def is_year_like(value: str) -> bool:
    value = value.strip()
    return len(value) >= 4 and value[:4].isdigit()


def parse_publication_year(root: ET.Element) -> str:
    date_node = root.find(".//tei:sourceDesc//tei:imprint/tei:date", NS)
    if date_node is None:
        return ""

    when = (date_node.get("when") or "").strip()
    if is_year_like(when):
        return when[:4]

    value = text_content(date_node)
    if is_year_like(value):
        return value[:4]

    return ""


def parse_source_edition_number(root: ET.Element) -> str:
    edition_node = root.find(".//tei:sourceDesc//tei:edition", NS)
    if edition_node is None:
        return ""

    number = (edition_node.get("n") or "").strip()
    if number:
        return number

    label = text_content(edition_node)
    match = re.search(r"(\d+)", label)
    if not match:
        return ""
    return match.group(1)


def chapter_bucket(div: ET.Element) -> str | None:
    heading = text_content(div.find("tei:head", NS))
    if not heading:
        return None

    if heading.casefold().startswith("vorwort"):
        return "Vorwort"

    match = re.match(r"^([IVXLCDM]+)\b", heading, re.IGNORECASE)
    if not match:
        return None

    return match.group(1).upper()


def entity_label(kind: str, node: ET.Element) -> str:
    if kind == "person":
        return text_content(first(node, "tei:persName[@type='main']", "tei:persName"))
    if kind == "place":
        return text_content(
            first(
                node,
                "tei:settlement/tei:placeName[@type='main']",
                "tei:placeName[@type='main']",
                "tei:settlement/tei:placeName",
                "tei:placeName",
            )
        )
    return text_content(first(node, "tei:title[@type='main']", "tei:title"))


def include_person(node: ET.Element) -> bool:
    role = (node.get("role") or "").strip().lower()
    is_character = node.find("tei:listBibl[@type='characterOf']", NS) is not None
    return role != "fictional" and not is_character


def build_catalog(person_root: ET.Element, place_root: ET.Element, work_root: ET.Element) -> dict[str, dict[str, str]]:
    catalog: dict[str, dict[str, str]] = {}

    for node in person_root.findall(".//tei:listPerson/tei:person", NS):
        entity_id = (node.get(XML_ID) or "").strip()
        if not entity_id or not include_person(node):
            continue
        label = entity_label("person", node)
        if not label:
            continue
        catalog[entity_id] = {
            "kind": "person",
            "label": label,
            "url": f"{entity_id}.html",
        }

    for node in work_root.findall(".//tei:listBibl/tei:bibl", NS):
        entity_id = (node.get(XML_ID) or "").strip()
        if not entity_id:
            continue
        label = entity_label("work", node)
        if not label:
            continue
        catalog[entity_id] = {
            "kind": "work",
            "label": label,
            "url": f"{entity_id}.html",
        }

    for node in place_root.findall(".//tei:listPlace/tei:place", NS):
        entity_id = (node.get(XML_ID) or "").strip()
        if not entity_id:
            continue
        label = entity_label("place", node)
        if not label:
            continue
        catalog[entity_id] = {
            "kind": "place",
            "label": label,
            "url": f"{entity_id}.html",
        }

    return catalog


def extract_entities(context_node: ET.Element, catalog: dict[str, dict[str, str]]) -> set[str]:
    entities: set[str] = set()
    for rs in context_node.findall(".//tei:rs", NS):
        rs_type = (rs.get("type") or "").strip()
        if rs_type not in {"person", "bibl", "place"}:
            continue

        ref = (rs.get("ref") or "").strip()
        if not ref.startswith("#"):
            continue

        entity_id = ref[1:]
        if entity_id.startswith("ehsl_"):
            entity_id = entity_id[1:]

        entity = catalog.get(entity_id)
        if entity is None:
            continue

        expected_kind = "person" if rs_type == "person" else ("work" if rs_type == "bibl" else "place")
        if entity["kind"] != expected_kind:
            continue

        entities.add(entity_id)

    return entities


def collect_memberships(editions_dir: Path, catalog: dict[str, dict[str, str]]) -> tuple[dict[str, set[str]], dict[str, set[str]], dict[str, str], list[str]]:
    chapter_memberships: dict[str, set[str]] = defaultdict(set)
    paragraph_memberships: dict[str, set[str]] = defaultdict(set)
    edition_labels: dict[str, str] = {}
    chapter_order: list[str] = []

    for edition_path in sorted(editions_dir.glob("*.xml")):
        root = ET.parse(edition_path).getroot()
        source_edition_number = parse_source_edition_number(root)
        if source_edition_number != "10":
            continue

        year = parse_publication_year(root)
        if not year:
            continue

        edition_labels[year] = parse_edition_label(root)

        for div in root.findall(".//tei:text/tei:body/tei:div", NS):
            chapter = chapter_bucket(div)
            if chapter is None:
                continue
            if chapter not in chapter_order:
                chapter_order.append(chapter)

            chapter_key = f"{year}::{chapter}"
            chapter_entities = extract_entities(div, catalog)
            for entity_id in chapter_entities:
                chapter_memberships[entity_id].add(chapter_key)

            for index, paragraph in enumerate(div.findall(".//tei:p", NS), start=1):
                paragraph_entities = extract_entities(paragraph, catalog)
                if not paragraph_entities:
                    continue

                paragraph_n = (paragraph.get("n") or "").strip() or f"p{index}"
                paragraph_key = f"{year}::{chapter}::{paragraph_n}"
                for entity_id in paragraph_entities:
                    paragraph_memberships[entity_id].add(paragraph_key)

    return chapter_memberships, paragraph_memberships, edition_labels, chapter_order


def generate_vms_payload(args: argparse.Namespace) -> dict:
    person_root = ET.parse(args.person_index).getroot()
    place_root = ET.parse(args.place_index).getroot()
    work_root = ET.parse(args.work_index).getroot()

    catalog = build_catalog(person_root, place_root, work_root)
    chapter_memberships, paragraph_memberships, edition_labels, chapter_order = collect_memberships(
        args.traktat_editions_dir,
        catalog,
    )

    nodes: list[dict] = []
    for entity_id, meta in sorted(
        catalog.items(),
        key=lambda item: (
            0 if item[1]["kind"] == "person" else (1 if item[1]["kind"] == "place" else 2),
            item[1]["label"].casefold(),
        ),
    ):
        chapter_keys = sorted(chapter_memberships.get(entity_id, set()))
        paragraph_keys = sorted(paragraph_memberships.get(entity_id, set()))

        if not chapter_keys and not paragraph_keys:
            continue

        nodes.append(
            {
                "id": entity_id,
                "kind": meta["kind"],
                "label": meta["label"],
                "url": meta["url"],
                "chapterKeys": chapter_keys,
                "paragraphKeys": paragraph_keys,
            }
        )

    return {
        "editions": [
            {"year": year, "label": edition_labels[year]}
            for year in sorted(edition_labels.keys(), key=int)
        ],
        "chapters": chapter_order,
        "nodes": nodes,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate JSON data for VMS network page")
    parser.add_argument(
        "--person-index",
        type=Path,
        default=Path("data/indices/listperson.xml"),
        help="Path to the person index XML (default: %(default)s)",
    )
    parser.add_argument(
        "--work-index",
        type=Path,
        default=Path("data/indices/listbibl.xml"),
        help="Path to the work index XML (default: %(default)s)",
    )
    parser.add_argument(
        "--place-index",
        type=Path,
        default=Path("data/indices/listplace.xml"),
        help="Path to the place index XML (default: %(default)s)",
    )
    parser.add_argument(
        "--traktat-editions-dir",
        type=Path,
        default=Path("data/traktat/editions"),
        help="Directory with traktat TEI editions (default: %(default)s)",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=Path("html/data/vms-network-data.json"),
        help="Output JSON file for VMS network (default: %(default)s)",
    )
    return parser


def main(argv: list[str] | None = None) -> None:
    parser = build_parser()
    args = parser.parse_args(argv)
    write_json(args.out, generate_vms_payload(args))


if __name__ == "__main__":
    main()
