import glob
import os
import re
import time
import datetime
from urllib.parse import quote

from typesense.api_call import ObjectNotFound
from acdh_cfts_pyutils import TYPESENSE_CLIENT as client
from acdh_cfts_pyutils import CFTS_COLLECTION
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm


files = glob.glob('./data/*/editions/*.xml')


try:
    client.collections['hsl'].delete()
except ObjectNotFound:
    pass

current_schema = {
    'name': 'hsl',
    'fields': [
        {
            'name': 'id',
            'type': 'string'
        },
        {
            'name': 'rec_id',
            'type': 'string'
        },
        {
            'name': 'title',
            'type': 'string'
        },
        {
            'name': 'full_text',
            'type': 'string'
        },
        {
            'name': 'edition',
            'type': 'string[]',
            'optional': True,
            'facet': True,
        },
        {
            'name': 'year',
            'type': 'int32',
            'optional': True,
            'facet': True,
        },
        {
            'name': 'date',
            'type': 'int32',
            'optional': True,
            'facet': True,
        },
        {
            'name': 'persons',
            'type': 'string[]',
            'facet': True,
            'optional': True
        },
        {
            'name': 'places',
            'type': 'string[]',
            'facet': True,
            'optional': True
        },
        {
            'name': 'works',
            'type': 'string[]',
            'facet': True,
            'optional': True
        }
    ]
}

client.collections.create(current_schema)


XML_NS = {'tei': "http://www.tei-c.org/ns/1.0"}
XML_ID = '{http://www.w3.org/XML/1998/namespace}id'
TRACTAT_FILENAME_PATTERN = re.compile(r'^t__(\d{2})_VMS_(\d{4})_.*\.xml$')


def tractat_html_filename(base_id: str) -> str:
    """Return the published HTML filename for a Traktat TEI file."""
    match = TRACTAT_FILENAME_PATTERN.match(base_id)
    if match:
        edition, year = match.groups()
        return f"t__VMS_Auflage_{edition}_{year}.html"
    # Fallback: mimic previous behaviour for unexpected filenames
    return base_id.replace('.xml', '.html')


def get_entities(paragraph_nodes, ent_type, ent_node, ent_name, record_id):
    entities = []
    e_path = f'.//tei:rs[@type="{ent_type}"]/@ref'
    for p_node in paragraph_nodes:
        ent = p_node.xpath(e_path, namespaces=XML_NS)
        ref = [ref.replace('#', '')
               for e in ent if len(ent) > 0 for ref in e.split()]
        for r in ref:
            p_path = f'.//tei:{ent_node}[@xml:id="{r}"]//tei:{ent_name}[1]'
            en = doc.any_xpath(p_path)
            if en:
                entity = " ".join(" ".join(en[0].xpath('.//text()')).split())
                if len(entity) != 0:
                    entities.append(entity)
                else:
                    with open("log-entities.txt", "a") as f:
                        f.write(f"{r} in {record_id}\n")
    return [ent for ent in sorted(set(entities))]


def handle_entities(paragraph_nodes, record, cfts_record):
    if len(paragraph_nodes) > 0:
        record_id = record.get('id', 'unknown')
        record['persons'] = get_entities(paragraph_nodes=paragraph_nodes,
                                         ent_type="person",
                                         ent_node="person",
                                         ent_name="persName",
                                         record_id=record_id)
        cfts_record['persons'] = record['persons']
        record['places'] = get_entities(paragraph_nodes=paragraph_nodes,
                                        ent_type="place",
                                        ent_node="place",
                                        ent_name="placeName",
                                        record_id=record_id)
        cfts_record['places'] = record['places']
        record['works'] = get_entities(paragraph_nodes=paragraph_nodes,
                                       ent_type="bibl",
                                       ent_node="bibl",
                                       ent_name="title",
                                       record_id=record_id)
        cfts_record['works'] = record['works']
        record['full_text'] = "\n".join(
            " ".join("".join(p.itertext()).split()) for p in paragraph_nodes)
        if len(record['full_text']) > 0:
            records.append(record)
            cfts_record['full_text'] = record['full_text']
            cfts_records.append(cfts_record)


def critic_anchor(paragraph, html_filename):
    para_idx = int(paragraph.xpath('count(preceding::tei:p)',
                                   namespaces=XML_NS)) + 1
    lb_nodes = paragraph.xpath('.//tei:lb', namespaces=XML_NS)
    if lb_nodes:
        first_lb = lb_nodes[0]
        line_idx = int(first_lb.xpath('count(preceding::tei:lb)',
                                      namespaces=XML_NS)) + 1
    else:
        line_idx = 1
    div_id = paragraph.xpath('ancestor::tei:div[1]/@xml:id',
                             namespaces=XML_NS)
    prefix = div_id[0] if div_id else os.path.splitext(html_filename)[0]
    anchor = f"{prefix}__p{para_idx}__lb{line_idx}"
    return f"{html_filename}#{anchor}", anchor


