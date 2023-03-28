import os
import pandas as pd
import glob
import tqdm
from lxml import etree as ET
from collections import defaultdict
from acdh_tei_pyutils.tei import TeiEnricher
from acdh_tei_pyutils.tei import TeiReader


NS = {
    "tei": "http://www.tei-c.org/ns/1.0",
    "xml": "http://www.w3.org/XML/1998/namespace",
}


files = os.path.join("data", "traktat", "editions", "t__01_VMS_1854_TEI_AW_26-01-21-TEI-P5.xml")
fNames = os.path.join("traktat-images", "1", "out.csv")


def get_df(fpath=None):
    """open df with filenames"""
    
    file = fpath
    df = pd.read_csv(file)
    return df


def facs_to_tei(fpath=None,fnames=None):
    """add facsimiles object to tei"""
    
    f = fpath
    df = get_df(fnames)
    print(f"START updating xml: {f}")
    doc = TeiReader(f)
    root_node = doc.tree.getroot()
    facs = ET.Element("{http://www.tei-c.org/ns/1.0}facsimile")
    for i, row in df.iterrows():
        surface = ET.Element("{http://www.tei-c.org/ns/1.0}surface")
        surface.attrib["ulx"] = "0"
        surface.attrib["uly"] = "0"
        surface.attrib["lrx"] = str(row["width"])
        surface.attrib["lry"] = str(row["height"])
        graphic = ET.Element("{http://www.tei-c.org/ns/1.0}graphic")
        graphic.attrib["url"] = f"https://iiif.acdh.oeaw.ac.at/hsl/{row['id']}"
        surface.append(graphic)
        facs.append(surface)
    root_node.insert(1, facs)
    doc.tree_to_file(file=f)
    print(f"FINISHED updating xml: {f}")


def create_mention_list(mentions, event_title="erwähnt in"):
        """ creates a tei elemen with list of mentions
        :param mentions: a list of dicts with keys `doc_uri` and `doc_title`
        :type mentions: list
        :param event_title: short description of the event, defaults to "erwähnt in"
        :type event_title: str
        :return: a etree.element
        """
        tei_ns = f"http://www.tei-c.org/ns/1.0"
        node_root = ET.Element(f"{{{tei_ns}}}listEvent")
        for x in mentions:
            event_node = ET.Element(f"{{{tei_ns}}}event")
            event_node.set('type', 'mentioned')
            event_p_node = ET.Element(f"{{{tei_ns}}}p")
            event_p_node.text = event_title
            title_node = ET.Element(f"{{{tei_ns}}}title")
            if x['doc_title_sub']:
                title_node.text = f"{x['doc_title']} ({x['doc_title_sub']})"
            else:
                title_node.text = x['doc_title']
            event_p_node.append(title_node)
            event_node.append(event_p_node)
            lnkgrp_node = ET.Element(f"{{{tei_ns}}}linkGrp")
            lnk_node = ET.Element(f"{{{tei_ns}}}link")
            lnk_node.set('type', 'ARCHE')
            lnk_node.set('target', x['doc_uri'])
            lnkgrp_node.append(lnk_node)
            event_node.append(lnkgrp_node)
            node_root.append(event_node)
        return node_root


