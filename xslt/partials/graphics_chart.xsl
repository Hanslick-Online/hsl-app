<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:graphics"
    version="2.0"
    exclude-result-prefixes="tei xsl xs local">

    <xsl:variable name="is-german" as="xs:boolean" select="exists(/tei:TEI/tei:text/tei:body[@xml:lang = 'de-AT'])"/>

    <xsl:function name="local:text" as="xs:string">
        <xsl:param name="de" as="xs:string"/>
        <xsl:param name="en" as="xs:string"/>
        <xsl:sequence select="if ($is-german) then $de else $en"/>
    </xsl:function>

    <xsl:function name="local:person-label" as="xs:string">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:sequence select="normalize-space(string-join((($person/tei:persName[@type='main'][1], $person/tei:persName[1])[1])//text(), ' '))"/>
    </xsl:function>

    <xsl:template name="meta_extra_head">
        <link rel="stylesheet" href="css/charts.css"/>
    </xsl:template>

    <xsl:template name="meta_extra_scripts">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
        <script type="text/javascript" src="js/graphics.js"></script>
    </xsl:template>

    <xsl:template name="chart_container">
        <section class="graphics-page">
            <div class="card shadow-sm graphics-panel">
                <div class="card-body p-4 p-lg-5">
                    <p class="graphics-intro">
                        <xsl:value-of select="local:text('Vergleichen Sie die jährlichen Häufigkeiten von Entitäten in den vier Korpora. Lassen Sie &quot;Gesamt&quot; aktiviert, um alle Korpora zusammen zu sehen, oder deaktivieren Sie es und wählen Sie gezielt ein oder mehrere Korpora.', 'Compare yearly entity frequencies across the four corpora. Keep &quot;Total&quot; enabled for all corpora together, or disable it and choose one or more corpora directly.')"/>
                    </p>
                    <div class="row g-4 align-items-start">
                        <div class="col-lg-4">
                            <div class="graphics-controls">
                                <div>
                                    <div class="graphics-section-title"><xsl:value-of select="local:text('Entitäten', 'Entities')"/></div>
                                    <label class="form-label" for="graphics-person-input"><xsl:value-of select="local:text('Bis zu fünf Entitäten hinzufügen', 'Add up to five entities')"/></label>
                                    <div class="graphics-add-row">
                                        <input id="graphics-person-input" class="form-control" type="text" list="graphics-person-options" placeholder="{local:text('Person eingeben', 'Start typing a person')}"/>
                                        <button id="graphics-add-person" class="btn btn-primary" type="button"><xsl:value-of select="local:text('Hinzufügen', 'Add')"/></button>
                                    </div>
                                    <div class="graphics-add-row mt-2">
                                        <input id="graphics-work-input" class="form-control" type="text" list="graphics-work-options" placeholder="{local:text('Werk eingeben', 'Start typing a work')}"/>
                                        <button id="graphics-add-work" class="btn btn-primary" type="button"><xsl:value-of select="local:text('Hinzufügen', 'Add')"/></button>
                                    </div>
                                    <div class="graphics-add-row mt-2">
                                        <input id="graphics-place-input" class="form-control" type="text" list="graphics-place-options" placeholder="{local:text('Ort eingeben', 'Start typing a place')}"/>
                                        <button id="graphics-add-place" class="btn btn-primary" type="button"><xsl:value-of select="local:text('Hinzufügen', 'Add')"/></button>
                                    </div>
                                </div>
                                <div>
                                    <div class="graphics-section-title"><xsl:value-of select="local:text('Ausgewählt', 'Selected')"/></div>
                                    <div id="graphics-selected-entities" class="graphics-selected-list"></div>
                                </div>
                                <div>
                                    <div class="graphics-section-title"><xsl:value-of select="local:text('Korpora', 'Corpora')"/></div>
                                    <div class="graphics-corpus-list">
                                        <label><input id="graphics-corpus-total" type="checkbox" checked="checked"/><xsl:value-of select="local:text('Gesamt', 'Total')"/></label>
                                        <label><input class="graphics-corpus-checkbox" data-corpus="traktat" type="checkbox" checked="checked"/>Traktat</label>
                                        <label><input class="graphics-corpus-checkbox" data-corpus="critics" type="checkbox" checked="checked"/><xsl:value-of select="local:text('Kritiken (NFP)', 'Critics (NFP)')"/></label>
                                        <label><input class="graphics-corpus-checkbox" data-corpus="vms" type="checkbox" checked="checked"/><xsl:value-of select="local:text('VMS-Rezensionen', 'VMS Reviews')"/></label>
                                        <label><input class="graphics-corpus-checkbox" data-corpus="documents" type="checkbox" checked="checked"/><xsl:value-of select="local:text('Dokumente', 'Documents')"/></label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-8">
                            <div class="d-flex justify-content-end mb-2">
                                <button id="graphics-reset-zoom" class="btn btn-sm btn-outline-secondary" type="button"><xsl:value-of select="local:text('Zoom zurücksetzen', 'Reset zoom')"/></button>
                            </div>
                            <div class="graphics-chart-shell">
                                <canvas id="graphics-chart"></canvas>
                            </div>
                            <div id="graphics-legend" class="graphics-legend-list mt-3"></div>
                            <div id="graphics-status" class="graphics-status mt-3 small text-muted"><xsl:value-of select="local:text('Wählen Sie mindestens eine Entität aus, um das Diagramm anzuzeigen.', 'Select at least one entity to draw the chart.')"/></div>
                        </div>
                    </div>
                </div>
            </div>

            <datalist id="graphics-person-options"></datalist>
            <datalist id="graphics-work-options"></datalist>
            <datalist id="graphics-place-options"></datalist>

            <div id="graphics-data" class="d-none"
                data-source="data/graphics-chart-data.json"
                data-label-traktat="Traktat"
                data-label-critics="{local:text('Kritiken (NFP)', 'Critics (NFP)')}"
                data-label-vms="{local:text('VMS-Rezensionen', 'VMS Reviews')}"
                data-label-documents="{local:text('Dokumente', 'Documents')}"
                data-type-person="Person"
                data-type-work="{local:text('Werk', 'Work')}"
                data-type-place="{local:text('Ort', 'Place')}"
                data-remove-aria-label="{local:text('Entfernen: {label}', 'Remove {label}')}"
                data-tooltip-year="{local:text('Jahr {year}', 'Year {year}')}"
                data-axis-year="{local:text('Jahr', 'Year')}"
                data-axis-frequency="{local:text('Häufigkeit', 'Frequency')}"
                data-status-loading="{local:text('Lade Diagrammdaten…', 'Loading chart data...')}"
                data-status-load-error="{local:text('Diagrammdaten konnten nicht geladen werden.', 'Chart data could not be loaded.')}"
                data-status-empty="{local:text('Wählen Sie mindestens eine Entität aus, um das Diagramm anzuzeigen.', 'Select at least one entity to draw the chart.')}"
                data-status-no-corpora="{local:text('Aktivieren Sie mindestens ein Korpus oder schalten Sie &quot;Gesamt&quot; wieder ein.', 'Enable at least one corpus or switch Total back on.')}"
                data-status-total-singular="{local:text('Zeige {count} Entität über alle Korpora zusammen.', 'Showing {count} entity across all corpora together.')}"
                data-status-total-plural="{local:text('Zeige {count} Entitäten über alle Korpora zusammen.', 'Showing {count} entities across all corpora together.')}"
                data-status-filtered-singular="{local:text('Zeige {count} Entität für {corpora}.', 'Showing {count} entity for {corpora}.')}"
                data-status-filtered-plural="{local:text('Zeige {count} Entitäten für {corpora}.', 'Showing {count} entities for {corpora}.')}"
                data-error-invalid-entity="{local:text('Wählen Sie vor dem Hinzufügen einen Eintrag aus der Vorschlagsliste aus.', 'Choose an entry from the suggestion list before adding it.')}"
                data-error-duplicate="{local:text('{label} ist bereits ausgewählt.', '{label} is already selected.')}"
                data-error-max="{local:text('Sie können bis zu {max} Entitäten gleichzeitig vergleichen.', 'You can compare up to {max} entities at once.')}">
            </div>
        </section>
    </xsl:template>
</xsl:stylesheet>
