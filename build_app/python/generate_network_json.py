#!/usr/bin/env python3
"""Generate JSON payload for the person network page.

Usage:
    python3 build_app/python/generate_network_json.py \
        --person-index data/indices/listperson.xml \
        --place-index data/indices/listplace.xml \
        --work-index data/indices/listbibl.xml \
        --critics-editions-dir data/critics/editions \
        --traktat-editions-dir data/traktat/editions \
        --out html/data/person-network-data.json
"""

from __future__ import annotations

import argparse
import json
from collections.abc import Hashable, Iterable
from pathlib import Path
import re
from typing import TypeVar
import xml.etree.ElementTree as ET

NS = {"tei": "http://www.tei-c.org/ns/1.0"}
XML_ID = "{http://www.w3.org/XML/1998/namespace}id"
DEFAULT_HANSLICK_ID = "hsl_person_id_1"
ENTITY_REF_PATTERN = re.compile(r"#?e?(hsl_(?:person|work|place)_id_[A-Za-z0-9_\-]+)")
TARGET_VMS_FILENAME = "t__10_VMS_1902_TEI_AW_26-01-21-TEI-P5.xml"
T = TypeVar("T", bound=Hashable)


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


def unique_preserve_order(values: Iterable[T]) -> list[T]:
    seen: set[T] = set()
    result: list[T] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            result.append(value)
    return result


def write_json(out_path: Path, payload: dict) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def person_label(person: ET.Element) -> str:
    return text_content(first(person, "tei:persName[@type='main']", "tei:persName"))


def work_label(work: ET.Element) -> str:
    return text_content(first(work, "tei:title[@type='main']", "tei:title"))


def place_label(place: ET.Element) -> str:
    return text_content(
        first(
            place,
            "tei:settlement/tei:placeName[@type='main']",
            "tei:placeName[@type='main']",
            "tei:settlement/tei:placeName",
            "tei:placeName",
        )
    )


def build_entity_catalog(args: argparse.Namespace) -> dict[str, dict[str, str]]:
    person_root = ET.parse(args.person_index).getroot()
    work_root = ET.parse(args.work_index).getroot()
    place_root = ET.parse(args.place_index).getroot()
    catalog: dict[str, dict[str, str]] = {}

    for person in person_root.findall(".//tei:listPerson/tei:person", NS):
        entity_id = (person.get(XML_ID) or "").strip()
        label = person_label(person)
        if entity_id and label:
            catalog[entity_id] = {
                "kind": "person",
                "label": label,
                "url": f"{entity_id}.html",
            }

    for work in work_root.findall(".//tei:listBibl/tei:bibl", NS):
        entity_id = (work.get(XML_ID) or "").strip()
        label = work_label(work)
        if entity_id and label:
            catalog[entity_id] = {
                "kind": "work",
                "label": label,
                "url": f"{entity_id}.html",
            }

    for place in place_root.findall(".//tei:listPlace/tei:place", NS):
        entity_id = (place.get(XML_ID) or "").strip()
        label = place_label(place)
        if entity_id and label:
            catalog[entity_id] = {
                "kind": "place",
                "label": label,
                "url": f"{entity_id}.html",
            }

    return catalog


def normalize_collection_target(collection: str, file_name: str) -> str:
    if collection == "nfp":
        if file_name.startswith("c__"):
            return file_name
        return f"c__{file_name}"

    if file_name.startswith("t__"):
        return file_name
    if file_name.startswith("v__"):
        return f"t__{file_name[3:]}"
    return f"t__{file_name}"


def extract_entity_ids_in_node(context_node: ET.Element, catalog: dict[str, dict[str, str]]) -> set[str]:
    entity_ids: set[str] = set()
    for node in context_node.iter():
        for attr in ("ref", "corresp"):
            value = (node.get(attr) or "").strip()
            if not value:
                continue

            for match in ENTITY_REF_PATTERN.findall(value):
                entity_id = match.strip()
                if entity_id in catalog:
                    entity_ids.add(entity_id)

    return entity_ids


def extract_entity_ids_from_body(root: ET.Element, catalog: dict[str, dict[str, str]]) -> set[str]:
    body = root.find(".//tei:text/tei:body", NS)
    if body is None:
        return set()

    return extract_entity_ids_in_node(body, catalog)


