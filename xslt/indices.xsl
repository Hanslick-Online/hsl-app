<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="no" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>

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
                </style>
            </head>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">
                        <h1 style="text-align: center;margin: 2em auto;"><xsl:value-of select="$doc_title"/></h1>
                        
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
                <xsl:choose>
                    <xsl:when test="contains($doc_title, 'Personenregister')">
                        <script type="text/javascript" src="js/dt-panes.js"></script>
                        <script type="text/javascript">
                            $(document).ready(function () {
                                createDataTable('listperson', 'Suche:', [2, 3, 5, 12], [0, 1, 4, 6, 7, 8, 9, 10, 11], [12]);
                            });
                        </script>
                    </xsl:when>
                    <xsl:when test="contains($doc_title, 'Ortsregister')">
                        
                        <script src="js/leaflet.js"></script>
                        <script type="text/javascript">
                            $(document).ready(function () {
                                leafletDatatable('listplace', [6, 7, 8], [0, 1, 2, 3, 4, 5]);
                            });
                        </script>
                    </xsl:when>
                    <xsl:when test="contains($doc_title, 'Werkregister')">
                        <script type="text/javascript" src="js/dt-panes.js"></script>
                        <script type="text/javascript">
                            $(document).ready(function () {
                                createDataTable('listbibl', 'Suche:', [2, 3, 5, 6], [0, 1, 4], [6]);
                            });
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
                        <th>GND ID</th>
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
                                    <a href="{./tei:idno[@subtype='GND']}" target="_blank">
                                        <xsl:value-of select="tokenize(./tei:idno[@subtype='GND'], '/')[last()]"/>
                                    </a>
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
