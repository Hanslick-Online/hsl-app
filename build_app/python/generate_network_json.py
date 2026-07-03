#!/usr/bin/env python3
"""Generate JSON payloads for Hanslick network pages.

This unifies the previous standalone scripts:
- generate_person_network_json.py
- generate_vms_network_json.py

Usage:
    python3 build_app/python/generate_network_json.py person \
        --person-index data/indices/listperson.xml \
        --doc-editions-dir data/doc/editions \
        --out html/person-network-data.json

    python3 build_app/python/generate_network_json.py vms \
        --person-index data/indices/listperson.xml \
        --work-index data/indices/listbibl.xml \
        --traktat-editions-dir data/traktat/editions \
        --out html/data/vms-network-data.json
"""

from __future__ import annotations

import argparse
import json
from collections import defaultdict
from collections.abc import Iterable
from pathlib import Path
import re
import xml.etree.ElementTree as ET

NS = {"tei": "http://www.tei-c.org/ns/1.0"}
XML_ID = "{http://www.w3.org/XML/1998/namespace}id"
DEFAULT_HANSLICK_ID = "hsl_person_id_1"


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


def unique_preserve_order(values: Iterable[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            result.append(value)
    return result


def write_json(out_path: Path, payload: dict) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )


# ----------------------------
# Person network generation
# ----------------------------

def person_label(person: ET.Element) -> str:
    return text_content(first(person, "tei:persName[@type='main']", "tei:persName"))


def normalize_target(target: str) -> str:
    if target.startswith("t__"):
        return "t__VMS_TREATISE"
    return target


def mention_targets(person: ET.Element) -> list[str]:
    targets: list[str] = []
    for note in person.findall("tei:noteGrp/tei:note[@type='mentions']", NS):
        target = (note.get("target") or "").strip()
        if target:
            targets.append(target)
    return unique_preserve_order(targets)


def pub_targets_from_mentions(targets: list[str]) -> list[str]:
    return unique_preserve_order(
        normalize_target(target)
        for target in targets
        if target.startswith("c__") or target.startswith("t__")
    )


def doc_mention_targets_from_mentions(targets: list[str]) -> list[str]:
    return unique_preserve_order(
        target for target in targets if target.startswith("d__")
    )


def load_doc_editions(doc_targets: list[str], doc_editions_dir: Path) -> list[tuple[Path, ET.Element]]:
    docs: list[tuple[Path, ET.Element]] = []
    for target in doc_targets:
        doc_path = doc_editions_dir / target
        if not doc_path.exists():
            continue
        docs.append((doc_path, ET.parse(doc_path).getroot()))
    return docs


def doc_authored_targets(person: ET.Element, docs: list[tuple[Path, ET.Element]]) -> list[str]:
    person_id = (person.get(XML_ID) or "").strip()
    if not person_id:
        return []

    person_ref = f"#{person_id}"
    matches: list[str] = []

    for doc_path, root in docs:
        authored = root.findall(".//tei:teiHeader//tei:author", NS)
        if any((author.get("ref") or "").strip() == person_ref for author in authored):
            doc_id = (root.get(XML_ID) or "").strip()
            matches.append(doc_id if doc_id else doc_path.name)

    return unique_preserve_order(matches)


def node_group(person: ET.Element, hanslick_id: str, rel_pub: int, rel_doc_mentions: int, rel_doc_authored: int) -> str:
    person_id = (person.get(XML_ID) or "").strip()
    role = (person.get("role") or "").strip()

    if person_id == hanslick_id:
        return "hanslick"
    if rel_doc_authored > 0:
        return "doc-author"
    if rel_doc_mentions > 0 and role == "fictional":
        return "doc-character"
    if rel_doc_mentions > 0:
        return "doc-person"
    if rel_pub > 0 and role == "fictional":
        return "pub-character"
    return "pub-person"


def generate_person_payload(args: argparse.Namespace) -> dict:
    root = ET.parse(args.person_index).getroot()
    persons = root.findall(".//tei:listPerson/tei:person", NS)

    mention_cache: dict[str, list[str]] = {}
    for person in persons:
        person_id = (person.get(XML_ID) or "").strip()
        if not person_id:
            continue
        mention_cache[person_id] = mention_targets(person)

    all_doc_targets = unique_preserve_order(
        target
        for targets in mention_cache.values()
        for target in doc_mention_targets_from_mentions(targets)
    )
    docs = load_doc_editions(all_doc_targets, args.doc_editions_dir)

    nodes: list[dict] = []
    max_rel = 1

    for person in persons:
        person_id = (person.get(XML_ID) or "").strip()
        if not person_id:
            continue

        person_mentions = mention_cache.get(person_id, [])
        rel_pub_targets = pub_targets_from_mentions(person_mentions)
        rel_doc_targets = doc_mention_targets_from_mentions(person_mentions)
        rel_authored_targets = doc_authored_targets(person, docs)
        relation_targets = unique_preserve_order(
            rel_pub_targets + rel_doc_targets + rel_authored_targets
        )

        rel_total = len(relation_targets)
        max_rel = max(max_rel, rel_total)

        if person_id != args.hanslick_id and rel_total == 0:
            continue

        nodes.append(
            {
                "id": person_id,
                "label": person_label(person),
                "url": f"{person_id}.html",
                "group": node_group(
                    person,
                    args.hanslick_id,
                    len(rel_pub_targets),
                    len(rel_doc_targets),
                    len(rel_authored_targets),
                ),
                "relTotal": rel_total,
                "relPub": len(rel_pub_targets),
                "relDocMentions": len(rel_doc_targets),
                "relDocAuthored": len(rel_authored_targets),
                "targets": relation_targets,
            }
        )

    return {
        "hanslickId": args.hanslick_id,
        "maxRel": max_rel,
        "nodes": nodes,
    }


# ----------------------------
# VMS network generation
# ----------------------------

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


def chapter_bucket(div: ET.Element) -> str | None:
    heading = text_content(div.find("tei:head", NS))
    if not heading:
        return None

    if heading.casefold().startswith("vorwort"):
        return "Vorwort"

    match = re.match(r"^([IVXLCDM]+)\\b", heading, re.IGNORECASE)
    if not match:
        return None

    return match.group(1).upper()


def entity_label(kind: str, node: ET.Element) -> str:
    if kind == "person":
        return text_content(first(node, "tei:persName[@type='main']", "tei:persName"))
    return text_content(first(node, "tei:title[@type='main']", "tei:title"))


def include_person(node: ET.Element) -> bool:
    role = (node.get("role") or "").strip().lower()
    is_character = node.find("tei:listBibl[@type='characterOf']", NS) is not None
    return role != "fictional" and not is_character


def build_catalog(person_root: ET.Element, work_root: ET.Element) -> dict[str, dict[str, str]]:
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

    return catalog


def extract_entities(context_node: ET.Element, catalog: dict[str, dict[str, str]]) -> set[str]:
    entities: set[str] = set()
    for rs in context_node.findall(".//tei:rs", NS):
        rs_type = (rs.get("type") or "").strip()
        if rs_type not in {"person", "bibl"}:
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

        expected_kind = "person" if rs_type == "person" else "work"
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
    work_root = ET.parse(args.work_index).getroot()

    catalog = build_catalog(person_root, work_root)
    chapter_memberships, paragraph_memberships, edition_labels, chapter_order = collect_memberships(
        args.traktat_editions_dir,
        catalog,
    )

    nodes: list[dict] = []
    for entity_id, meta in sorted(
        catalog.items(),
        key=lambda item: (0 if item[1]["kind"] == "person" else 1, item[1]["label"].casefold()),
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


# ----------------------------
# CLI
# ----------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate JSON data for network pages")
    parser.add_argument(
        "--network",
        choices=("all", "person", "vms"),
        default="all",
        help="Which network JSON to build (default: %(default)s)",
    )
    parser.add_argument(
        "--person-index",
        type=Path,
        default=Path("data/indices/listperson.xml"),
        help="Path to the person index XML (default: %(default)s)",
    )
    parser.add_argument(
        "--doc-editions-dir",
        type=Path,
        default=Path("data/doc/editions"),
        help="Directory containing document editions (default: %(default)s)",
    )
    parser.add_argument(
        "--hanslick-id",
        type=str,
        default=DEFAULT_HANSLICK_ID,
        help="Center person id used for group assignment (default: %(default)s)",
    )
    parser.add_argument(
        "--work-index",
        type=Path,
        default=Path("data/indices/listbibl.xml"),
        help="Path to the work index XML (default: %(default)s)",
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
        default=None,
        help="Output JSON file for single-network builds only",
    )
    parser.add_argument(
        "--person-out",
        type=Path,
        default=Path("html/person-network-data.json"),
        help="Output JSON file for person network (default: %(default)s)",
    )
    parser.add_argument(
        "--vms-out",
        type=Path,
        default=Path("html/data/vms-network-data.json"),
        help="Output JSON file for VMS network (default: %(default)s)",
    )
    return parser


def main(argv: list[str] | None = None) -> None:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.network == "all":
        if args.out is not None:
            parser.error("--out is only valid with --network person or --network vms")
        write_json(args.person_out, generate_person_payload(args))
        write_json(args.vms_out, generate_vms_payload(args))
        return

    output = args.out if args.out is not None else (args.person_out if args.network == "person" else args.vms_out)
    if args.network == "person":
        write_json(output, generate_person_payload(args))
    else:
        write_json(output, generate_vms_payload(args))


if __name__ == "__main__":
    main()