def extract_entity_ids_by_vms_chapter(root: ET.Element, catalog: dict[str, dict[str, str]]) -> dict[int, set[str]]:
    body = root.find(".//tei:text/tei:body", NS)
    if body is None:
        return {}

    by_chapter: dict[int, set[str]] = {}
    chapter_index = 0

    for div in body.findall("tei:div", NS):
        by_chapter[chapter_index] = extract_entity_ids_in_node(div, catalog)
        chapter_index += 1

    return by_chapter


def collect_targets_by_collection(
    catalog: dict[str, dict[str, str]],
    critics_editions_dir: Path,
    traktat_editions_dir: Path,
) -> dict[str, dict[str, list[str] | list[int]]]:
    memberships: dict[str, dict[str, list[str] | list[int]]] = {}

    def append_target(entity_id: str, collection: str, target_id: str | int) -> None:
        if entity_id not in memberships:
            memberships[entity_id] = {"nfp": [], "vms": []}
        memberships[entity_id][collection].append(target_id)

    for edition_path in sorted(critics_editions_dir.glob("*.xml")):
        root = ET.parse(edition_path).getroot()
        entity_ids = extract_entity_ids_from_body(root, catalog)
        target_id = normalize_collection_target("nfp", edition_path.name)

        for entity_id in entity_ids:
            append_target(entity_id, "nfp", target_id)

    vms_path = traktat_editions_dir / TARGET_VMS_FILENAME
    if vms_path.exists():
        vms_root = ET.parse(vms_path).getroot()
        by_chapter = extract_entity_ids_by_vms_chapter(vms_root, catalog)

        for chapter_index, entity_ids in by_chapter.items():
            for entity_id in entity_ids:
                append_target(entity_id, "vms", chapter_index)

    for entity_id, by_collection in memberships.items():
        memberships[entity_id] = {
            "nfp": unique_preserve_order(by_collection["nfp"]),
            "vms": unique_preserve_order(by_collection["vms"]),
        }

    return memberships


def generate_person_payload(args: argparse.Namespace) -> dict:
    catalog = build_entity_catalog(args)
    targets_by_entity = collect_targets_by_collection(
        catalog,
        args.critics_editions_dir,
        args.traktat_editions_dir,
    )

    kind_order = {"person": 0, "work": 1, "place": 2}
    work_catalog = {
        entity_id: {
            "label": meta["label"],
            "url": meta["url"],
        }
        for entity_id, meta in catalog.items()
        if meta["kind"] == "work"
    }
    nodes: list[dict] = []
    max_rel = 1

    for entity_id, meta in sorted(
        catalog.items(),
        key=lambda item: (kind_order.get(item[1]["kind"], 99), item[1]["label"].casefold()),
    ):
        rel_targets_by_collection = targets_by_entity.get(entity_id, {"nfp": [], "vms": []})
        relation_targets = unique_preserve_order(rel_targets_by_collection["nfp"] + rel_targets_by_collection["vms"])
        rel_total = len(relation_targets)
        max_rel = max(max_rel, rel_total)

        if entity_id != args.hanslick_id and rel_total == 0:
            continue

        group = "hanslick" if entity_id == args.hanslick_id else ("pub-work" if meta["kind"] == "work" else "pub-person")

        nodes.append(
            {
                "id": entity_id,
                "label": meta["label"],
                "url": meta["url"],
                "kind": meta["kind"],
                "group": group,
                "targetsByCollection": rel_targets_by_collection,
            }
        )

    return {
        "hanslickId": args.hanslick_id,
        "maxRel": max_rel,
        "nodes": nodes,
        "workCatalog": work_catalog,
    }


# ----------------------------
# CLI
# ----------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate JSON data for person network page")
    parser.add_argument(
        "--person-index",
        type=Path,
        default=Path("data/indices/listperson.xml"),
        help="Path to the person index XML (default: %(default)s)",
    )
    parser.add_argument(
        "--place-index",
        type=Path,
        default=Path("data/indices/listplace.xml"),
        help="Path to the place index XML (default: %(default)s)",
    )
    parser.add_argument(
        "--critics-editions-dir",
        type=Path,
        default=Path("data/critics/editions"),
        help="Directory with critics TEI editions (default: %(default)s)",
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
        default=Path("html/data/person-network-data.json"),
        help="Output JSON file for person network (default: %(default)s)",
    )
    return parser


def main(argv: list[str] | None = None) -> None:
    parser = build_parser()
    args = parser.parse_args(argv)

    write_json(args.out, generate_person_payload(args))


if __name__ == "__main__":
    main()