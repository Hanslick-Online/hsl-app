#!/usr/bin/env python3
"""Generate JSON payload for the person network page.

This script mirrors the former XSLT-based JSON generation in
xslt/partials/graphics_net.xsl and writes html/person-network-data.json.

Usage:
    python3 build_app/python/generate_person_network_json.py \
        --person-index data/indices/listperson.xml \
        --doc-editions-dir data/doc/editions \
        --out html/person-network-data.json
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import xml.etree.ElementTree as ET

NS = {"tei": "http://www.tei-c.org/ns/1.0"}
XML_ID = "{http://www.w3.org/XML/1998/namespace}id"
DEFAULT_HANSLICK_ID = "hsl_person_id_1"


def unique_preserve_order(values: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for value in values:
        if value and value not in seen:
            seen.add(value)
            result.append(value)
    return result


def text_content(node: ET.Element | None) -> str:
    if node is None:
        return ""
    return " ".join("".join(node.itertext()).split())


def person_label(person: ET.Element) -> str:
    main = person.find("tei:persName[@type='main']", NS)
    fallback = person.find("tei:persName", NS)
    return text_content(main if main is not None else fallback)


def normalize_target(target: str) -> str:
    if target.startswith("t__"):
        return "t__VMS_TREATISE"
    return target


def pub_targets(person: ET.Element) -> list[str]:
    raw: list[str] = []
    for note in person.findall("tei:noteGrp/tei:note[@type='mentions']", NS):
        target = (note.get("target") or "").strip()
        if target.startswith("c__") or target.startswith("t__"):
            raw.append(normalize_target(target))
    return unique_preserve_order(raw)


def doc_mention_targets(person: ET.Element) -> list[str]:
    raw: list[str] = []
    for note in person.findall("tei:noteGrp/tei:note[@type='mentions']", NS):
        target = (note.get("target") or "").strip()
        if target.startswith("d__"):
            raw.append(target)
    return unique_preserve_order(raw)


def collect_doc_targets(persons: list[ET.Element]) -> list[str]:
    targets: list[str] = []
    for person in persons:
        targets.extend(doc_mention_targets(person))
    return unique_preserve_order(targets)


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
        if not any((author.get("ref") or "").strip() == person_ref for author in authored):
            continue

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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate JSON data for the person network page")
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
        "--out",
        type=Path,
        default=Path("html/person-network-data.json"),
        help="Output JSON file (default: %(default)s)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    root = ET.parse(args.person_index).getroot()
    persons = root.findall(".//tei:listPerson/tei:person", NS)

    doc_targets = collect_doc_targets(persons)
    docs = load_doc_editions(doc_targets, args.doc_editions_dir)

    nodes: list[dict] = []
    max_rel = 1

    for person in persons:
        person_id = (person.get(XML_ID) or "").strip()
        if not person_id:
            continue

        rel_pub_targets = pub_targets(person)
        rel_doc_targets = doc_mention_targets(person)
        rel_authored_targets = doc_authored_targets(person, docs)
        relation_targets = unique_preserve_order(rel_pub_targets + rel_doc_targets + rel_authored_targets)

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

    payload = {
        "hanslickId": args.hanslick_id,
        "maxRel": max_rel,
        "nodes": nodes,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")


if __name__ == "__main__":
    main()
