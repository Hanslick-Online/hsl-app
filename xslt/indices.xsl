<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="urn:hsl:indices"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="local xsl tei xs">
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>

    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="no" omit-xml-declaration="yes"/>

    <xsl:variable name="hanslick-id" as="xs:string" select="'hsl_person_id_1'"/>
    <xsl:variable name="doc-targets" as="xs:string*" select="distinct-values(/tei:TEI//tei:listPerson/tei:person/tei:noteGrp/tei:note[starts-with(string(@target), 'd__')]/string(@target))"/>
    <xsl:variable name="doc-editions" as="document-node()*">
        <xsl:for-each select="$doc-targets">
            <xsl:variable name="doc-uri" as="xs:anyURI" select="resolve-uri(concat('../data/doc/editions/', .), static-base-uri())"/>
            <xsl:if test="doc-available($doc-uri)">
                <xsl:sequence select="doc($doc-uri)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <xsl:function name="local:person-label" as="xs:string">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:variable name="main" as="element(tei:persName)?" select="$person/tei:persName[@type='main'][1]"/>
        <xsl:variable name="fallback" as="element(tei:persName)?" select="$person/tei:persName[1]"/>
        <xsl:variable name="selected" as="element(tei:persName)?" select="($main, $fallback)[1]"/>
        <xsl:variable name="surname" as="xs:string" select="normalize-space(string($selected/tei:surname))"/>
        <xsl:variable name="forename" as="xs:string" select="normalize-space(string($selected/tei:forename))"/>
        <xsl:choose>
            <xsl:when test="$surname != '' and $forename != ''">
                <xsl:sequence select="concat($surname, ', ', $forename)"/>
            </xsl:when>
            <xsl:when test="$surname != ''">
                <xsl:sequence select="$surname"/>
            </xsl:when>
            <xsl:when test="$forename != ''">
                <xsl:sequence select="$forename"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="normalize-space(string-join($selected//text(), ' '))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="local:normalize-target" as="xs:string">
        <xsl:param name="target" as="xs:string"/>
        <xsl:choose>
            <!-- Treat all VMS treatise editions as a single logical document. -->
            <xsl:when test="starts-with($target, 't__')">t__VMS_TREATISE</xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$target"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="local:json-escape" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:variable name="v0" as="xs:string" select="string($value)"/>
        <xsl:variable name="v1" as="xs:string" select="replace($v0, '\\', '\\\\')"/>
        <xsl:variable name="v2" as="xs:string" select="replace($v1, '&quot;', '\\&quot;')"/>
        <xsl:variable name="v3" as="xs:string" select="replace($v2, codepoints-to-string(10), '\\n')"/>
        <xsl:variable name="v4" as="xs:string" select="replace($v3, codepoints-to-string(13), '\\r')"/>
        <xsl:sequence select="replace($v4, codepoints-to-string(9), '\\t')"/>
    </xsl:function>

    <xsl:function name="local:pub-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:sequence select="distinct-values(for $target in $person/tei:noteGrp/tei:note[@type='mentions'][starts-with(string(@target), 'c__') or starts-with(string(@target), 't__')]/string(@target) return local:normalize-target($target))"/>
    </xsl:function>

    <xsl:function name="local:doc-mention-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:sequence select="distinct-values($person/tei:noteGrp/tei:note[@type='mentions'][starts-with(string(@target), 'd__')]/string(@target))"/>
    </xsl:function>

    <xsl:function name="local:doc-authored-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:variable name="person-ref" as="xs:string" select="concat('#', string($person/@xml:id))"/>
        <xsl:sequence select="distinct-values(for $doc in $doc-editions[.//tei:teiHeader//tei:author[@ref = $person-ref]] return string((($doc/tei:TEI/@xml:id)[1], tokenize(base-uri($doc), '/')[last()])[1]))"/>
    </xsl:function>

    <xsl:function name="local:node-group" as="xs:string">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:param name="pub-count" as="xs:integer"/>
        <xsl:param name="doc-mention-count" as="xs:integer"/>
        <xsl:param name="doc-authored-count" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="string($person/@xml:id) = $hanslick-id">hanslick</xsl:when>
            <xsl:when test="$doc-authored-count gt 0">doc-author</xsl:when>
            <xsl:when test="$doc-mention-count gt 0 and $person/@role = 'fictional'">doc-character</xsl:when>
            <xsl:when test="$doc-mention-count gt 0">doc-person</xsl:when>
            <xsl:when test="$pub-count gt 0 and $person/@role = 'fictional'">pub-character</xsl:when>
            <xsl:otherwise>pub-person</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:titleStmt//tei:title[@type='main'][1]/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                
                <xsl:if test="contains($doc_title, 'Ortsregister')">
                    <!-- ############### leaflet stylesheets ############### -->
                    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.3/dist/leaflet.css"
                        integrity="sha256-kLaT2GOSpHechhsozzB+flnD+zUyjE2LlfWPgU04xyI="
                        crossorigin=""/>
                    <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css"/>
                    <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css"/>
                    <link href='https://api.mapbox.com/mapbox.js/plugins/leaflet-fullscreen/v1.0.1/leaflet.fullscreen.css' rel='stylesheet'/>
                </xsl:if>
                
                <!-- ############### datatable ############### -->
                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/bs5/jszip-2.5.0/dt-1.13.1/b-2.3.3/b-colvis-2.3.3/b-html5-2.3.3/fc-4.2.1/fh-3.3.1/r-2.4.0/sp-2.1.0/sl-1.5.0/datatables.min.css"/>
                <style>
                    .container-fluid {
                        max-width: 100% !important;
                    }

                    .person-network-panel {
                        margin: 1.5rem auto 2rem auto;
                        padding: 1rem;
                        border: 1px solid #d9e2ec;
                        border-radius: 0.75rem;
                        background: #f8fbfd;
                    }

                    .person-network-controls {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 0.75rem 1.25rem;
                        align-items: center;
                        margin-bottom: 0.75rem;
                    }

                    .person-network-controls label {
                        font-weight: 600;
                    }

                    .person-network-controls input[type='range'] {
                        width: 220px;
                    }

                    .person-network-category-toggles {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 0.5rem 1rem;
                        width: 100%;
                        margin-top: 0.25rem;
                        font-size: 0.9rem;
                    }

                    .person-network-category-toggles label {
                        display: inline-flex;
                        align-items: center;
                        gap: 0.35rem;
                        font-weight: 400;
                    }

                    .person-network-performance-note {
                        width: 100%;
                        font-size: 0.82rem;
                        color: #6b7280;
                    }

                    .person-network-copresence-min {
                        display: inline-flex;
                        align-items: center;
                        gap: 0.35rem;
                    }

                    .person-network-copresence-min input {
                        width: 64px;
                    }

                    .person-network-node-limit {
                        display: inline-flex;
                        align-items: center;
                        gap: 0.5rem;
                    }

                    .person-network-node-limit input[type='number'] {
                        width: 92px;
                    }

                    #person-network {
                        position: relative;
                        height: 560px;
                        width: 100%;
                        border: 1px solid #cfd8e3;
                        border-radius: 0.5rem;
                        background: #ffffff;
                    }

                    .person-network-popup {
                        position: absolute;
                        z-index: 30;
                        display: none;
                        pointer-events: auto;
                        text-align: center;
                        margin-bottom: 20px;
                    }

                    .person-network-popup .leaflet-popup-content-wrapper {
                        padding: 1px;
                        border-radius: 12px;
                        box-shadow: 0 3px 14px rgba(0, 0, 0, 0.22);
                        background: #fff;
                        color: #333;
                        text-align: left;
                    }

                    .person-network-popup .leaflet-popup-content {
                        margin: 13px 24px 13px 20px;
                        line-height: 1.35;
                        font-size: 13px;
                        min-width: 120px;
                        max-width: 220px;
                    }

                    .person-network-popup .leaflet-popup-tip-container {
                        width: 40px;
                        height: 20px;
                        position: absolute;
                        left: 50%;
                        margin-top: -1px;
                        margin-left: -20px;
                        overflow: hidden;
                        pointer-events: none;
                        bottom: -20px;
                    }

                    .person-network-popup .leaflet-popup-tip {
                        width: 17px;
                        height: 17px;
                        padding: 1px;
                        margin: -10px auto 0;
                        transform: rotate(45deg);
                        background: #fff;
                        box-shadow: 0 3px 14px rgba(0, 0, 0, 0.18);
                    }

                    .person-network-popup .leaflet-popup-close-button {
                        position: absolute;
                        top: 0;
                        right: 0;
                        width: 24px;
                        height: 24px;
                        color: #757575;
                        text-align: center;
                        text-decoration: none;
                        font: 16px/24px Tahoma, Verdana, sans-serif;
                        background: transparent;
                        border: 0;
                        cursor: pointer;
                    }

                    .person-network-popup .leaflet-popup-close-button:hover {
                        color: #333;
                    }

                    .person-network-legend {
                        margin-top: 0.75rem;
                        display: flex;
                        flex-wrap: wrap;
                        gap: 0.5rem 1rem;
                        font-size: 0.9rem;
                    }

                    .person-network-legend span {
                        display: inline-flex;
                        align-items: center;
                        gap: 0.35rem;
                    }

                    .person-network-legend i {
                        width: 0.75rem;
                        height: 0.75rem;
                        border-radius: 50%;
                        display: inline-block;
                    }

                    .person-network-hint {
                        margin-top: 0.5rem;
                        color: #4b5563;
                        font-size: 0.88rem;
                    }
                </style>
            </head>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">
                        <h1 style="text-align: center;margin: 2em auto;"><xsl:value-of select="$doc_title"/></h1>

                        <xsl:if test="contains($doc_title, 'Personenregister')">
                            <xsl:variable name="graph-persons" as="element(tei:person)*" select="//tei:listPerson/tei:person"/>
                            <xsl:variable name="graph-max-rel" as="xs:integer"
                                select="max((1, for $person in $graph-persons return count(distinct-values((local:pub-targets($person), local:doc-mention-targets($person), local:doc-authored-targets($person))))))"/>

                            <xsl:result-document href="person-network-data.json" method="text" encoding="UTF-8">
                                <xsl:text>{"hanslickId":"</xsl:text>
                                <xsl:value-of select="$hanslick-id"/>
                                <xsl:text>","maxRel":</xsl:text>
                                <xsl:value-of select="$graph-max-rel"/>
                                <xsl:text>,"nodes":[</xsl:text>
                                <xsl:for-each select="$graph-persons[string(@xml:id) = $hanslick-id or count(distinct-values((local:pub-targets(.), local:doc-mention-targets(.), local:doc-authored-targets(.)))) gt 0]">
                                    <xsl:variable name="pub-targets" as="xs:string*" select="local:pub-targets(.)"/>
                                    <xsl:variable name="doc-targets" as="xs:string*" select="local:doc-mention-targets(.)"/>
                                    <xsl:variable name="authored-targets" as="xs:string*" select="local:doc-authored-targets(.)"/>
                                    <xsl:variable name="relation-targets" as="xs:string*" select="distinct-values(($pub-targets, $doc-targets, $authored-targets))"/>
                                    <xsl:variable name="total-rel" as="xs:integer" select="count($relation-targets)"/>
                                    <xsl:if test="position() gt 1">
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                    <xsl:text>{"id":"</xsl:text>
                                    <xsl:value-of select="local:json-escape(string(@xml:id))"/>
                                    <xsl:text>","label":"</xsl:text>
                                    <xsl:value-of select="local:json-escape(local:person-label(.))"/>
                                    <xsl:text>","url":"</xsl:text>
                                    <xsl:value-of select="local:json-escape(concat(string(@xml:id), '.html'))"/>
                                    <xsl:text>","group":"</xsl:text>
                                    <xsl:value-of select="local:json-escape(local:node-group(., count($pub-targets), count($doc-targets), count($authored-targets)))"/>
                                    <xsl:text>","relTotal":</xsl:text>
                                    <xsl:value-of select="$total-rel"/>
                                    <xsl:text>,"relPub":</xsl:text>
                                    <xsl:value-of select="count($pub-targets)"/>
                                    <xsl:text>,"relDocMentions":</xsl:text>
                                    <xsl:value-of select="count($doc-targets)"/>
                                    <xsl:text>,"relDocAuthored":</xsl:text>
                                    <xsl:value-of select="count($authored-targets)"/>
                                    <xsl:text>,"targets":[</xsl:text>
                                    <xsl:for-each select="$relation-targets">
                                        <xsl:if test="position() gt 1">
                                            <xsl:text>,</xsl:text>
                                        </xsl:if>
                                        <xsl:text>"</xsl:text>
                                        <xsl:value-of select="local:json-escape(.)"/>
                                        <xsl:text>"</xsl:text>
                                    </xsl:for-each>
                                    <xsl:text>]}</xsl:text>
                                </xsl:for-each>
                                <xsl:text>]}</xsl:text>
                            </xsl:result-document>

                            <div class="person-network-panel">
                                <div class="person-network-controls">
                                    <label for="person-network-min-rel">Mindestanzahl Relationen:</label>
                                    <input id="person-network-min-rel" type="number" min="1" max="{$graph-max-rel}" step="1" value="1"/>
                                    <div class="person-network-node-limit">
                                        <label for="person-network-node-limit">Knoten pro Kategorie:</label>
                                        <input id="person-network-node-limit" type="number" min="1" step="1" value="25"/>
                                        <span id="person-network-node-limit-max"></span>
                                    </div>
                                    <div class="person-network-category-toggles">
                                        <label><input type="checkbox" class="person-network-category-toggle" data-group="pub-person" checked="checked"/>Personen von Hanslick erwähnt</label>
                                        <label><input type="checkbox" class="person-network-category-toggle" data-group="pub-character" checked="checked"/>Figuren von Hanslick erwähnt</label>
                                        <label><input type="checkbox" class="person-network-category-toggle" data-group="doc-author" checked="checked"/>erwähnt Hanslick</label>
                                        <label><input type="checkbox" class="person-network-category-toggle" data-group="doc-person" checked="checked"/>Kopräsenz mit Hanslick (Person)</label>
                                        <label><input type="checkbox" class="person-network-category-toggle" data-group="doc-character" checked="checked"/>Kopräsenz mit Hanslick (Figur)</label>
                                        <label><input type="checkbox" id="person-network-toggle-copresence"/>Kopräsenz-Kanten zwischen Knoten</label>
                                        <label class="person-network-copresence-min" for="person-network-min-copresence">Min. Kopräsenz:
                                            <input id="person-network-min-copresence" type="number" min="1" step="1" value="2"/>
                                        </label>
                                        <span class="person-network-performance-note">Hinweis: Kopräsenz-Kanten sind bei großen Netzen aufwendig und standardmäßig deaktiviert.</span>
                                    </div>
                                </div>
                                <div id="person-network"></div>
                                <div class="person-network-hint">Klicken Sie auf einen Knoten, um zur Personenseite zu wechseln. Zoomen mit Mausrad oder Touch-Geste.</div>
                                <div class="person-network-legend">
                                    <span><i style="background:#1d4e89"></i>Personen von Hanslick erwähnt</span>
                                    <span><i style="background:#5f93c2"></i>Figuren von Hanslick erwähnt</span>
                                    <span><i style="background:#ba4a00"></i>erwähnt Hanslick</span>
                                    <span><i style="background:#e67e22"></i>Kopräsenz mit Hanslick (Person)</span>
                                    <span><i style="background:#f5b041"></i>Kopräsenz mit Hanslick (Figur)</span>
                                </div>

                                <div id="person-network-data" class="d-none" data-hanslick-id="{$hanslick-id}" data-max-rel="{$graph-max-rel}" data-source="person-network-data.json"/>
                            </div>
                        </xsl:if>
                        
                        <xsl:if test="contains($doc_title, 'Ortsregister')">
                            <div id="tableReload-wrapper">
                                <svg id="tableReload" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-arrow-clockwise" viewBox="0 0 16 16">
                                    <path fill-rule="evenodd" d="M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2v1z"/>
                                    <path d="M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 0 1 8 4.466z"/>
                                </svg>
                            </div>
                            <div id="leaflet-map-one"></div>
                        </xsl:if>
                        
                        <xsl:apply-templates select="//tei:body"/>

                    </div><!-- .container-fluid -->
                    <xsl:call-template name="html_footer"/>
                </div><!-- .site -->
                
                <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/pdfmake.min.js"></script>
                <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/vfs_fonts.js"></script>
                <script type="text/javascript" src="https://cdn.datatables.net/v/bs5/jszip-2.5.0/dt-1.13.1/b-2.3.3/b-colvis-2.3.3/b-html5-2.3.3/fc-4.2.1/fh-3.3.1/r-2.4.0/sp-2.1.0/sl-1.5.0/datatables.min.js"></script>                
                <xsl:if test="contains($doc_title, 'Ortsregister')">
                    <!-- ############### leaflet script ################ -->
                    <script src="https://unpkg.com/leaflet@1.9.3/dist/leaflet.js"
                        integrity="sha256-WBkoXOwTeyKclOHuWtc+i2uENFpDZ9YPdf5Hf+D7ewM="
                        crossorigin=""></script>
                    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet-ajax/2.1.0/leaflet.ajax.min.js"></script>
                    <script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"></script>
                    <script src='https://api.mapbox.com/mapbox.js/plugins/leaflet-fullscreen/v1.0.1/Leaflet.fullscreen.min.js'></script>
                    <script src="https://unpkg.com/heatmap.js@2.0.5/build/heatmap.min.js"></script>
                    <script src="https://unpkg.com/heatmap.js@2.0.5/plugins/leaflet-heatmap/leaflet-heatmap.js"></script>
                </xsl:if>
                <xsl:if test="contains($doc_title, 'Personenregister')">
                    <script src="https://unpkg.com/cytoscape@3.29.2/dist/cytoscape.min.js"></script>
                    <script src="js/person-network.js"></script>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="contains($doc_title, 'Personenregister')">
                        <script src="js/dt-panes.js"/>
                        <script type="text/javascript">
                            createDataTable('listperson', 'Suche:', [2, 3, 5, 12], [0, 1, 4, 6, 7, 8, 9, 10, 11], [12]);
                        </script>
                    </xsl:when>
                    <xsl:when test="contains($doc_title, 'Ortsregister')">
                        <script src="js/leaflet.js"/>
                        <script type="text/javascript">
                            leafletDatatable('listplace', [6, 7, 8], [0, 1, 2, 3, 4, 5]);
                        </script>
                    </xsl:when>
                    <xsl:when test="contains($doc_title, 'Werkregister')">
                        <script src="js/dt-panes.js"/>
                        <script type="text/javascript">
                            createDataTable('listbibl', 'Suche:', [2, 3, 5, 7], [0, 1, 4, 6], [8]);
                        </script>
                    </xsl:when>
                </xsl:choose>
                <script type="text/javascript" src="js/run.js"></script>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="tei:body">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:listPerson">
        <div class="index-table">
            <table class="table" id="listperson">
                 <thead>
                     <tr>
                         <th>Name</th>
                         <th>Name (alt)</th>
                         <th>Typ</th>
                         <th>Lebensdaten</th>
                         <th>Beschreibung</th>
                         <th>Werke (Figur)</th>
                         <th>GND</th>
                         <th>Wikidata</th>
                         <th>PMB</th>
                         <th>OeBl</th>
                         <th>OeMl</th>
                         <th>Erwähnt #</th>
                         <th>Initial</th>
                     </tr>
                 </thead>
                 <tbody>
                     <xsl:for-each select="./tei:person">
                         <xsl:if test="count(./tei:noteGrp/tei:note) gt 0">
                            <tr>
                                <td>
                                    <a href="{concat(@xml:id, '.html')}">
                                        <xsl:if test="./tei:persName[@type='main']/tei:surname/text()">
                                            <xsl:value-of select="./tei:persName[@type='main']/tei:surname"/>
                                        </xsl:if>
                                        <xsl:if test="./tei:persName[@type='main']/tei:surname/text() and ./tei:persName[@type='main']/tei:forename/text()">
                                        <xsl:text>, </xsl:text>
                                        </xsl:if>
                                        <xsl:if test="./tei:persName[@type='main']/tei:forename/text()">
                                            <xsl:value-of select="./tei:persName[@type='main']/tei:forename"/>
                                        </xsl:if>
                                    </a>
                                </td>
                                <td>
                                    <xsl:if test="./tei:persName[@type='alternative']/tei:surname/text()">
                                        <xsl:value-of select="./tei:persName[@type='alternative']/tei:surname"/>
                                    </xsl:if>
                                    <xsl:if test="./tei:persName[@type='alternative']/tei:surname/text() and 
                                                  ./tei:persName[@type='alternative']/tei:forename/text()">
                                        <xsl:text>, </xsl:text>
                                    </xsl:if>
                                    <xsl:if test="./tei:persName[@type='alternative']/tei:forename/text()">
                                        <xsl:value-of select="./tei:persName[@type='alternative']/tei:forename"/>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="@role">
                                            <xsl:value-of select="@role"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>non fictional</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>                                    
                                </td>
                                <td>
                                    <xsl:value-of select="./tei:birth"/>
                                </td>
                                <td>
                                    <xsl:if test="./tei:occupation">
                                        <ul>
                                            <xsl:for-each select="./tei:occupation">
                                                <li class="{substring-before(substring-after(@style, 'background-color: '), ';')}">
                                                    <xsl:value-of select="./text()"/>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:listBibl[@type='characterOf']">
                                        <!--<a href="{./tei:bibl/@n}.html" alt="{./tei:listBibl[@type='characterOf']/tei:bibl/text()}">
                                            <xsl:value-of select="./tei:listBibl[@type='characterOf']/tei:bibl/text()"/>
                                        </a>-->
                                        <ul>
                                            <xsl:for-each select="./tei:listBibl[@type='characterOf']/tei:bibl">
                                                <li>
                                                    <xsl:value-of select="./text()"/>
                                                    <xsl:if test="position() != last()">
                                                        <xsl:text>;</xsl:text>
                                                    </xsl:if>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:idno[@subtype='GND']">
                                    <a href="{./tei:idno[@subtype='GND']}" target="_blank">
                                        <xsl:value-of select="tokenize(./tei:idno[@subtype='GND'], '/')[last()]"/>
                                    </a>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:idno[@subtype='WIKIDATA']">
                                    <a href="{./tei:idno[@subtype='WIKIDATA']}" target="_blank">
                                        <xsl:value-of select="tokenize(./tei:idno[@subtype='WIKIDATA'], '/')[last()]"/>
                                    </a>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:idno[@subtype='PMB']">
                                    <a href="{./tei:idno[@subtype='PMB']}" target="_blank">
                                        <xsl:value-of select="tokenize(./tei:idno[@subtype='PMB'], '/')[last()]"/>
                                    </a>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:idno[@subtype='OEBL']">
                                        <a href="{./tei:idno[@subtype='OEBL']}" target="_blank">
                                            <xsl:value-of select="concat(
                                                tokenize(./tei:idno[@subtype='OEBL'], '/')[last() - 1],
                                                '/',
                                                replace(tokenize(./tei:idno[@subtype='OEBL'], '/')[last()], '.xml', '')
                                                )"/>
                                        </a>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:idno[@subtype='OEML']">
                                    <a href="{./tei:idno[@subtype='OEML']}" target="_blank">
                                        <xsl:value-of select="concat(
                                            tokenize(./tei:idno[@subtype='OEML'], '/')[last() - 1],
                                            '/',
                                            replace(tokenize(./tei:idno[@subtype='OEML'], '/')[last()], '.xml', '')
                                            )"/>
                                    </a>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:value-of select="count(./tei:noteGrp/tei:note)"/>
                                </td>
                                
                                <td>
                                    <xsl:value-of select="substring(./tei:persName[@type='main']/tei:surname, 1, 1)"/>
                                </td>
                            </tr>
                         </xsl:if>
                     </xsl:for-each>
                 </tbody>
             </table>
        </div>
    </xsl:template>
    <xsl:template match="tei:listPlace">
        <div class="index-table">
            <table class="table" id="listplace">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Name (alt)</th>
                        <th>Geonames ID</th>
                        <th>Wikidata ID</th>
                        <th>GND ID</th>
                        <th>Koordinaten</th>
                        <th>Typ</th>
                        <th>Land</th>
                        <th>Erwähnt #</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="./tei:place">
                        <xsl:if test="count(./tei:noteGrp/tei:note) gt 0">
                        <xsl:variable name="count" select="count(./tei:listEvent/tei:event)"/>
                        <xsl:variable name="coords" select="tokenize(./tei:location[@type='coords']/tei:geo, ', ')"/>
                            <tr>
                                <td>
                                    <a href="{concat(@xml:id, '.html')}">
                                        <xsl:choose>
                                            <xsl:when test="./tei:settlement/tei:placeName[@type='main']">
                                                <xsl:value-of select="./tei:settlement/tei:placeName[@type='main']"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="./tei:placeName[@type='main']"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </a>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="./tei:settlement/tei:placeName[@type='alternative']">
                                            <xsl:value-of select="./tei:settlement/tei:placeName[@type='alternative']"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="./tei:placeName[@type='alternative']"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <a href="{./tei:idno[@subtype='GEONAMES']}" target="_blank">
                                        <xsl:value-of select="tokenize(./tei:idno[@subtype='GEONAMES'], '/')[4]"/>
                                    </a>
                                </td>
                                <td>
                                    <a href="{./tei:idno[@subtype='WIKIDATA']}" target="_blank">
                                        <xsl:value-of select="tokenize(./tei:idno[@subtype='WIKIDATA'], '/')[last()]"/>
                                    </a>
                                </td>
                                <td>
                                    <a href="{./tei:idno[@subtype='GND']}" target="_blank">
                                        <xsl:value-of select="tokenize(./tei:idno[@subtype='GND'], '/')[last()]"/>
                                    </a>
                                </td>
                                <xsl:choose>
                                    <xsl:when test="./tei:location/tei:geo">
                                        <td class="map-coordinates" 
                                            id="{@xml:id}" 
                                            data-count="{$count}" 
                                            data-country="{substring-before(./tei:country, ', ')}" 
                                            lat="{$coords[1]}" 
                                            long="{$coords[2]}" 
                                            subtitle="{if (./tei:settlement) then (./tei:settlement/tei:placeName) else (./tei:placeName)}">
                                            <xsl:value-of select="./tei:location/tei:geo"/>
                                        </td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td></td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <td>
                                    <xsl:if test="./tei:settlement/@type">
                                        <xsl:value-of select="concat(./tei:settlement/@type, ', ', ./tei:desc[@type='entity_type'])"/>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:value-of select="./tei:country"/>
                                </td>
                                <td>
                                    <xsl:value-of select="count(./tei:noteGrp/tei:note)"/>
                                </td>
                            </tr>
                        </xsl:if>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>
    <xsl:template match="tei:listBibl">
        <div class="index-table">
            <table class="table" id="listbibl">
                <thead>
                    <tr>
                        <th>Titel</th>
                        <th>Titel (alt)</th>
                        <th style="min-width: 200px;">Autor</th>
                        <th style="min-width: 200px;">Figur</th>
                        <th>GND</th>
                        <th>Digitalisat</th>
                        <th>Werkbezug</th>
                        <th>Erwähnt #</th>
                        <th>Initial</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="./tei:bibl">
                        <xsl:if test="count(./tei:noteGrp/tei:note) gt 0">
                            <tr>
                                <td>
                                    <a href="{concat(@xml:id, '.html')}">
                                        <xsl:value-of select="./tei:title[@type='main']"/>
                                    </a>
                                </td>
                                <td>
                                    <xsl:value-of select="./tei:title[@type='alternative']"/>
                                </td>
                                <td>
                                    <xsl:if test="./tei:author">
                                    <ul>
                                        <xsl:for-each select="./tei:author">
                                            <xsl:sort select="./tei:persName/text()" order="ascending"/>
                                            <li>
                                                <xsl:value-of select="./tei:persName"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>;</xsl:text>
                                                </xsl:if>
                                            </li>
                                        </xsl:for-each>    
                                    </ul>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:name[@type='character']">
                                    <ul>
                                        <xsl:for-each select="./tei:name[@type='character']">
                                            <xsl:sort select="." order="ascending"/>
                                            <li>
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>;</xsl:text>
                                                </xsl:if>
                                            </li>
                                        </xsl:for-each>    
                                    </ul>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:idno[@subtype='GND']">
                                    <a href="{./tei:idno[@subtype='GND']}" target="_blank">
                                        <xsl:value-of select="tokenize(./tei:idno[@subtype='GND'], '/')[last()]"/>
                                    </a>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:idno[@subtype='Digitalisat']/text()">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-check2-circle" viewBox="0 0 16 16">
                                            <path d="M2.5 8a5.5 5.5 0 0 1 8.25-4.764.5.5 0 0 0 .5-.866A6.5 6.5 0 1 0 14.5 8a.5.5 0 0 0-1 0 5.5 5.5 0 1 1-11 0"/>
                                            <path d="M15.354 3.354a.5.5 0 0 0-.708-.708L8 9.293 5.354 6.646a.5.5 0 1 0-.708.708l3 3a.5.5 0 0 0 .708 0z"/>
                                        </svg>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:if test="./tei:noteGrp[@type='Werkbezug']">
                                        <ul>
                                            <xsl:for-each select="./tei:noteGrp[@type='Werkbezug']/tei:note">
                                                <li>
                                                    <xsl:value-of select="./text()"/>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:if>
                                </td>
                                <td>
                                    <xsl:value-of select="count(./tei:noteGrp/tei:note)"/>
                                </td>
                                <td>
                                    <xsl:value-of select="substring(./tei:title[@type='main'], 1, 1)"/>
                                </td>
                            </tr>
                        </xsl:if>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>
    
</xsl:stylesheet>
