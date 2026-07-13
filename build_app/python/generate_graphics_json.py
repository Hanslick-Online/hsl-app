#!/usr/bin/env python
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
import re
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

TRAKTAT_KIND_MAP = {
    "person": "person",
    "bibl": "work",
    "place": "place",
}

TRAKTAT_CHAPTER_ORDER = ["Vorwort", "I", "II", "III", "IV", "V", "VI", "VII", "VIII"]


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


def parse_edition_label(root: ET.Element) -> str:
    # xml.etree does not support XPath attribute extraction, so fetch the node.
    edition_node = root.find(".//tei:sourceDesc//tei:edition", NS)
    if edition_node is None:
        return ""

    # Keep the edition exactly as authored in the source data.
    label = text_content(edition_node)
    if label:
        return label

    return (edition_node.get("n") or "").strip()


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

    match = re.match(r"^([IVXLCDM]+)\b", heading, re.IGNORECASE)
    if not match:
        return None
    return match.group(1).upper()


def build_entity_catalog(person_root: ET.Element, work_root: ET.Element, place_root: ET.Element) -> dict[str, dict[str, str]]:
    catalog: dict[str, dict[str, str]] = {}
    for kind, root in (("person", person_root), ("work", work_root), ("place", place_root)):
        xpath = next(spec.xpath for spec in ENTITY_SPECS if spec.kind == kind)
        for node in root.findall(xpath, NS):
            entity_id = node.get("{http://www.w3.org/XML/1998/namespace}id")
            if not entity_id:
                continue

            if kind == "person":
                if not include_entity(kind, node, {0: {}}):
                    continue

            label = entity_label(kind, node)
            if not label:
                continue

            catalog[entity_id] = {"kind": kind, "label": label}

    return catalog


def collect_traktat_entities(editions_dir: Path, catalog: dict[str, dict[str, str]]) -> list[dict]:
    year_meta: dict[str, str] = {}
    counts: dict[str, dict[str, dict[str, int]]] = defaultdict(lambda: defaultdict(lambda: defaultdict(int)))

    for edition_path in sorted(editions_dir.glob("*.xml")):
        root = ET.parse(edition_path).getroot()
        year = parse_publication_year(root)
        if not year:
            continue

        year_meta[year] = parse_edition_label(root)

        for div in root.findall(".//tei:text/tei:body/tei:div", NS):
            chapter = chapter_bucket(div)
            if chapter is None:
                continue

            for ref_node in div.findall(".//tei:rs", NS):
                ref_type = (ref_node.get("type") or "").strip()
                mapped_kind = TRAKTAT_KIND_MAP.get(ref_type)
                if mapped_kind is None:
                    continue

                raw_ref = (ref_node.get("ref") or "").strip()
                if not raw_ref.startswith("#"):
                    continue

                entity_id = raw_ref[1:]
                if entity_id.startswith("ehsl_"):
                    entity_id = entity_id[1:]

                entity = catalog.get(entity_id)
                if entity is None or entity["kind"] != mapped_kind:
                    continue

                counts[entity_id][year][chapter] += 1

    entities: list[dict] = []
    for entity_id, years in counts.items():
        entity = catalog[entity_id]
        year_payload: dict[str, dict[str, int | str]] = {}

        for year in sorted(years.keys()):
            chapter_counts = years[year]
            counts_payload = {chapter: chapter_counts.get(chapter, 0) for chapter in TRAKTAT_CHAPTER_ORDER}
            counts_payload["total"] = sum(counts_payload.values())
            year_payload[year] = {
                "edition": year_meta.get(year, ""),
                **counts_payload,
            }

        entities.append(
            {
                "id": entity_id,
                "kind": entity["kind"],
                "label": entity["label"],
                "years": year_payload,
            }
        )

    entities.sort(key=lambda item: ({"person": 0, "work": 1, "place": 2}[item["kind"]], item["label"].casefold()))
    return entities


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
    parser = argparse.ArgumentParser(
        description="Generate JSON data for the graphics chart"
    )

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
        "--out",
        type=Path,
        default=Path("html/data/graphics-chart-data.json"),
        help="Output JSON file (default: %(default)s)",
    )
    parser.add_argument(
        "--traktat-editions-dir",
        type=Path,
        default=Path("data/traktat/editions"),
        help="Directory with traktat TEI editions (default: %(default)s)",
    )
    parser.add_argument(
        "--traktat-out",
        type=Path,
        default=Path("html/data/graphics-chart-traktat-entities.json"),
        help="Output JSON for traktat edition chapter counts (default: %(default)s)",
    )

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

    catalog = build_entity_catalog(person_root, work_root, place_root)
    traktat_entities = collect_traktat_entities(args.traktat_editions_dir, catalog)
    traktat_payload = {
        "chapters": TRAKTAT_CHAPTER_ORDER,
        "entities": traktat_entities,
    }
    args.traktat_out.parent.mkdir(parents=True, exist_ok=True)
    args.traktat_out.write_text(
        json.dumps(traktat_payload, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
