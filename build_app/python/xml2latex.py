#!/usr/bin/env python
from acdh_tei_pyutils.tei import ET
import sys
import re
ns = {'tei': 'http://www.tei-c.org/ns/1.0', 'xml': "http://www.w3.org/XML/1998/namespace"}

biblinfo = {'t': ['Eduard Hanslick, \\emph{Vom Musikalisch-Schönen: Ein Beitrag zur Revision der Ästhetik der Tonkunst}',
                  'Alexander Wilfing', 'Daniel Elsner und Meike Wilfing-Albrecht', '2023'],
            'c': ['\\emph{Eduard Hanslicks Schriften für die „Neue Freie Presse“}',
                  'Alexander Wilfing',
                  'Katharina Bamer, Daniel Elsner, Anna-Maria Pfiel und Fernando Sanz-Lázaro', '2023–2026'],
            'v': ['\\emph{Die Rezensionen zu Eduard Hanslicks „Vom Musikalisch-Schönen“ (1854–1857)}',
                  'Alexander Wilfing und Anna-Maria Pfiel', 'Daniel Elsner und Fernando Sanz-Lázaro', '2024–2025'],
            'd': ['\\emph{Dokumente zu Eduard Hanslicks „Vom Musikalisch-Schönen}',
                  'Alexander Wilfing und Meike Wilfing-Albrecht', 'Fernando Sanz-Lázaro',  '2025']
            }


def make_bibl(title, hsrg, mitarbeiter, year):
    return f"{title}, hrsg. von {hsrg} unter Mitarbeit von {mitarbeiter} (Wien: ACDH. {year})."


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
    text = re.sub(r"\s+", " ", text.strip())
    for i in ("_", "&"):
        text = text.replace(i, rf"\{i}")
    return text.replace("„ ", "„").replace(" “", "“").replace(" ,", ",").replace(" ’", "’")


def process_paragraph(element):
    """
    Processes a paragraph element to combine all text, adding spaces where needed,
    and handle <lb>, <cb>, and inline elements properly.
    """
    result = []
    skip_space = False
    for node in element.iter():
        text = ""
        tail = ""
        tag = node.tag.split("}")[-1]  # remove namespace if present
        # Handle line or column breaks

        if tag in {"lb", "cb", "pb"}:
            if node.attrib.get("break") == "no":
                skip_space = True
        text = ""
        # Add the current node's text content
        if node.text:
            text = node.text.strip() if node.text else ""
            if (tag == "hi" and node.attrib.get("rendition") == "#em") or tag == "emph":
                text = "\\textit{" + text + "}"
                # result.append("\\textit{" + text + "}")
        if node.tail and node.tail.strip():
            tail = re.sub(r"\s+", " ", node.tail)
            if tail == " ":
                tail = ""
        if skip_space and result:
            result[-1] += text + tail
            skip_space = False
        else:
            result.append(text + tail)
    spacing = "" if element.attrib.get("prev") == "true" else "\n\n"
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


def make_body(tree, document_type):
    text = ""
    chapters = tree.xpath(".//tei:text//tei:body//tei:div", namespaces=ns)
    for chapter in chapters:
        head = chapter.xpath("./tei:head", namespaces=ns)
        if head:
            head = process_paragraph(head[0]).strip()
            if len(head) > 80:
                short = head[:-79]
            else:
                short = ""
            text += section(document_type, head, short) + "\n"

        paragraphs = chapter.xpath("./tei:p", namespaces=ns)
        for p in paragraphs:
            paragraph_text = process_paragraph(p)
            if paragraph_text:
                text += paragraph_text
    return text


