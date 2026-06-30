<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:graphics"
    version="2.0"
    exclude-result-prefixes="tei xsl xs local">

    <xsl:template name="vms_chart_container">
        <section class="graphics-page">
            <div class="card shadow-sm graphics-panel">
                <div class="card-body p-4 p-lg-5">
                    <p class="graphics-intro">
                        <xsl:value-of select="local:text('Wählen Sie Entitäten und wechseln Sie zwischen Jahres- und Kapitelansicht. In der Kapitelansicht wird jede Kurve als Kombination aus Entität und Auflage hinzugefügt.', 'Select entities and switch between yearly and chapter views. In chapter view, each line is added as an entity + edition combination.')"/>
                    </p>
                    <div class="row g-4 align-items-start">
                        <div class="col-lg-4">
                            <div class="graphics-controls">
                                <div>
                                    <button id="graphics-view-toggle" class="btn btn-primary" type="button" data-mode="year">
                                        Kapitelansicht
                                    </button>
                                </div>
                                <div id="graphics-edition-wrap" class="d-none">
                                    <label class="form-label" for="graphics-edition-select"><xsl:value-of select="local:text('Für den nächsten Eintrag (Kapitelansicht)', 'For next entry (chapter view)')"/></label>
                                    <select id="graphics-edition-select" class="form-select"></select>
                                </div>
                                <div>
                                    <label class="form-label" for="graphics-person-input"><xsl:value-of select="local:text('Bis zu fünf Einträge hinzufügen', 'Add up to five entries')"/></label>
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
                                    <div id="graphics-selected-entities" class="graphics-selected-list" />
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-8">
                            <div class="graphics-chart-shell">
                                <canvas id="graphics-chart"></canvas>
                            </div>
                            <div id="graphics-legend" class="graphics-legend-list mt-3"></div>
                            <div id="graphics-status" class="graphics-status mt-3 small text-muted"><xsl:value-of select="local:text('Wählen Sie mindestens einen Eintrag aus, um das Diagramm anzuzeigen.', 'Select at least one entry to draw the chart.')"/></div>
                        </div>
                    </div>
                </div>
            </div>

            <datalist id="graphics-person-options"></datalist>
            <datalist id="graphics-work-options"></datalist>
            <datalist id="graphics-place-options"></datalist>

            <div id="graphics-data" class="d-none" data-source="data/graphics-chart-traktat-entities.json"></div>
        </section>
    </xsl:template>
</xsl:stylesheet>
