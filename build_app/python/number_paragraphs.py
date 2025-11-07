#!/usr/bin/env python3
"""Ensure <tei:p> nodes have @xml:id attributes (numeration disabled)."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable

from lxml import etree as ET

TEI_NS = {"tei": "http://www.tei-c.org/ns/1.0"}
XML_NS = "http://www.w3.org/XML/1998/namespace"
XML_ID_ATTR = f"{{{XML_NS}}}id"


def iter_bodies(tree: ET._ElementTree) -> Iterable[ET._Element]:
    """Yield every <tei:body> element in document."""

    return tree.xpath("//tei:body", namespaces=TEI_NS)


def add_missing_numbers(
    doc_path: Path,
    *,
    dry_run: bool = False,
    output_path: Path | None = None,
) -> tuple[int, int]:
    """Add @xml:id attributes to <tei:p> nodes lacking them and report totals."""

    tree = ET.parse(str(doc_path))
    number_updates = 0
    id_updates = 0

    existing_ids: set[str] = set(
        tree.xpath("//*/@xml:id", namespaces={"xml": XML_NS})
    )
    id_counter = 1

    def next_xml_id() -> str:
        nonlocal id_counter
        while True:
            candidate = f"p_auto_{id_counter:05d}"
            id_counter += 1
            if candidate not in existing_ids:
                existing_ids.add(candidate)
                return candidate

    for body in iter_bodies(tree):
        for para in body.xpath(".//tei:p", namespaces=TEI_NS):
            xml_id = (para.get(XML_ID_ATTR) or "").strip()
            if not xml_id:
                para.set(XML_ID_ATTR, next_xml_id())
                id_updates += 1
            # Numeration logic intentionally disabled; keeping existing @n values.
            # current = (para.get("n") or "").strip()
            # if not current:
            #     para.set("n", str(counter))
            #     number_updates += 1
            # counter += 1

    if dry_run:
        return number_updates, id_updates

    destination = output_path if output_path is not None else doc_path
    tree.write(
        str(destination),
        encoding="UTF-8",
        xml_declaration=True,
        pretty_print=True,
    )
    return number_updates, id_updates


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Ensure every <tei:p> element below <tei:body> has an @xml:id attribute."
        )
    )
    parser.add_argument(
        "input",
        nargs="+",
        type=Path,
        help="One or more TEI XML files to update",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Optional path for a single output file (only valid with one input file)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
    help="Report how many @xml:id attributes would be added without writing changes",
    )
    args = parser.parse_args()

    if args.output and len(args.input) != 1:
        parser.error("--output can only be used when processing a single input file")

    total_number_updates = 0
    total_id_updates = 0
    for input_path in args.input:
        if not input_path.exists():
            parser.error(f"Input file not found: {input_path}")
        target_output = args.output if args.output else None
        added_numbers, added_ids = add_missing_numbers(
            input_path,
            dry_run=args.dry_run,
            output_path=target_output,
        )
        total_number_updates += added_numbers
        total_id_updates += added_ids
        print(f"{input_path}: added {added_ids} @xml:id attributes")

    if args.dry_run:
        print(
            "Dry run finished, "
            f"{total_id_updates} @xml:id attributes would be added across all files"
        )


if __name__ == "__main__":
    main()
