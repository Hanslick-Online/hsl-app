[![Build and publish](https://github.com/Hanslick-Online/hsl-app/actions/workflows/build.yml/badge.svg)](https://github.com/Hanslick-Online/hsl-app/actions/workflows/build.yml) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7825053.svg)](https://doi.org/10.5281/zenodo.7825053)

# Digital Scholarly Edition Hanslick Online

## Ordnerstruktur

### HTML

Enthält u.a. statische Dateien wie Stylesheets (CSS), Bilder, JavaScript (JS).

### XSLT

Enthält XSL Stylesheets für XML -> HTML Serialisierung.

## Graphics Chart JSON

Die Chart-Seite verwendet externe Daten aus einer JSON-Datei statt eingebetteter Entity-Daten im HTML.

- Generator-Skript: [build_app/python/generate_graphics_json.py](build_app/python/generate_graphics_json.py)
- Ausgabe-Datei: [html/data/graphics-chart-data.json](html/data/graphics-chart-data.json)

Manuell ausführen:

```bash
python3 build_app/python/generate_graphics_json.py \
	--person-index data/indices/listperson.xml \
	--work-index data/indices/listbibl.xml \
	--place-index data/indices/listplace.xml \
	--out html/data/graphics-chart-data.json
```

Beim Ant-Build wird das Skript automatisch vor der Serialisierung von [data/meta/g_chart.xml](data/meta/g_chart.xml) ausgeführt.

## Person Network JSON

Die Netzwerk-Seite verwendet externe Daten aus einer JSON-Datei, die per Python-Skript erzeugt wird.

- Generator-Skript: [build_app/python/generate_network_json.py](build_app/python/generate_network_json.py) (`person`-Modus)
- Ausgabe-Datei: [html/person-network-data.json](html/person-network-data.json)

Manuell ausführen:

```bash
python3 build_app/python/generate_network_json.py --network person \
	--person-index data/indices/listperson.xml \
	--doc-editions-dir data/doc/editions \
	--out html/person-network-data.json
```

## VMS Network JSON

Der VMS-Beziehungsgraph verwendet externe Daten aus einer eigenen JSON-Datei.

- Generator-Skript: [build_app/python/generate_network_json.py](build_app/python/generate_network_json.py) (`vms`-Modus)
- Ausgabe-Datei: [html/data/vms-network-data.json](html/data/vms-network-data.json)

Manuell ausführen:

```bash
python3 build_app/python/generate_network_json.py --network vms \
	--person-index data/indices/listperson.xml \
	--work-index data/indices/listbibl.xml \
	--traktat-editions-dir data/traktat/editions \
	--out html/data/vms-network-data.json
```

Standardverhalten (ohne `--network`): beide JSON-Dateien werden erzeugt.

