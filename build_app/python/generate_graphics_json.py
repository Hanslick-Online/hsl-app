#!/usr/bin/env python3
"""Generate chart payload JSON for the graphics page.

This script reads the TEI index files used by the graphics chart and writes a
single JSON file that contains all entity labels and yearly corpus counts.

Usage:
    python3 build_app/python/generate_graphics_json.py \
        --person-index data/indices/listperson.xml \
        --work-index data/indices/listbibl.xml \
        --place-index data/indices/listplace.xml \
        --out html/data/graphics-chart-data.json
"""

from __future__ import annotations

import argparse
import json
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
import xml.etree.ElementTree as ET

NS = {"tei": "http://www.tei-c.org/ns/1.0"}
CORPUS_PREFIXES = {
    "t__": "traktat",
    "c__": "critics",
    "v__": "vms",
    "d__": "documents",
}


@dataclass(frozen=True)
class EntitySpec:
    kind: str
    xpath: str


ENTITY_SPECS = [
    EntitySpec("person", ".//tei:person"),
    EntitySpec("work", ".//tei:listBibl/tei:bibl"),
    EntitySpec("place", ".//tei:place"),
]


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


def corpus_from_target(target: str) -> str | None:
    for prefix, corpus in CORPUS_PREFIXES.items():
        if target.startswith(prefix):
            return corpus
    return None


def is_year_like(value: str) -> bool:
    value = value.strip()
    return len(value) >= 4 and value[:4].isdigit()


def entity_label(kind: str, node: ET.Element) -> str:
    if kind == "person":
        return text_content(first(node, "tei:persName[@type='main']", "tei:persName"))
    if kind == "work":
        return text_content(first(node, "tei:title[@type='main']", "tei:title"))
    return text_content(first(node, ".//tei:placeName[@type='main']", ".//tei:placeName"))


def mentions_for_entity(node: ET.Element) -> dict[int, dict[str, int]]:
    # Distinct targets per year/corpus: mirrors XSLT count(distinct-values(@target)).
    buckets: dict[int, dict[str, set[str]]] = defaultdict(lambda: defaultdict(set))

    for note in node.findall("tei:noteGrp/tei:note[@type='mentions']", NS):
        corresp = (note.get("corresp") or "").strip()
        target = (note.get("target") or "").strip()

        if not (is_year_like(corresp) and target):
            continue

        corpus = corpus_from_target(target)
        if corpus is None:
            continue

        year = int(corresp[:4])
        buckets[year][corpus].add(target)

    collapsed: dict[int, dict[str, int]] = {}
    for year, corpus_map in buckets.items():
        collapsed[year] = {
            "traktat": len(corpus_map.get("traktat", set())),
            "critics": len(corpus_map.get("critics", set())),
            "vms": len(corpus_map.get("vms", set())),
            "documents": len(corpus_map.get("documents", set())),
        }

    return collapsed


def include_entity(kind: str, node: ET.Element, yearly_counts: dict[int, dict[str, int]]) -> bool:
    if not yearly_counts:
        return False

    if kind != "person":
        return True

    role = (node.get("role") or "").strip().lower()
    is_character = node.find("tei:listBibl[@type='characterOf']", NS) is not None
    return role != "fictional" and not is_character


def collect_entities(kind: str, root: ET.Element) -> list[dict]:
    entities: list[dict] = []

    xpath = next(spec.xpath for spec in ENTITY_SPECS if spec.kind == kind)
    for node in root.findall(xpath, NS):
        entity_id = node.get("{http://www.w3.org/XML/1998/namespace}id")
        if not entity_id:
            continue

        yearly_counts = mentions_for_entity(node)
        if not include_entity(kind, node, yearly_counts):
            continue

        label = entity_label(kind, node)
        if not label:
            continue

        entities.append(
            {
                "id": entity_id,
                "kind": kind,
                "label": label,
                "years": {str(year): counts for year, counts in sorted(yearly_counts.items())},
            }
        )

    return entities


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate JSON data for the graphics chart")
    parser.add_argument("--person-index", required=True, type=Path)
    parser.add_argument("--work-index", required=True, type=Path)
    parser.add_argument("--place-index", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    person_root = ET.parse(args.person_index).getroot()
    work_root = ET.parse(args.work_index).getroot()
    place_root = ET.parse(args.place_index).getroot()

    entities = []
    entities.extend(collect_entities("person", person_root))
    entities.extend(collect_entities("work", work_root))
    entities.extend(collect_entities("place", place_root))

    entities.sort(key=lambda item: ({"person": 0, "work": 1, "place": 2}[item["kind"]], item["label"].casefold()))

    all_years = [int(year) for entity in entities for year in entity["years"].keys()]
    min_year = min(all_years) if all_years else 0
    max_year = max(all_years) if all_years else 0

    payload = {
        "min_year": min_year,
        "max_year": max_year,
        "entities": entities,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")


if __name__ == "__main__":
    main()
