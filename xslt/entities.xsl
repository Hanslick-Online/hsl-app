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
                                                <xsl:if test="./tei:persName[@type='main']/tei:surname">
                                                <tr>
                                                    <th>
                                                        Name
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:persName[@type='main']/tei:surname"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:persName[@type='main']/tei:forename">
                                                <tr>
                                                    <th>
                                                        Vorname
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:persName[@type='main']/tei:forename"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:persName[@type='alternative']">
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
                                                <xsl:if test="./tei:birth/tei:date">
                                                <tr>
                                                    <th>
                                                        Geburtstag
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:birth/tei:date/@when-iso"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:birth/tei:settlement">
                                                <tr>
                                                    <th>
                                                        Geburtsorg
                                                    </th>
                                                    <td>
                                                        <ul>
                                                            <xsl:for-each select="./tei:birth/tei:settlement">
                                                                <li>
                                                                    <a href="{@key}.html">
                                                                        <xsl:value-of select="./tei:placeName"/>
                                                                    </a>    
                                                                </li>
                                                            </xsl:for-each>    
                                                        </ul>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:death/tei:date">
                                                <tr>
                                                    <th>
                                                        Todestag
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:death/tei:date/@when-iso"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:death/tei:settlement">
                                                <tr>
                                                    <th>
                                                        Todesort
                                                    </th>
                                                    <td>
                                                        <ul>
                                                            <xsl:for-each select="./tei:death/tei:settlement">
                                                                <li>
                                                                    <a href="{@key}.html">
                                                                        <xsl:value-of select="./tei:placeName"/>
                                                                    </a>            
                                                                </li>   
                                                            </xsl:for-each>
                                                        </ul>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@type='GND']">
                                                <tr>
                                                    <th>
                                                        GND
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@type='GND']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@type='GND'], '/')[last()]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@type='WIKIDATA']">
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
                                                <xsl:if test="//tei:placeName[@type='alternative']">
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
                                                <xsl:if test="./tei:location[@type='located_in_place']">
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
                                                <xsl:if test="./tei:country">
                                                <tr>
                                                    <th>
                                                        Land
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:country"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:settlement">
                                                <tr>
                                                    <th>
                                                        Typ
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="./tei:settlement/@type"/>, <xsl:value-of select="./tei:desc[@type='entity_type']"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@type='GEONAMES']">
                                                <tr>
                                                    <th>
                                                        Geonames ID
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@type='GEONAMES']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@type='GEONAMES'], '/')[4]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@type='WIKIDATA']">
                                                <tr>
                                                    <th>
                                                        Wikidata ID
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@type='WIKIDATA']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@type='WIKIDATA'], '/')[last()]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@type='GND']">
                                                <tr>
                                                    <th>
                                                        GND ID
                                                    </th>
                                                    <td>
                                                        <a href="{./tei:idno[@type='GND']}" target="_blank">
                                                            <xsl:value-of select="tokenize(./tei:idno[@type='GND'], '/')[last()]"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:location">
                                                <tr>
                                                    <th>
                                                        Latitude
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="tokenize(./tei:location/tei:geo, ', ')[1]"/>
                                                    </td>
                                                </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:location">
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
                                                <xsl:if test="./tei:title[@type='main']">
                                                    <tr>
                                                        <th>
                                                            Titel
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:title[@type='main']"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:title[@type='alternative']">
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
                                                <xsl:if test="./tei:name">
                                                    <tr>
                                                        <th>
                                                            Figur(en)
                                                        </th>
                                                        <td>
                                                            <ul>
                                                                <xsl:for-each select="./tei:name[@type='character']">
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
                                                <xsl:if test="./tei:date">
                                                    <tr>
                                                        <th>
                                                            Datum
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:date"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:biblScope[@type='volume']">
                                                    <tr>
                                                        <th>
                                                            Band
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:biblScope[@type='volume']"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:biblScope[@type='chapter']">
                                                    <tr>
                                                        <th>
                                                            Kapitel
                                                        </th>
                                                        <td>
                                                            <xsl:value-of select="./tei:biblScope[@type='chapter']"/>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@type='GND']">
                                                    <tr>
                                                        <th>
                                                            GND
                                                        </th>
                                                        <td>
                                                            <a href="{./tei:idno[@type='GND']}" target="_blank">
                                                                <xsl:value-of select="tokenize(./tei:idno[@type='GND'], '/')[last()]"/>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                <xsl:if test="./tei:idno[@type='WIKIDATA']">
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
                                                </xsl:if>
                                                <xsl:if test="./tei:lang">
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
