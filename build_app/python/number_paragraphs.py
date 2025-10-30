#!/usr/bin/env python3
"""Add sequential @n attributes to <tei:p> nodes lacking them."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable

from lxml import etree as ET

TEI_NS = {"tei": "http://www.tei-c.org/ns/1.0"}


def iter_bodies(tree: ET._ElementTree) -> Iterable[ET._Element]:
    """Yield every <tei:body> element in document."""

    return tree.xpath("//tei:body", namespaces=TEI_NS)


def add_missing_numbers(doc_path: Path, *, dry_run: bool = False, output_path: Path | None = None) -> int:
    """Add @n attributes to <tei:p> nodes without one (or empty) and return count of updates."""

    tree = ET.parse(str(doc_path))
    updated = 0

    for body in iter_bodies(tree):
        counter = 1
        for para in body.xpath(".//tei:p", namespaces=TEI_NS):
            current = (para.get("n") or "").strip()
            if current:
                try:
                    counter = int(current) + 1
                except ValueError:
                    counter += 1
                continue
            para.set("n", str(counter))
            counter += 1
            updated += 1

    if dry_run:
        return updated

    destination = output_path if output_path is not None else doc_path
    tree.write(
        str(destination),
        encoding="UTF-8",
        xml_declaration=True,
        pretty_print=True,
    )
    return updated


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Add sequential @n attributes to <tei:p> elements below <tei:body> "
            "when the attribute is missing or empty."
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
        help="Report how many @n attributes would be added without writing changes",
    )
    args = parser.parse_args()

    if args.output and len(args.input) != 1:
        parser.error("--output can only be used when processing a single input file")

    total_updates = 0
    for input_path in args.input:
        if not input_path.exists():
            parser.error(f"Input file not found: {input_path}")
        target_output = args.output if args.output else None
        added = add_missing_numbers(
            input_path,
            dry_run=args.dry_run,
            output_path=target_output,
        )
        total_updates += added
        print(f"{input_path}: added {added} @n attributes")

    if args.dry_run:
        print(f"Dry run finished, {total_updates} attributes would be added across all files")


if __name__ == "__main__":
    main()
