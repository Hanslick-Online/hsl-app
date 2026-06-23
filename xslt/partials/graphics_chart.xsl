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

    <xsl:variable name="person-index" as="document-node()" select="doc(resolve-uri('../../data/indices/listperson.xml', static-base-uri()))"/>
    <xsl:variable name="bibl-index" as="document-node()" select="doc(resolve-uri('../../data/indices/listbibl.xml', static-base-uri()))"/>
    <xsl:variable name="place-index" as="document-node()" select="doc(resolve-uri('../../data/indices/listplace.xml', static-base-uri()))"/>

    <xsl:function name="local:corpus" as="xs:string?">
        <xsl:param name="target" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="starts-with($target, 't__')">traktat</xsl:when>
            <xsl:when test="starts-with($target, 'c__')">critics</xsl:when>
            <xsl:when test="starts-with($target, 'v__')">vms</xsl:when>
            <xsl:when test="starts-with($target, 'd__')">documents</xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:function>

        <xsl:function name="local:text" as="xs:string">
            <xsl:param name="de" as="xs:string"/>
            <xsl:param name="en" as="xs:string"/>
            <xsl:sequence select="if ($is-german) then $de else $en"/>
        </xsl:function>

        <xsl:function name="local:count-targets" as="xs:integer">
            <xsl:param name="notes" as="element(tei:note)*"/>
            <xsl:param name="corpus" as="xs:string"/>
            <xsl:sequence select="count(distinct-values(for $note in $notes[local:corpus(string(@target)) = $corpus] return string($note/@target)))"/>
        </xsl:function>

        <xsl:function name="local:person-label" as="xs:string">
            <xsl:param name="person" as="element(tei:person)"/>
            <xsl:sequence select="normalize-space(string-join((($person/tei:persName[@type='main'][1], $person/tei:persName[1])[1])//text(), ' '))"/>
        </xsl:function>

        <xsl:function name="local:work-label" as="xs:string">
            <xsl:param name="bibl" as="element(tei:bibl)"/>
            <xsl:sequence select="normalize-space(string-join((($bibl/tei:title[@type='main'][1], $bibl/tei:title[1])[1])//text(), ' '))"/>
        </xsl:function>

        <xsl:function name="local:place-label" as="xs:string">
            <xsl:param name="place" as="element(tei:place)"/>
            <xsl:sequence select="normalize-space(string-join((($place//tei:placeName[@type='main'][1], $place//tei:placeName[1])[1])//text(), ' '))"/>
        </xsl:function>

        <xsl:function name="local:entity-label" as="xs:string">
            <xsl:param name="entity" as="element()"/>
            <xsl:choose>
                <xsl:when test="$entity/self::tei:person">
                    <xsl:sequence select="local:person-label($entity/self::tei:person)"/>
                </xsl:when>
                <xsl:when test="$entity/self::tei:bibl">
                    <xsl:sequence select="local:work-label($entity/self::tei:bibl)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="local:place-label($entity/self::tei:place)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:function>

        <xsl:function name="local:entity-type-label" as="xs:string">
            <xsl:param name="entity" as="element()"/>
            <xsl:choose>
                <xsl:when test="$entity/self::tei:person">Person</xsl:when>
                <xsl:when test="$entity/self::tei:bibl">
                    <xsl:sequence select="local:text('Werk', 'Work')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="local:text('Ort', 'Place')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:function>

        <xsl:function name="local:entity-sort-group" as="xs:integer">
            <xsl:param name="entity" as="element()"/>
            <xsl:choose>
                <xsl:when test="$entity/self::tei:person">1</xsl:when>
                <xsl:when test="$entity/self::tei:bibl">2</xsl:when>
                <xsl:otherwise>3</xsl:otherwise>
            </xsl:choose>
        </xsl:function>

        <xsl:function name="local:entity-mentions" as="element(tei:note)*">
            <xsl:param name="entity" as="element()"/>
            <xsl:sequence select="$entity/tei:noteGrp/tei:note[@type='mentions'][matches(normalize-space(@corresp), '^\d{4}')][local:corpus(string(@target)) != '']"/>
        </xsl:function>

        <xsl:variable name="people" as="element(tei:person)*" select="$person-index//tei:person[local:entity-mentions(.)]"/>
        <xsl:variable name="works" as="element(tei:bibl)*" select="$bibl-index//tei:listBibl/tei:bibl[local:entity-mentions(.)]"/>
        <xsl:variable name="places" as="element(tei:place)*" select="$place-index//tei:place[local:entity-mentions(.)]"/>
        <xsl:variable name="entities" as="element()*" select="($people, $works, $places)"/>
        <xsl:variable name="all-mentions" as="element(tei:note)*" select="for $entity in $entities return local:entity-mentions($entity)"/>
        <xsl:variable name="global-min-year" as="xs:integer" select="min(for $note in $all-mentions return xs:integer(substring(normalize-space($note/@corresp), 1, 4)))"/>
        <xsl:variable name="global-max-year" as="xs:integer" select="max(for $note in $all-mentions return xs:integer(substring(normalize-space($note/@corresp), 1, 4)))"/>

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
                                        <label class="form-label" for="graphics-entity-input"><xsl:value-of select="local:text('Bis zu fünf Entitäten hinzufügen', 'Add up to five entities')"/></label>
                                        <div class="graphics-add-row">
                                            <input id="graphics-entity-input" class="form-control" type="text" list="graphics-entity-options" placeholder="{local:text('Entität eingeben', 'Start typing an entity')}"/>
                                            <button id="graphics-add-entity" class="btn btn-primary" type="button"><xsl:value-of select="local:text('Hinzufügen', 'Add')"/></button>
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
                                <div class="graphics-chart-shell">
                                    <canvas id="graphics-chart"></canvas>
                                </div>
                                <div id="graphics-status" class="graphics-status mt-3 small text-muted"><xsl:value-of select="local:text('Wählen Sie mindestens eine Entität aus, um das Diagramm anzuzeigen.', 'Select at least one entity to draw the chart.')"/></div>
                            </div>
                        </div>
                    </div>
                </div>

                <datalist id="graphics-entity-options">
                    <xsl:apply-templates select="$entities" mode="entity-option">
                        <xsl:sort select="local:entity-sort-group(.)" data-type="number"/>
                        <xsl:sort select="lower-case(local:entity-label(.))"/>
                    </xsl:apply-templates>
                </datalist>

                <div id="graphics-data" class="d-none"
                    data-min-year="{$global-min-year}"
                    data-max-year="{$global-max-year}"
                    data-label-traktat="Traktat"
                    data-label-critics="{local:text('Kritiken (NFP)', 'Critics (NFP)')}"
                    data-label-vms="{local:text('VMS-Rezensionen', 'VMS Reviews')}"
                    data-label-documents="{local:text('Dokumente', 'Documents')}"
                    data-remove-aria-label="{local:text('Entfernen: {label}', 'Remove {label}')}"
                    data-tooltip-year="{local:text('Jahr {year}', 'Year {year}')}"
                    data-axis-year="{local:text('Jahr', 'Year')}"
                    data-axis-frequency="{local:text('Häufigkeit', 'Frequency')}"
                    data-status-empty="{local:text('Wählen Sie mindestens eine Entität aus, um das Diagramm anzuzeigen.', 'Select at least one entity to draw the chart.')}"
                    data-status-no-corpora="{local:text('Aktivieren Sie mindestens ein Korpus oder schalten Sie &quot;Gesamt&quot; wieder ein.', 'Enable at least one corpus or switch Total back on.')}"
                    data-status-total-singular="{local:text('Zeige {count} Entität über alle Korpora zusammen.', 'Showing {count} entity across all corpora together.')}"
                    data-status-total-plural="{local:text('Zeige {count} Entitäten über alle Korpora zusammen.', 'Showing {count} entities across all corpora together.')}"
                    data-status-filtered-singular="{local:text('Zeige {count} Entität für {corpora}.', 'Showing {count} entity for {corpora}.')}"
                    data-status-filtered-plural="{local:text('Zeige {count} Entitäten für {corpora}.', 'Showing {count} entities for {corpora}.')}"
                    data-error-invalid-entity="{local:text('Wählen Sie vor dem Hinzufügen eine Entität aus der Vorschlagsliste aus.', 'Choose an entity from the suggestion list before adding it.')}"
                    data-error-duplicate="{local:text('{label} ist bereits ausgewählt.', '{label} is already selected.')}"
                    data-error-max="{local:text('Sie können bis zu {max} Entitäten gleichzeitig vergleichen.', 'You can compare up to {max} entities at once.')}">
                    <xsl:apply-templates select="$entities" mode="entity-data">
                        <xsl:sort select="local:entity-sort-group(.)" data-type="number"/>
                        <xsl:sort select="lower-case(local:entity-label(.))"/>
                    </xsl:apply-templates>
                </div>
            </section>
        </xsl:template>

        <xsl:template match="tei:person | tei:bibl | tei:place" mode="entity-option">
            <xsl:variable name="label" as="xs:string" select="local:entity-label(.)"/>
            <xsl:variable name="type-label" as="xs:string" select="local:entity-type-label(.)"/>
            <option value="{$label} ({$type-label}, {@xml:id})" data-entity-id="{string(@xml:id)}" data-display-label="{$label}" data-entity-type="{$type-label}">
                <xsl:value-of select="$label"/>
            </option>
        </xsl:template>

        <xsl:template match="tei:person | tei:bibl | tei:place" mode="entity-data">
            <xsl:variable name="label" as="xs:string" select="local:entity-label(.)"/>
            <xsl:variable name="type-label" as="xs:string" select="local:entity-type-label(.)"/>
            <xsl:variable name="mentions" as="element(tei:note)*" select="local:entity-mentions(.)"/>
            <div class="graphics-entity" data-entity-id="{string(@xml:id)}" data-entity-label="{$label}" data-entity-type="{$type-label}">
                <xsl:for-each-group select="$mentions" group-by="substring(normalize-space(@corresp), 1, 4)">
                    <xsl:sort select="xs:integer(current-grouping-key())" data-type="number"/>
                    <span class="graphics-year"
                        data-year="{current-grouping-key()}"
                        data-traktat="{local:count-targets(current-group(), 'traktat')}"
                        data-critics="{local:count-targets(current-group(), 'critics')}"
                        data-vms="{local:count-targets(current-group(), 'vms')}"
                        data-documents="{local:count-targets(current-group(), 'documents')}"></span>
                </xsl:for-each-group>
            </div>
        </xsl:template>
    </xsl:stylesheet>
