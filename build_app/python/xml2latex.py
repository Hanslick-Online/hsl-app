#!/usr/bin/env python
import glob
import os
from acdh_tei_pyutils.tei import TeiReader, ET
import sys

files = sorted(glob.glob(os.path.join("data", "editions", "*.xml")))

def process_paragraph(element):
    """
    Processes a paragraph element to combine all text, adding spaces where needed,
    and handle <lb>, <cb>, and inline elements properly.
    """
    result = []
    for node in element.iter():
        # Handle line or column breaks
        if node.tag.endswith("lb") or node.tag.endswith("cb"):
            if node.attrib.get("break") != "no":
                result.append(" ")  # Add space unless break="no"

        # Add the current node's text content
        if node.text:
            result.append(node.text.strip())

        # Add the tail content after a child node
        if node.tail:
            result.append(node.tail.strip())

    return " ".join(result).strip() + "\n\n"  # Join with spaces to avoid word merging


def transform_tei_to_latex(input_file, output_file):
    # Parse the XML-TEI file
    tree = TeiReader(input_file)

    titles =  tree.any_xpath(".//tei:analytic/tei:title") + tree.any_xpath(".//tei:monogr/tei:title")
    titles = [t for t in titles if t.text]
    origeditors = tree.any_xpath(".//tei:monogr/tei:respStmt/tei:name")
    for idx, title in enumerate(titles):
        print(title.text)
        if idx > 0:
            titles[idx] = f"\\Large{{{title.text}}}"
        else:
            titles[idx] = title.text
    authors = [a.text for a in tree.any_xpath(".//tei:author")]
    title = "\\\\".join(titles)
    author = ", ".join(authors)
    origdate = "{20. Jänner 1890}"

    # Example: Extracting some TEI elements and converting to LaTeX
    latex_content = []
    latex_content.append("\\documentclass{article}")
    latex_content.append("\\usepackage[austrian]{babel}")
    latex_content.append("\\usepackage{fontspec}")
    latex_content.append("\\usepackage{microtype}")
    latex_content.append("\\setmainfont{Latin Modern Roman}")
    latex_content.append(f"\\title{{{title}}}")
    latex_content.append(f"\\author{{{author}}}")
    latex_content.append(f"\\date{origdate}")
    latex_content.append("\\begin{document}")
    latex_content.append("\\maketitle")

    for elem in tree.any_xpath(".//tei:head"):
        text = "".join(elem.itertext()).strip().strip(".") 
        latex_content.append(f"\\section*{{{text}}}")
    
    for p in tree.any_xpath(".//tei:text//tei:body//tei:div//tei:p"):
        print(p)
        paragraph_text = process_paragraph(p)
        if paragraph_text:
            latex_content.append(paragraph_text)
        print(paragraph_text)



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
