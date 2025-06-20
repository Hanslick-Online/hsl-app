#!/usr/bin/env python
from acdh_tei_pyutils.tei import ET
import sys
import re
ns = {'tei': 'http://www.tei-c.org/ns/1.0', 'xml': "http://www.w3.org/XML/1998/namespace"}


def fix_invalid_xml_id(xml_text):
    """ Fix invalid xml:id values that don't start with a letter or underscore """
    return re.sub(r'xml:id="([^a-zA-Z_])', r'xml:id="_\1', xml_text)


def make_name_list(names):
    names = [
        " ".join([n.strip() for n in name.split(",")][::-1])
        for name in list(dict.fromkeys(names))
    ]
    if len(names) > 1:
        names = ", ".join(names[:-1]) + " und " + names[-1]
    elif names:
        names = names[0]
    else:
        names = ""
    return names


def clean_text(text):
    return text.strip().replace("&", "\\&").replace("„ ", "„").replace(" “", "“").replace(" ,", ",").replace(" ’", "’")


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
            if node.text:
                result.append("\\textit{" + node.text.strip() + "}")
        elif node.text:
            result.append(node.text.strip())
        # Add the tail content after a child node
        if node.tail:
            result.append(node.tail.strip())
        if element.attrib.get("prev") == "true":
            spacing = ""
        else:
            spacing = "\n\n"
    return spacing + clean_text(" ".join(result))


def get_date(tree):
    date = tree.xpath(".//tei:monogr/tei:imprint/tei:date/@when", namespaces=ns)
    if date:
        date = date[0].split("-")
        for i in range(0, 3 - len(date)):
            date += [0]
    return date


def get_info(tree):
    if tree.xpath(".//tei:titleStmt/tei:title[@level='a']", namespaces=ns):
        titles = tree.xpath(".//tei:titleStmt/tei:title[@level='a']/text()", namespaces=ns)
        if tree.xpath(".//tei:titleStmt/tei:title[@level='s']", namespaces=ns):
            titles += tree.xpath(".//tei:titleStmt/tei:title[@level='s']/text()", namespaces=ns)
        if tree.xpath(".//tei:titleStmt/tei:title[@level='j']", namespaces=ns):
            titles += tree.xpath(".//tei:titleStmt/tei:title[@level='j']/text()", namespaces=ns)
    elif tree.xpath(".//tei:titleStmt/tei:title[@level='s']", namespaces=ns):
        titles = tree.xpath(".//tei:titleStmt/tei:title[@level='s']/text()", namespaces=ns)
        if tree.xpath(".//tei:titleStmt/tei:title[@level='j']", namespaces=ns):
            titles += tree.xpath(".//tei:titleStmt/tei:title[@level='j']/text()", namespaces=ns)
    else:
        titles = tree.xpath(".//tei:analytic/tei:title/text()", namespaces=ns) + tree.xpath(
            ".//tei:monogr/tei:title/text()", namespaces=ns)
    if tree.xpath(".//tei:titleStmt/tei:authors", namespaces=ns):
        authorsb = tree.xpath(".//tei:titleStmt/tei:authors/text()", namespaces=ns)
    else:
        authorsb = tree.xpath(".//tei:author", namespaces=ns)

    authors = []
    for elem in authorsb:
        if elem.text and elem.text.strip() and elem.text not in authors:
            authors.append(elem.text.strip())
    origdate = get_date(tree)
    origeditors = [
        elem.text
        for elem in tree.xpath(".//tei:monogr/tei:respStmt/tei:name", namespaces=ns)
        if elem.text
    ]
    return titles, make_name_list(authors), origdate, make_name_list(origeditors)


def make_body(tree, section):
    text = ""
    chapters = tree.xpath(".//tei:text//tei:body//tei:div", namespaces=ns)
    for chapter in chapters:
        head = chapter.xpath("./tei:head", namespaces=ns)
        if head:
            head = process_paragraph(head[0]).strip()
            text += section + head + "}\n"
        paragraphs = chapter.xpath("./tei:p", namespaces=ns)
        for p in paragraphs:
            paragraph_text = process_paragraph(p)
            if paragraph_text:
                text += paragraph_text
    return text


