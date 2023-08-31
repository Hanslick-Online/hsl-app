import glob
import os
import time
import datetime

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


def get_entities(ent_type, ent_node, ent_name):
    entities = []
    e_path = f'.//tei:rs[@type="{ent_type}"]/@ref'
    for p in body:
        ent = p.xpath(e_path,
                      namespaces={'tei': "http://www.tei-c.org/ns/1.0"})
        ref = [ref.replace("#", "")
               for e in ent if len(ent) > 0 for ref in e.split()]
        for r in ref:
            p_path = f'.//tei:{ent_node}[@xml:id="{r}"]//tei:{ent_name}[1]'
            en = doc.any_xpath(p_path)
            if en:
                entity = " ".join(" ".join(en[0].xpath(".//text()")).split())
                if len(entity) != 0:
                    entities.append(entity)
                else:
                    with open("log-entities.txt", "a") as f:
                        f.write(f"{r} in {record['id']}\n")
    return [ent for ent in sorted(set(entities))]


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
            p_group = f".//tei:body/tei:div[{pages}]/tei:p"
            body = doc.any_xpath(p_group)
            cfts_record = {
                'project': 'hsl',
            }
            record = {}
            anchor_id_1 = os.path.split(x)[-1]
            anchor_id_2 = ".html#index.xml-body.1_div."
            record['id'] = anchor_id_1.replace('.xml',
                                               f"{anchor_id_2}{str(pages)}")
            cfts_record['id'] = record['id']
            hsl_url = "https://hanslick.acdh.oeaw.ac.at"
            cfts_record['resolver'] = f"{hsl_url}/{record['id']}"
            record['rec_id'] = os.path.split(x)[-1]
            cfts_record['rec_id'] = record['rec_id']
            r_title = " ".join(
                " ".join(doc.any_xpath(
                        './/tei:titleStmt/tei:title[@type="main"]/text()')
                        ).split())
            s_title = doc.any_xpath('.//tei:sourceDesc//tei:edition/@n')[0]
            title = f"{r_title} {s_title}. Auflage"
            if pages - 1 == 0:
                cht = "Vorwort"
            else:
                cht = f"Kapitel {str(pages - 1)}"
            record['title'] = f"{title} - {cht}"
            cfts_record['title'] = record['title']
            try:
                date_str = doc.any_xpath('//tei:sourceDesc//tei:date/@when')[0]
                date_seq = f"{date_str}-0{str(pages)}-01"
                date_seq = time.mktime(datetime.datetime.strptime(date_seq,
                                                                  "%Y-%m-%d"
                                                                  ).timetuple()
                                       )
            except IndexError:
                try:
                    date_str = doc.any_xpath(
                        '//tei:sourceDesc//tei:date/text()')[0]
                except IndexError:
                    date_str = "0"
            if len(date_str) > 3:
                date_str = date_str
                date_seq = date_seq
            else:
                date_str = "1854"

            try:
                record['year'] = int(date_str[:4])
                record['date'] = int(date_seq)
                cfts_record['year'] = int(date_str[:4])
            except ValueError:
                pass

            if len(body) > 0:
                # get unique persons per page
                ent_type = "person"
                ent_name = "persName"
                record['persons'] = get_entities(ent_type=ent_type,
                                                 ent_node=ent_type,
                                                 ent_name=ent_name)
                cfts_record['persons'] = record['persons']
                # get unique places per page
                ent_type = "place"
                ent_name = "placeName"
                record['places'] = get_entities(ent_type=ent_type,
                                                ent_node=ent_type,
                                                ent_name=ent_name)
                cfts_record['places'] = record['places']
                # get unique bibls per page
                ent_type = "bibl"
                ent_name = "title"
                record['works'] = get_entities(ent_type=ent_type,
                                               ent_node=ent_type,
                                               ent_name=ent_name)
                cfts_record['works'] = record['works']
                record['full_text'] = "\n".join(" ".join("".join(
                    p.itertext()).split()) for p in body)
                if len(record['full_text']) > 0:
                    records.append(record)
                    cfts_record['full_text'] = record['full_text']
                    cfts_records.append(cfts_record)
    # index for critics edition
    if 'critics' in x:
        pages = 0
        for v in facs:
            pages += 1
            p_group = f".//tei:body/tei:div[{pages}]"
            body = doc.any_xpath(p_group)
            body_str = doc.any_xpath(p_group)[0].text
            cfts_record = {
                'project': 'hsl',
            }
            record = {}
            record['id'] = os.path.split(x)[-1].replace('.xml', ".html")
            cfts_record['id'] = record['id']
            hsl_url_dev = "https://hanslick-online.github.io/hsl-app-dev"
            # hsl_url = "https://hanslick.acdh.oeaw.ac.at"
            cfts_record['resolver'] = f"{hsl_url_dev}/{record['id']}"
            record['rec_id'] = os.path.split(x)[-1]
            cfts_record['rec_id'] = record['rec_id']
            r_title = " ".join(" ".join(
                doc.any_xpath('.//tei:titleStmt/tei:title[@level="a"]/text()')
            ).split())
            s_title = doc.any_xpath(
                './/tei:titleStmt/tei:title[@level="s"]/text()')[0]
            title = f"{r_title} {s_title}"
            record['title'] = title
            cfts_record['title'] = record['title']
            try:
                date_str = doc.any_xpath('//tei:sourceDesc//tei:date/@when')[0]
                if len(date_str) == 4:
                    date_str = f"{date_str}-01-01"
                date_seq = time.mktime(datetime.datetime.strptime(date_str,
                                                                  "%Y-%m-%d")
                                       .timetuple())
            except IndexError:
                date_str = "0000-00-00"
                date_seq = "0000-00-00"

            try:
                record['year'] = int(date_str[:4])
                record['date'] = int(date_seq)
                cfts_record['year'] = int(date_str[:4])
            except ValueError:
                pass

            if len(body) > 0:
                # get unique persons per page
                ent_type = "person"
                ent_name = "persName"
                record['persons'] = get_entities(ent_type=ent_type,
                                                 ent_node=ent_type,
                                                 ent_name=ent_name)
                cfts_record['persons'] = record['persons']
                # get unique places per page
                ent_type = "place"
                ent_name = "placeName"
                record['places'] = get_entities(ent_type=ent_type,
                                                ent_node=ent_type,
                                                ent_name=ent_name)
                cfts_record['places'] = record['places']
                # get unique bibls per page
                ent_type = "bibl"
                ent_name = "title"
                record['works'] = get_entities(ent_type=ent_type,
                                               ent_node=ent_type,
                                               ent_name=ent_name)
                cfts_record['works'] = record['works']
                record['full_text'] = "\n".join(" ".join(
                    "".join(p).split()) for p in body_str)
                if len(record['full_text']) > 0:
                    records.append(record)
                    cfts_record['full_text'] = record['full_text']
                    cfts_records.append(cfts_record)

make_index = client.collections['hsl'].documents.import_(records)
print(make_index)
print('done with indexing hsl')

make_index = CFTS_COLLECTION.documents.import_(cfts_records,
                                               {'action': 'upsert'})
print(make_index)
print('done with cfts-index hsl')