def traktat_anchor(paragraph, html_filename):
    xml_id = paragraph.get(XML_ID)
    if xml_id:
        return f"{html_filename}#{xml_id}", xml_id
    para_text = " ".join("".join(paragraph.itertext()).split())
    if para_text:
        fragment = quote(para_text[:80])
        return f"{html_filename}#:~:text={fragment}", fragment
    return html_filename, os.path.splitext(html_filename)[0]


def vms_anchor(paragraph, html_filename):
    xml_id = paragraph.get(XML_ID)
    if xml_id:
        return f"{html_filename}#{xml_id}", xml_id
    para_text = " ".join("".join(paragraph.itertext()).split())
    if para_text:
        fragment = quote(para_text[:80])
        return f"{html_filename}#:~:text={fragment}", fragment
    return html_filename, os.path.splitext(html_filename)[0]


records = []
cfts_records = []
for x in tqdm(files, total=len(files)):
    doc = TeiReader(xml=x)
    facs = doc.any_xpath('.//tei:body/tei:div')
    # index for critics edition
    if 'traktat' in x:
        pages = 0
        for v in facs:
            pages += 1
            paragraph_nodes = v.xpath('.//tei:p', namespaces=XML_NS)
            if not paragraph_nodes:
                continue
            base_id = os.path.split(x)[-1]
            html_filename = tractat_html_filename(base_id)
            cfts_record_template = {
                'project': 'hsl',
            }
            r_title = " ".join(
                " ".join(doc.any_xpath(
                    './/tei:titleStmt/tei:title[@type="main"]/text()')).split())
            s_title = doc.any_xpath('.//tei:sourceDesc//tei:edition/@n')[0]
            title = f"{r_title} {s_title}. Auflage"
            if pages - 1 == 0:
                chapter_label = "Vorwort"
            else:
                chapter_label = f"Kapitel {str(pages - 1)}"
            date_str = "1854"
            date_seq = 0
            try:
                date_candidate = doc.any_xpath(
                    '//tei:sourceDesc//tei:date/@when')[0]
                date_str = date_candidate
                composed = f"{date_candidate}-0{str(pages)}-01"
                date_dt = datetime.datetime.strptime(composed, "%Y-%m-%d")
            except (IndexError, ValueError):
                try:
                    date_candidate = doc.any_xpath(
                        '//tei:sourceDesc//tei:date/text()')[0]
                    date_str = date_candidate
                    date_dt = datetime.datetime.strptime(
                        date_candidate, "%Y-%m-%d")
                except (IndexError, ValueError):
                    try:
                        year_val = int(date_str[:4])
                    except ValueError:
                        year_val = 1854
                    date_dt = datetime.datetime(year_val, 1, 1)
            date_seq = int(time.mktime(date_dt.timetuple()))
            year_value = date_dt.year
            hsl_url = "https://hanslick.acdh.oeaw.ac.at"
            for para_idx, para in enumerate(paragraph_nodes, start=1):
                html_id, anchor_id = traktat_anchor(para, html_filename)
                record = {
                    'edition': ["Treatise/Traktat"],
                    'id': html_id,
                    'rec_id': f"{base_id}#{anchor_id}",
                    'title': f"{title} - {chapter_label}",
                }
                cfts_record = cfts_record_template.copy()
                cfts_record['id'] = record['id']
                cfts_record['resolver'] = f"{hsl_url}/{record['id']}"
                cfts_record['rec_id'] = record['rec_id']
                para_label = para.get('n')
                if para_label:
                    record['title'] = f"{record['title']} (§ {para_label})"
                cfts_record['title'] = record['title']
                record['year'] = year_value
                record['date'] = date_seq
                cfts_record['year'] = year_value
                handle_entities([para], record, cfts_record)

    # index for critics edition
    if 'critics' in x:
        paragraphs = doc.any_xpath('.//tei:body//tei:p')
        if not paragraphs:
            continue
        base_id = os.path.split(x)[-1]
        html_filename = base_id.replace('.xml', '.html')
        r_title = " ".join(" ".join(
            doc.any_xpath('.//tei:titleStmt/tei:title[@level="a"]/text()')
        ).split())
        s_title = doc.any_xpath(
            './/tei:titleStmt/tei:title[@level="s"]/text()')[0]
        title = f"{r_title} {s_title}"
        try:
            date_str = doc.any_xpath('//tei:sourceDesc//tei:date/@when')[0]
            if len(date_str) == 4:
                date_str = f"{date_str}-01-01"
            date_seq = time.mktime(datetime.datetime.strptime(
                date_str, "%Y-%m-%d").timetuple())
        except IndexError:
            date_str = "0000-00-00"
            date_seq = 0
        hsl_url = "https://hanslick.acdh.oeaw.ac.at"
        for para in paragraphs:
            html_id, anchor_id = critic_anchor(para, html_filename)
            record = {
                'edition': ["Reviews/Kritiken"],
                'id': html_id,
                'rec_id': f"{base_id}#{anchor_id}",
                'title': title,
            }
            cfts_record = {
                'project': 'hsl',
                'id': record['id'],
                'resolver': f"{hsl_url}/{record['id']}",
                'rec_id': record['rec_id'],
                'title': record['title'],
            }
            try:
                record['year'] = int(date_str[:4])
                record['date'] = int(date_seq)
                cfts_record['year'] = int(date_str[:4])
            except ValueError:
                pass
            handle_entities([para], record, cfts_record)

    # index for vms edition
    if 'vms' in x:
        paragraphs = doc.any_xpath('.//tei:body//tei:p')
        if not paragraphs:
            continue
        base_id = os.path.split(x)[-1]
        html_filename = base_id.replace('.xml', '.html')
        r_title = " ".join(" ".join(
            doc.any_xpath('.//tei:titleStmt/tei:title[@level="a"]/text()')
        ).split())
        s_title = doc.any_xpath(
            './/tei:titleStmt/tei:title[@level="s"]/text()')[0]
        title = f"{r_title} {s_title}"
        try:
            date_str = doc.any_xpath('//tei:sourceDesc//tei:date/@when')[0].strip()
            if len(date_str) == 4:
                date_str = f"{date_str}-01-01"
            elif len(date_str) == 7:
                date_str = f"{date_str}-01"
            date_seq = time.mktime(datetime.datetime.strptime(
                date_str, "%Y-%m-%d").timetuple())
        except IndexError:
            date_str = "0000-00-00"
            date_seq = 0
        hsl_url = "https://hanslick-online.github.io/hsl-app-dev"
        for para in paragraphs:
            html_id, anchor_id = vms_anchor(para, html_filename)
            record = {
                'edition': ["Reviews/Kritiken: VMS"],
                'id': html_id,
                'rec_id': f"{base_id}#{anchor_id}",
                'title': title,
            }
            cfts_record = {
                'project': 'hsl',
                'id': record['id'],
                'resolver': f"{hsl_url}/{record['id']}",
                'rec_id': record['rec_id'],
                'title': record['title'],
            }
            try:
                record['year'] = int(date_str[:4])
                record['date'] = int(date_seq)
                cfts_record['year'] = int(date_str[:4])
            except ValueError:
                pass
            handle_entities([para], record, cfts_record)
    if 'doc' in x:
        for v in facs:
            paragraph_nodes = v.xpath('.//tei:p', namespaces=XML_NS)
            if not paragraph_nodes:
                continue
            base_id = os.path.split(x)[-1]
            html_filename = base_id.replace('.xml', '.html')
            hsl_url = "https://hanslick-online.github.io/hsl-vms-doc"
            r_title = " ".join(" ".join(
                doc.any_xpath('.//tei:titleStmt/tei:title[@level="a"]/text()')
            ).split())
            s_title = doc.any_xpath(
                './/tei:titleStmt/tei:title[@level="s"]/text()')[0]
            title = f"{r_title} {s_title}"
            try:
                date_str = doc.any_xpath('//tei:sourceDesc//tei:date/@when')[0].strip()
                if len(date_str) == 4:
                    date_str = f"{date_str}-01-01"
                elif len(date_str) == 7:
                    date_str = f"{date_str}-01"
                date_seq = time.mktime(datetime.datetime.strptime(
                    date_str, "%Y-%m-%d").timetuple())
            except IndexError:
                date_str = "0000-00-00"
                date_seq = 0
            for para in paragraph_nodes:
                html_id, anchor_id = vms_anchor(para, html_filename)
                record = {
                    'edition': ["Documents/Dokumente"],
                    'id': html_id,
                    'rec_id': f"{base_id}#{anchor_id}",
                    'title': title,
                }
                cfts_record = {
                    'project': 'hsl',
                    'id': record['id'],
                    'resolver': f"{hsl_url}/{record['id']}",
                    'rec_id': record['rec_id'],
                    'title': record['title'],
                }
                try:
                    record['year'] = int(date_str[:4])
                    record['date'] = int(date_seq)
                    cfts_record['year'] = int(date_str[:4])
                except ValueError:
                    pass
                handle_entities([para], record, cfts_record)


make_index = client.collections['hsl'].documents.import_(records)
print(make_index)
print('done with indexing hsl')

make_index = CFTS_COLLECTION.documents.import_(cfts_records,
                                               {'action': 'upsert'})
print(make_index)
print('done with cfts-index hsl')