def make_front(front):
    def _norm_ws(s: str) -> str:
        return re.sub(r"\s+", " ", s).strip()

    title_nodes = front.xpath(".//tei:titlePage//tei:docTitle/tei:titlePart[@type='main']", namespaces=ns)
    title = clean_text(_norm_ws(" ".join("".join(n.itertext()) for n in title_nodes)))

    subtitle_nodes = front.xpath(".//tei:titlePage//tei:docTitle/tei:titlePart[@type='sub']", namespaces=ns)
    subtitles = [
        clean_text(_norm_ws("".join(n.itertext())))
        for n in subtitle_nodes
        if _norm_ws("".join(n.itertext()))
    ]

    bylines = [
        clean_text(_norm_ws("".join(byline.itertext())))
        for byline in front.xpath(".//tei:titlePage//tei:byline", namespaces=ns)
        if _norm_ws("".join(byline.itertext()))
    ]

    imprints = [
        clean_text(_norm_ws("".join(imprint.itertext())))
        for imprint in front.xpath(".//tei:titlePage//tei:docImprint", namespaces=ns)
        if _norm_ws("".join(imprint.itertext()))
    ]

    edition_nodes = front.xpath(".//tei:titlePage//tei:docEdition", namespaces=ns)
    edition = clean_text(_norm_ws(" ".join("".join(n.itertext()) for n in edition_nodes)))

    tei_root = front.getroottree().getroot()
    tei_xml_id = tei_root.attrib.get(f"{{{ns['xml']}}}id", "")
    i = tei_xml_id[:1].lower()
    if i not in biblinfo:
        raise ValueError(
            f"Unexpected TEI xml:id '{tei_xml_id}'. "
            f"Expected first character to be one of {sorted(biblinfo.keys())}."
        )

    bibl = make_bibl(*biblinfo[i])
    text = f"""\\frontmatter
        \\thispagestyle{{empty}}\\noindent {bibl}\\vspace{{.2\\textheight}}
        \\begin{{center}}
        {{\\Huge\\textbf{{{title.strip('.')}}}}}\\vspace{{.05\\textheight}}

        """
    if subtitles:
        text += "{\\LARGE\\textbf{" + ' '.join(subtitles).strip('.') + "}}\\vspace{.1\\textheight}\n\n"
    if bylines:
        text += "{\\large " + ' '.join(bylines).strip('.') + "}\n\\vfill\n\n"
    if edition:
        text += "{\\small " + edition.strip('.') + "}\n\\vfill\n\n"
    if imprints:
        text += "\n\n".join(imprints).strip('.')
    return text + "\\end{center}\\clearpage\n\\mainmatter\n"


def section(document, text, shorttext=""):
    if shorttext:
        shorttext = f"[{shorttext}]"
    if document == "book":
        section = "chapter"
    else:
        section = "section"
    return f"\n\n\\{section}{shorttext}" + "{" + text + "}"


def transform_tei_to_latex(input_file, output_file):
    # Parse the XML-TEI file
    with open(input_file, "r", encoding="utf-8") as f:
        xml_text = f.read()
    fixed_xml_text = fix_invalid_xml_id(xml_text)

    tree = ET.fromstring(fixed_xml_text.encode("utf-8"))
    # tree = TeiReader(input_file)

    Titles, Author, Date, Editors = get_info(tree)
    front = tree.xpath(".//tei:text//tei:front", namespaces=ns)
    has_title_page = bool(tree.xpath(".//tei:text//tei:front//tei:titlePage", namespaces=ns))
    document_type = "book" if has_title_page else "article"

    # Example: Extracting some TEI elements and converting to LaTeX
    Title = ""
    if Titles:
        #  Fix title
        Titles = [clean_text(i) for i in Titles if len(clean_text(i)) > 0]
        Title = Titles[0]
        if Titles[1:]:
            Subtitle = "\\\\".join([f"\\Large{{{title}}}" for title in Titles[1:] if title.strip()])
            Title = "\\\\".join([Title, Subtitle])
        if Editors:
            Title = "\\\\".join([Title, f"\\large{{Herausgegeben von {Editors}}}"])
    latex_content = []
    latex_content.append(f"\\documentclass[a4paper]{{{document_type}}}")
    latex_content.append("\\usepackage{polyglossia}")
    latex_content.append("\\setmainlanguage[variant=austrian]{german}")
    latex_content.append("\\usepackage{tracklang}")
    # latex_content.append("\\usepackage[austrian]{babel}")
    latex_content.append("\\usepackage{fontspec,xltxtra,xunicode}")
    latex_content.append("\\usepackage{microtype}")
    latex_content.append("\\usepackage{geometry}")
    latex_content.append("\\usepackage[pagestyles]{titlesec}")
    latex_content.append("\\titleformat{\\chapter}[display]{\\normalfont\\bfseries}{}{0pt}{\\Large}")
    latex_content.append("\\usepackage[de-AT]{datetime2}")
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
    if document_type == "book" and front:
        latex_content.append(make_front(front[0]))
    else:
        latex_content.append("\\maketitle")
    latex_content.append(make_body(tree, document_type))

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