def denormalize_indices(
    files, indices, mention_xpath, event_title, title_xpath, title_xpath_sub, blacklist_ids=[]
):  # pragma: no cover
    """Write pointers to mentions in index-docs and copy index entries into docs"""

    files = sorted(glob.glob(files))
    index_files = sorted(glob.glob(indices))
    ref_doc_dict = defaultdict(list)
    doc_ref_dict = defaultdict(list)
    print(f"collecting list of mentions from {len(files)} docs")
    for x in tqdm.tqdm(files):
        filename = os.path.split(x)[1]
        if "list" in filename:
            continue
        doc = TeiEnricher(x)
        doc_base = doc.any_xpath("./@xml:base")[0]
        doc_id = doc.any_xpath("./@xml:id")[0]
        doc_uri = f"{doc_base}/{doc_id}"
        doc_title = doc.any_xpath(title_xpath)[0]
        doc_title_sub = doc.any_xpath(title_xpath_sub)[0]
        refs = doc.any_xpath(mention_xpath)
        for ref in set(refs):
            if ref.startswith("#") and len(ref.split(" ")) == 1:
                ref = ref[1:]
            if ref.startswith("#") and len(ref.split(" ")) > 1:
                refs = ref.split(" ")
                ref = refs[0]
                ref = ref[1:]
                for r in refs[1:]:
                    ref_doc_dict[r[1:]].append(
                        {"doc_uri": doc_uri, "doc_path": x, "doc_title": doc_title, "doc_title_sub": doc_title_sub}
                    )
            ref_doc_dict[ref].append(
                {"doc_uri": doc_uri, "doc_path": x, "doc_title": doc_title, "doc_title_sub": doc_title_sub}
            )
            doc_ref_dict[filename].append(ref)

    print(f"collected {len(ref_doc_dict.keys())} of mentioned entities from {len(files)} docs")
    for x in index_files:
        doc = TeiEnricher(x)
        ent_nodes = doc.any_xpath(".//tei:body//*[@xml:id]")
        for ent in ent_nodes:
            ent_id = ent.xpath("@xml:id")[0]
            mention = ref_doc_dict[ent_id]
            if ent_id in blacklist_ids:
                continue
            event_list = create_mention_list(mention, event_title=event_title)            
            try:
                list(event_list[0])
                ent.append(event_list)
            except IndexError:
                pass
        doc.tree_to_file(file=x)

    all_ent_nodes = {}
    for x in index_files:
        doc = TeiEnricher(x)
        ent_nodes = doc.any_xpath(".//tei:body//*[@xml:id]")
        for ent in ent_nodes:
            all_ent_nodes[ent.xpath("@xml:id")[0]] = ent

    print(f"writing {len(all_ent_nodes)} index entries into {len(files)} files")
    for x in tqdm.tqdm(files):
        try:
            filename = os.path.split(x)[1]
            doc = TeiEnricher(x)
            root_node = doc.any_xpath(".//tei:text")[0]
            for bad in doc.any_xpath(".//tei:back"):
                bad.getparent().remove(bad)
            refs = doc.any_xpath(mention_xpath)
            ent_dict = defaultdict(list)
            for ref in set(refs):
                # print(ref, type(ref))
                if ref.startswith("#") and len(ref.split(" ")) == 1:
                    ent_id = ref[1:]
                elif ref.startswith("#") and len(ref.split(" ")) > 1:
                    refs = ref.split(" ")
                    ref = refs[0]
                    ent_id = ref[1:]
                    for r in refs[1:]:
                        try:
                            index_ent = all_ent_nodes[r[1:]]
                            ent_dict[index_ent.tag].append(index_ent)
                        except KeyError:
                            continue
                else:
                    ent_id = ref
                try:
                    index_ent = all_ent_nodes[ent_id]
                    ent_dict[index_ent.tag].append(index_ent)
                except KeyError:
                    continue
            back_node = ET.Element("{http://www.tei-c.org/ns/1.0}back")
            for key in ent_dict.keys():
                if key.endswith("person"):
                    list_person = ET.Element("{http://www.tei-c.org/ns/1.0}listPerson")
                    back_node.append(list_person)
                    for ent in ent_dict[key]:
                        list_person.append(ent)
                if key.endswith("place"):
                    list_place = ET.Element("{http://www.tei-c.org/ns/1.0}listPlace")
                    back_node.append(list_place)
                    for ent in ent_dict[key]:
                        list_place.append(ent)
                if key.endswith("org"):
                    list_org = ET.Element("{http://www.tei-c.org/ns/1.0}listOrg")
                    back_node.append(list_org)
                    for ent in ent_dict[key]:
                        list_org.append(ent)
                if key.endswith("bibl") or key.endswith("biblStruct"):
                    list_bibl = ET.Element("{http://www.tei-c.org/ns/1.0}listBibl")
                    back_node.append(list_bibl)
                    for ent in ent_dict[key]:
                        list_bibl.append(ent)
                if key.endswith("item"):
                    list_item = ET.Element("{http://www.tei-c.org/ns/1.0}list")
                    back_node.append(list_item)
                    for ent in ent_dict[key]:
                        list_item.append(ent)
                if key.endswith("event"):
                    list_eve = ET.Element("{http://www.tei-c.org/ns/1.0}listEvent")
                    back_node.append(list_eve)
                    for ent in ent_dict[key]:
                        list_eve.append(ent)
            root_node.append(back_node)
            doc.tree_to_file(file=x)
        except Exception as e:
            print(f"failed to process {x} due to {e}")
    print("DONE")
