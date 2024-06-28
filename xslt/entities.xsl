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
        <xsl:choose>
            <xsl:when test="contains($doc_title, 'Personenregister')">
                <xsl:for-each select="//tei:person">
                    <xsl:variable name="doc_url" select="concat(@xml:id, '.html')"/>
                    <xsl:result-document href="{$doc_url}">
                        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
                        <html>
                            <head>
                                <xsl:call-template name="html_head">
                                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                                </xsl:call-template>
                            </head>
                            <body class="page">
                                <div class="hfeed site" id="page">
                                    <xsl:call-template name="nav_bar"/>
                                    
                                    <div class="container-fluid">
                                            
                                        <table class="table entity-table">
                                            <tbody>
                                                <xsl:if test="./tei:persName[@type='main']/tei:surname/text()">
                                                <tr>
                                                    <th>
                                                        Name
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:persName[@type='main']/tei:surname"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:persName[@type='main']/tei:forename/text()">
                                                <tr>
                                                    <th>
                                                        Vorname
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:persName[@type='main']/tei:forename"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:persName[@type='alternative']/tei:surname/text() or
                                                    .           /tei:persName[@type='alternative']/tei:forename/text()">
                                                    <tr>
                                                        <th>
                                                            Name (alt)
                                                        </th>
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
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="@role">
                                                    <tr>
                                                        <th>
                                                            Funktion
                                                        </th>
                                                        <td>
                                                            Figur
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:birth/text()">
                                                <tr>
                                                    <th>
                                                        Lebensdaten
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:birth"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:occupation/text()">
                                                    <tr>
                                                        <th>
                                                            Beschreibung
                                                        </th>
                                                        <td>
                                                            <ul>
                                                                <xsl:for-each select="./tei:occupation">
                                                                    <li><xsl:value-of select="./text()"/></li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='GND']/text()">
                                                <tr>
                                                    <th>
                                                        GND
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@subtype='GND']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@subtype='GND'], '/')[last()]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='WIKIDATA']/text()">
                                                <tr>
                                                    <th>
                                                        Wikidata
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@subtype='WIKIDATA']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@subtype='WIKIDATA'], '/')[last()]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='OEML']/text()">
                                                    <tr>
                                                        <th>
                                                            Österreichisches Musiklexikon
                                                        </th>
                                                        <td>
                                                            <a href="{./tei:idno[@subtype='OEML']}" target="_blank">
                                                                <xsl:value-of select="tokenize(./tei:idno[@subtype='OEML'], '/')[last()]"/>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='OEBL']/text()">
                                                    <tr>
                                                        <th>
                                                            Österreichisches Biographisches Lexikon
                                                        </th>
                                                        <td>
                                                            <a href="{./tei:idno[@subtype='OEBL']}" target="_blank">
                                                                <xsl:value-of select="tokenize(./tei:idno[@subtype='OEBL'], '/')[last()]"/>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:listBibl[@type='authorOf']">
                                                <tr>
                                                    <th>
                                                        Werke (Schöpfer)
                                                    </th>
                                                    <td>
                                                        <ul>
                                                            <xsl:for-each select="./tei:listBibl/tei:bibl">
                                                                <xsl:sort select="." data-type="text"/>
                                                                <li>
                                                                    <a href="{concat(@n, '.html')}">
                                                                        <xsl:value-of select="."/>
                                                                    </a>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:listBibl[@type='characterOf']">
                                                    <tr>
                                                        <th>
                                                            Werke (Figur)
                                                        </th>
                                                        <td>
                                                            <ul>
                                                                <xsl:for-each select="./tei:listBibl/tei:bibl">
                                                                    <xsl:sort select="." data-type="text"/>
                                                                    <li>
                                                                        <a href="{concat(@n, '.html')}">
                                                                            <xsl:value-of select="."/>
                                                                        </a>
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:noteGrp">
                                                <tr>
                                                    <th>
                                                        Erwähnt in
                                                    </th>
                                                    <td>
                                                        <ul>
                                                            <xsl:for-each select="./tei:noteGrp/tei:note">
                                                                <li>
                                                                    <a href="{replace(@target, '.xml', '.html')}">
                                                                        <xsl:value-of select="./text()"/>
                                                                    </a>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="@cert">
                                                    <tr>
                                                        <th>
                                                            Überprüft
                                                        </th>
                                                        <td>
                                                            <xsl:choose>
                                                                <xsl:when test="@cert='high'">
                                                                    mehrfach
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    einmalig
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                            </tbody>
                                        </table>
                                           
                                    </div><!-- .container-fluid -->
                                    <xsl:call-template name="html_footer"/>
                                </div><!-- .site -->
                            </body>
                        </html>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="contains($doc_title, 'Ortsregister')">
                <xsl:for-each select="//tei:place">
                    <xsl:variable name="doc_url" select="concat(@xml:id, '.html')"/>
                    <xsl:result-document href="{$doc_url}">
                        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
                        <html>
                            <head>
                                <xsl:call-template name="html_head">
                                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                                </xsl:call-template>
                            </head>
                            <body class="page">
                                <div class="hfeed site" id="page">
                                    <xsl:call-template name="nav_bar"/>
                                    
                                    <div class="container-fluid">  
                                        
                                        
                                        <table class="table entity-table">
                                            <tbody>
                                                <tr>
                                                    <th>
                                                        Ortsname
                                                    </th>
                                                    <td>
                                                        <xsl:choose>
                                                            <xsl:when test="./tei:settlement/tei:placeName[@type='main']">
                                                                <xsl:value-of select="./tei:settlement/tei:placeName[@type='main']"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="./tei:placeName[@type='main']"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                                <xsl:if test="//tei:placeName[@type='alternative']/text()">
                                                    <tr>
                                                        <th>
                                                            Ortsname (alt)
                                                        </th>
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
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:location[@type='located_in_place']/text()">
                                                    <tr>
                                                        <th>
                                                            Teil von
                                                        </th>
                                                        <td>
                                                            <ul>
                                                                <xsl:for-each select="./tei:location[@type='located_in_place']">
                                                                    
                                                                    <li>
                                                                        <a href="{./tei:placeName/@key}.html">
                                                                            <xsl:value-of select="./tei:placeName"/>
                                                                        </a>            
                                                                    </li>
                                                                    
                                                                </xsl:for-each>
                                                            </ul>
                                                        </td>
                                                    </tr>
                                                </xsl:if> 
                                                <xsl:if test="./tei:country/text()">
                                                <tr>
                                                    <th>
                                                        Land
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:country"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:settlement/text()">
                                                <tr>
                                                    <th>
                                                        Typ
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:settlement/@type"/>, <xsl:value-of select="./tei:desc[@type='entity_type']"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='GEONAMES']/text()">
                                                <tr>
                                                    <th>
                                                        Geonames ID
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@subtype='GEONAMES']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@subtype='GEONAMES'], '/')[4]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='WIKIDATA']/text()">
                                                <tr>
                                                    <th>
                                                        Wikidata ID
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@subtype='WIKIDATA']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@subtype='WIKIDATA'], '/')[last()]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='GND']/text()">
                                                <tr>
                                                    <th>
                                                        GND ID
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@subtype='GND']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@subtype='GND'], '/')[last()]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:location/tei:geo/text()">
                                                <tr>
                                                    <th>
                                                        Latitude
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="tokenize(./tei:location/tei:geo, ', ')[1]"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:location/tei:geo/text()">
                                                <tr>
                                                    <th>
                                                        Longitude
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="tokenize(./tei:location/tei:geo, ', ')[2]"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:noteGrp">
                                                    <tr>
                                                        <th>
                                                            Erwähnt in
                                                        </th>
                                                        <td>
                                                            <ul>
                                                                <xsl:for-each select="./tei:noteGrp/tei:note">
                                                                    <li>
                                                                        <a href="{replace(@target, '.xml', '.html')}">
                                                                            <xsl:value-of select="./text()"/>
                                                                        </a>
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="@cert">
                                                    <tr>
                                                        <th>
                                                            Überprüft
                                                        </th>
                                                        <td>
                                                            <xsl:choose>
                                                                <xsl:when test="@cert='high'">
                                                                    mehrfach
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    einmalig
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                            </tbody>
                                        </table>
                                        
                                    </div><!-- .container-fluid -->
                                    <xsl:call-template name="html_footer"/>
                                </div><!-- .site -->
                            </body>
                        </html>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="contains($doc_title, 'Werkregister')">
                <xsl:for-each select="//tei:bibl">
                    <xsl:variable name="doc_url" select="concat(@xml:id, '.html')"/>
                    <xsl:result-document href="{$doc_url}">
                        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
                        <html>
                            <head>
                                <xsl:call-template name="html_head">
                                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                                </xsl:call-template>
                            </head>
                            <body class="page">
                                <div class="hfeed site" id="page">
                                    <xsl:call-template name="nav_bar"/>
                                    
                                    <div class="container-fluid">  
                                        
                                        <table class="table entity-table">
                                            <tbody>
                                                <xsl:if test="./tei:title[@type='main']/text()">
                                                    <tr>
                                                        <th>
                                                            Titel
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:title[@type='main']"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:title[@type='alternative']/text()">
                                                    <tr>
                                                        <th>
                                                            Titel (alt)
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:title[@type='alternative']"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:author">
                                                    <tr>
                                                        <th>
                                                            Autor(en)
                                                        </th>
                                                        <td>
                                                            <ul>
                                                                <xsl:for-each select="./tei:author">
                                                                    <xsl:sort select="./tei:persName" data-type="text" order="ascending"/>
                                                                    <li>
                                                                        <a href="{substring-after(@ref, '#')}.html">
                                                                            <xsl:value-of select="./tei:persName"/>
                                                                        </a>        
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </td>
                                                    </tr>    
                                                </xsl:if>
                                                <xsl:if test="./tei:name[@type='character']">
                                                    <tr>
                                                        <th>
                                                            Figur(en)
                                                        </th>
                                                        <td>
                                                            <ul>
                                                                <xsl:for-each select="./tei:name[@type='character']">
                                                                    <xsl:sort select="." data-type="text" order="ascending"/>
                                                                    <li>
                                                                        <a href="{substring-after(@ref, '#')}.html">
                                                                            <xsl:value-of select="."/>
                                                                        </a>        
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </td>
                                                    </tr>    
                                                </xsl:if>
                                                <xsl:if test="./tei:date/text()">
                                                    <tr>
                                                        <th>
                                                            Datum
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:date"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:biblScope[@type='volume']/text()">
                                                    <tr>
                                                        <th>
                                                            Band
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:biblScope[@type='volume']"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:biblScope[@type='chapter']/text()">
                                                    <tr>
                                                        <th>
                                                            Kapitel
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:biblScope[@type='chapter']"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='GND']/text()">
                                                    <tr>
                                                        <th>
                                                            GND
                                                        </th>
                                                        <td>
                                                            <a href="{./tei:idno[@subtype='GND']}" target="_blank">
                                                                <xsl:value-of select="tokenize(./tei:idno[@subtype='GND'], '/')[last()]"/>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@subtype='Digitalisat']/text()">
                                                    <tr>
                                                        <th> Digitalisat </th>
                                                        <td>
                                                            vorhanden
                                                            <!--<ul>
                                                                <xsl:for-each select="./tei:idno[@subtype = 'Digitalisat']">
                                                                    <li>
                                                                        <a href="{./text()}"
                                                                            target="_blank">
                                                                            <xsl:value-of
                                                                                select="./text()"
                                                                            />
                                                                        </a>
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>-->
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <!--<xsl:if test="./tei:idno[@type='WIKIDATA']">
                                                    <tr>
                                                        <th>
                                                            Wikidata
                                                        </th>
                                                        <td>
                                                            <a href="{./tei:idno[@type='WIKIDATA']}" target="_blank">
                                                                <xsl:value-of select="tokenize(./tei:idno[@type='WIKIDATA'], '/')[last()]"/>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:if>-->
                                                <xsl:if test="./tei:lang/text()">
                                                    <tr>
                                                        <th>
                                                            Sprache
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:lang"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:noteGrp">
                                                    <tr>
                                                        <th>
                                                            Erwähnt in
                                                        </th>
                                                        <td>
                                                            <ul>
                                                                <xsl:for-each select="./tei:noteGrp/tei:note">
                                                                    <li>
                                                                        <a href="{replace(@target, '.xml', '.html')}">
                                                                            <xsl:value-of select="./text()"/>
                                                                        </a>
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="@cert">
                                                    <tr>
                                                        <th>
                                                            Überprüft
                                                        </th>
                                                        <td>
                                                            <xsl:choose>
                                                                <xsl:when test="@cert='high'">
                                                                    mehrfach
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    einmalig
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                            </tbody>
                                        </table>
                                        
                                    </div><!-- .container-fluid -->
                                    <xsl:call-template name="html_footer"/>
                                </div><!-- .site -->
                            </body>
                        </html>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
            
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
