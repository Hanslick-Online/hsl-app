#!/usr/bin/env python
import sys
from lxml import etree


def transform_tei_to_latex(input_file, output_file):
    # Parse the XML-TEI file
    tree = etree.parse(input_file)
    root = tree.getroot()

    # Example: Extracting some TEI elements and converting to LaTeX
    latex_content = []
    latex_content.append("\\documentclass{article}")
    latex_content.append("\\begin{document}")

    for elem in root.findall(".//text//body//p"):
        text = elem.text or ""
        latex_content.append(f"\\paragraph{{{text.strip()}}}")

    latex_content.append("\\end{document}")

    # Write the LaTeX content to the output file
    with open(output_file, "w", encoding="utf-8") as f:
        f.write("\n".join(latex_content))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python transform_tei_to_latex.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    transform_tei_to_latex(input_file, output_file)