def make_front(front):
    title = ' '.join(front.xpath("//tei:docTitle/tei:titlePart[@type='main']/tei:title/text()", namespaces=ns))
    subtitles = front.xpath("//tei:docTitle/tei:titlePart[@type='sub']/tei:title/text()", namespaces=ns)
    bylines = ["".join(byline.itertext()).strip() for byline in front.xpath("//tei:byline", namespaces=ns)]
    imprints = [''.join(imprint.itertext()).strip() for imprint in front.xpath("//tei:docImprint", namespaces=ns)]
    edition = ' '.join(front.xpath("//tei:docEdition/text()", namespaces=ns))
    text = f"""\\frontmatter
        \\thispagestyle{{empty}}\\strut\\vspace{{.2\\textheight}}

        \\begin{{center}}
        {{\\Huge\\textbf{{{title}}}}}\\vspace{{.05\\textheight}}

        """
    if subtitles:
        text += "{\\LARGE\\textbf{" + ' '.join(subtitles) + "}}\\vspace{.1\\textheight}\n\n"
    if bylines:
        text += "{\\large " + ' '.join(bylines) + "}\n\\vfill\n\n"
    if edition:
        text += "{\\small " + edition + "}\n\\vfill\n\n"
    if imprints:
        text += "\n\n".join(imprints)
    return text + "\\end{center}\\clearpage\n\\mainmatter\n"


def transform_tei_to_latex(input_file, output_file):
    # Parse the XML-TEI file
    with open(input_file, "r", encoding="utf-8") as f:
        xml_text = f.read()
    fixed_xml_text = fix_invalid_xml_id(xml_text)

    tree = ET.fromstring(fixed_xml_text.encode("utf-8"))
    # tree = TeiReader(input_file)

    Titles, Author, Date, Editors = get_info(tree)
    if front := tree.xpath(".//tei:text//tei:front", namespaces=ns):
        document = "book"
        section = "\\chapter{"
    else:
        document = "article"
        section = "\\section{"

    # Example: Extracting some TEI elements and converting to LaTeX
    if Titles:
        Title = Titles[0]
        if Titles[1:]:
            Subtitle = "\\\\".join([f"\\Large{{{title}}}" for title in Titles[1:] if title.strip()])
            Title = f"{Title}\\\\{Subtitle}"
        if Editors:
            Title = f"{Title}\\\\\\large{{Herausgegeben von {Editors}}}"
    latex_content = []
    latex_content.append(f"\\documentclass[a4paper]{{{document}}}")
    latex_content.append("\\usepackage{polyglossia}")
    latex_content.append("\\setmainlanguage[variant=austrian]{german}")
    latex_content.append("\\usepackage{tracklang}")
    # latex_content.append("\\usepackage[austrian]{babel}")
    latex_content.append("\\usepackage{fontspec,xltxtra,xunicode}")
    latex_content.append("\\usepackage{microtype}")
    latex_content.append("\\usepackage{geometry}")
    latex_content.append("\\usepackage[pagestyles]{titlesec}")
    latex_content.append("\\titleformat{\\chapter}[display]{\\normalfont\\bfseries}{}{0pt}{\\Large}")
    latex_content.append("\\usepackage[useregional]{datetime2}")
    latex_content.append("\\geometry{left=35mm, right=35mm, top=35mm, bottom=35mm}")
    latex_content.append("\\setmainfont{Noto Serif}")
    latex_content.append(
        "\\newpagestyle{mystyle}{\\sethead[\\thepage][][\\chaptertitle]{}{}{\\thepage}}\\pagestyle{mystyle}")
    latex_content.append(f"\\title{{{Title}}}")
    latex_content.append(f"\\author{{{Author}}}")
    if Date[1] == 0:
        Date = Date[0]
    else:
        Date = f"\\DTMdisplaydate{{{Date[0]}}}{{{Date[1]}}}{{{Date[2]}}}" + "{gregorian}"
    latex_content.append(f"\\date{{{Date}}}")
    latex_content.append("\\begin{document}")
    if front := tree.xpath(".//tei:text//tei:front", namespaces=ns):
        latex_content.append(make_front(front[0]))
    else:
        latex_content.append("\\maketitle")
    latex_content.append(make_body(tree, section))

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
