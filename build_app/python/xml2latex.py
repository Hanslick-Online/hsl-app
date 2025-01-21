#!/usr/bin/env python
import glob
import os
from acdh_tei_pyutils.tei import TeiReader, ET
import sys

files = sorted(glob.glob(os.path.join("data", "editions", "*.xml")))



def make_name_list(names):
    last = True
    names = [" ".join([n.strip() for n in name.split(",")][::-1]) for name in list(dict.fromkeys(names))]

    if len(names) > 1:
        names = ", ".join(names[:-1]) + " und " + names[-1]
    elif names:
        names = names[0]
    else:
        names = ""
    return names

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
        if node.tag.endswith("hi") and node.attrib.get("rendition") == "#em":
            result.append("\\textit{")
            if node.text:
                result.append(node.text.strip())
            result.append("}")
        elif node.tag.endswith("rs") and node.attrib.get("type") == "person":
            if node.text:
                result.append(node.text.strip())
        # Add the current node's text content
        elif node.text:
            result.append(node.text.strip().replace("&", "\\&"))
        # Add the tail content after a child node
        if node.tail:
            result.append(node.tail.strip().replace("&", "\\&"))
        if element.attrib.get("prev") == "true":
            spacing = ""
        else:
            spacing = "\n\n"
    return spacing + " ".join(result).strip().replace("„ ", "„").replace(" “", "“")

def get_info(tree):
    titles =  tree.any_xpath(".//tei:analytic/tei:title") + tree.any_xpath(".//tei:monogr/tei:title")
    titles = [elem.text for elem in titles if elem.text]
    authors = [elem.text for elem in tree.any_xpath(".//tei:author") if elem.text]
    origdate = tree.any_xpath(".//tei:monogr/tei:imprint/tei:date")[0].text
    origeditors = [elem.text for elem in tree.any_xpath(".//tei:monogr/tei:respStmt/tei:name") if elem.text]
    return titles, make_name_list(authors), origdate, make_name_list(origeditors)


def transform_tei_to_latex(input_file, output_file):
    # Parse the XML-TEI file
    tree = TeiReader(input_file)
    Titles, Author, Date, Editors = get_info(tree)
    # Example: Extracting some TEI elements and converting to LaTeX
    if Titles:
        Title = Titles[0]
        if Titles[1:]:
            Subtitle = '\\\\'.join([f'\\Large{{{title}}}' for title in Titles[1:]])
            Title = f'{Title}\\\\{Subtitle}'
        if Editors:
            Title = f'{Title}\\\\\\large{{Herausgegeben von {Editors}}}'
    latex_content = []
    latex_content.append("\\documentclass[a4paper]{article}")
    latex_content.append("\\usepackage[austrian]{babel}")
    latex_content.append("\\usepackage{fontspec}")
    latex_content.append("\\usepackage{microtype}")
    latex_content.append("\\setmainfont{Latin Modern Roman}")
    latex_content.append(f"\\title{{{Title}}}")
    latex_content.append(f"\\author{{{Author}}}")
    latex_content.append(f"\\date{{{Date}}}")
    latex_content.append("\\begin{document}")
    latex_content.append("\\maketitle")

    for elem in tree.any_xpath(".//tei:head"):
        text = "".join(elem.itertext()).strip().strip(".")
        latex_content.append(f"\\section*{{{text}}}")

    for p in tree.any_xpath(".//tei:text//tei:body//tei:div//tei:p"):
        paragraph_text = process_paragraph(p)
        if paragraph_text:
            latex_content.append(paragraph_text)



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
