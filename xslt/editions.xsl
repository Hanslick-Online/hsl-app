<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:import href="partials/aot-options.xsl"/>
    <xsl:import href="partials/chapters.xsl"/>
    <xsl:import href="partials/edition.xsl"/>
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
                <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.0.0/openseadragon.min.js"></script>
            </head>
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">
                        
                        <div class="row">
                            <div class="col-md-6 facsimiles">
                                <div id="viewer-1">
                                    <!--<div id="spinner_1" class="text-center">
                                        <div class="loader"></div>
                                    </div>-->
                                    <div id="container_facs_1" style="padding:.5em;margin-top:2em;">
                                        <!-- image container accessed by OSD script -->                               
                                    </div>  
                                </div>
                            </div>
                            <div class="col-md-6 text">
                                <div class="row" style="margin:2em auto;">
                                    <div class="col-md-6" style="text-align:right;">
                                        <input type="checkbox" name="opt[]" value="separateWordSearch" checked="checked"/> W??rter einzeln suchen
                                    </div>
                                    <div class="col-md-6" style="text-align:right;">
                                        <input type="text" name="keyword" class="form-control input-sm" placeholder="Schlagwort eingeben..."/>
                                    </div>
                                </div>
                                <div class="section section-traktat" id="section-1">
                                    <div id="editor-widget">
                                        <xsl:call-template name="editions"></xsl:call-template>
                                        <xsl:call-template name="chapters"></xsl:call-template>
                                        <xsl:call-template name="annotation-options"></xsl:call-template>
                                    </div>
                                    <div class="card-header">
                                        <div class="docTitle yes-index">
                                            <a class="anchor" id="index.xml-body.1_div.0"></a>
                                            <span class="anchor-pb"></span>
                                            <span class="pb" source="{tokenize(//tei:front//tei:pb/@facs, '/')[last()]}"></span>
                                            <div class="titlePart">
                                                <xsl:for-each select=".//tei:docTitle/tei:titlePart">
                                                    <div class="titlePart {@type}">
                                                        <xsl:apply-templates/>
                                                    </div>
                                                </xsl:for-each>
                                            </div>
                                            <div class="docbyline">
                                                <xsl:for-each select=".//tei:titlePage/tei:byline">
                                                    <div class="byline">
                                                        <xsl:apply-templates/>
                                                    </div>
                                                </xsl:for-each>
                                            </div>
                                            <div class="imprint">
                                                <xsl:for-each select=".//tei:titlePage/tei:docImprint">
                                                    <div class="docImprint">
                                                        <xsl:apply-templates/>
                                                    </div>
                                                </xsl:for-each>
                                            </div>
                                            <div class="milestone">
                                                <xsl:for-each select="//tei:titlePage/tei:milestone">
                                                    <div class="milestone">
                                                        <xsl:text>***</xsl:text>
                                                    </div>
                                                </xsl:for-each>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card-body yes-index">                                
                                        <xsl:for-each select=".//tei:body/tei:div">
                                            
                                            <a class="anchor" id="index.xml-body.1_div.{position()}"></a>
                                            <xsl:apply-templates/>

                                        </xsl:for-each>
                                    </div>
                                    <div class="card-footer yes-index">
                                        <a class="anchor" id="index.xml-body.1_div.999"></a>
                                        <h5>Fu??noten</h5>
                                        <ul class="footnotes">
                                            <xsl:for-each select=".//tei:body//tei:note[@place='foot']">
                                                <li>
                                                    <a class="anchorFoot" id="{@xml:id}"></a>
                                                    <span class="footnote_link">
                                                        <a href="#{@xml:id}_inline" class="nounderline">
                                                            <xsl:value-of select="@n"/>
                                                        </a>
                                                    </span>
                                                    <span class="footnote_text">
                                                        <xsl:apply-templates select="node() except tei:pb"/>
                                                    </span>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                        
                                    </div>
                                </div>
                                <xsl:for-each select="//tei:back">
                                    <div class="tei-back">
                                        
                                        <xsl:apply-templates/>
                                        
                                    </div>
                                </xsl:for-each>
                            </div>
                        </div>
                        
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
                <script src="https://unpkg.com/de-micro-editor@0.2.6/dist/de-editor.min.js"></script>
                <script type="text/javascript" src="js/run.js"></script>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/mark.js/8.11.1/mark.min.js"></script>
                <script type="text/javascript" src="js/mark.js"></script>
                <script type="text/javascript" src="js/osd.js"></script>
            </body>
        </html>
    </xsl:template>
                  
    
    <xsl:template match="tei:head">
        <h3 class="yes-index">
            <!--<xsl:choose>
                <xsl:when test="contains(. ,'a)')">
                    <xsl:variable name="chapter" select="tokenize(., 'I')"/>
                    I. <xsl:value-of select="$chapter[2]"/>
                    <br/>
                    I. <xsl:value-of select="$chapter[3]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>-->
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    
    <xsl:template match="tei:byline">
        <xsl:if test="ancestor::tei:body">
            <p class="yes-index"><xsl:apply-templates/></p>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:p">
        <p id="{@xml:id}" class="indentedP yes-index">
            <a>
                <xsl:choose>
                    <xsl:when test="@n">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('diff_', @n, '.html')"/>
                        </xsl:attribute>
                        <xsl:attribute name="class">
                            <xsl:text>parNum nounderline</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">
                            <xsl:text>noParNum nounderline</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="replace(@n, 'xyz', '')"/>
            </a>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>
    <xsl:template match="tei:emph">
        <xsl:choose>
            <xsl:when test="starts-with(following-sibling::text()[1], ',') or 
                starts-with(following-sibling::text()[1], '??') or
                starts-with(following-sibling::text()[1], '.')">
                <em class="comma"><xsl:apply-templates/></em>
            </xsl:when>
            <xsl:when test="matches(preceding-sibling::text()[1], '\w+')">
                <em class="prev-text"><xsl:apply-templates/></em>
            </xsl:when>
            <xsl:otherwise>
                <em><xsl:apply-templates/></em>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:rs">
        <xsl:choose>
            <xsl:when test="count(tokenize(@ref, ' ')) > 1">
                <xsl:choose>
                    <xsl:when test="@type='person'">
                        <span class="persons {substring-after(@rendition, '#')}" id="{@xml:id}">
                            <xsl:apply-templates/>
                            <xsl:for-each select="tokenize(@ref, ' ')">
                                <sup class="entity" data-bs-toggle="modal" data-bs-target="{.}">
                                    <xsl:value-of select="position()"/>
                                </sup>
                                <xsl:if test="position() != last()">
                                    <sup class="entity">/</sup>
                                </xsl:if>
                            </xsl:for-each>
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='place'">
                        <span class="places {substring-after(@rendition, '#')}" id="{@xml:id}">
                            <xsl:apply-templates/>
                            <xsl:for-each select="tokenize(@ref, ' ')">
                                <sup class="entity" data-bs-toggle="modal" data-bs-target="{.}">
                                    <xsl:value-of select="position()"/>
                                </sup>
                                <xsl:if test="position() != last()">
                                    <sup class="entity">/</sup>
                                </xsl:if>
                            </xsl:for-each>
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='bibl'">
                        <span class="works {substring-after(@rendition, '#')}" id="{@xml:id}">
                            <xsl:apply-templates/>
                            <xsl:for-each select="tokenize(@ref, ' ')">
                                <sup class="entity" data-bs-toggle="modal" data-bs-target="{.}">
                                    <xsl:value-of select="position()"/>
                                </sup>
                                <xsl:if test="position() != last()">
                                    <sup class="entity">/</sup>
                                </xsl:if>
                            </xsl:for-each>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@type='person'">
                        <span class="persons entity {substring-after(@rendition, '#')}" id="{@xml:id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='place'">
                        <span class="places entity {substring-after(@rendition, '#')}" id="{@xml:id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='bibl'">
                        <span class="works entity {substring-after(@rendition, '#')}" id="{@xml:id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:pb">
        <xsl:choose>
            <xsl:when test="ancestor::tei:p and not(preceding-sibling::tei:list)">
                <span class="anchor-pb"></span>
                <span class="pb" source="{tokenize(@facs, '/')[last()]}"><xsl:value-of select="@n"/></span>
            </xsl:when>
            <xsl:when test="ancestor::tei:p and preceding-sibling::tei:list">
                <span class="anchor-pb"></span>
                <p class="indentedP"><span class="pb" source="{tokenize(@facs, '/')[last()]}"><xsl:value-of select="@n"/></span></p>
            </xsl:when>
            <xsl:when test="ancestor::tei:list">
                <span class="anchor-pb"></span>
                <span class="pb" source="{tokenize(@facs, '/')[last()]}"><xsl:value-of select="@n"/></span>
            </xsl:when>
            <xsl:when test="ancestor::tei:note">
                <span class="anchor-pb"></span>
                <span class="pb" source="{tokenize(@facs, '/')[last()]}"><xsl:value-of select="@n"/></span>
            </xsl:when>
            <xsl:otherwise>
                <p class="indentedP"><span class="anchor-pb"></span><span class="pb" source="{tokenize(@facs, '/')[last()]}"><xsl:value-of select="@n"/></span></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:cit">
        <cite><xsl:apply-templates/></cite>
    </xsl:template>
    <xsl:template match="tei:quote">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:list[@type='unordered']">
        <xsl:choose>
            <xsl:when test="parent::tei:p|ancestor::tei:body">
                <ul class="yes-index">
                    <xsl:apply-templates/>
                </ul>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:item">
        <xsl:choose>
            <xsl:when test="parent::tei:list[@type='unordered']|ancestor::tei:body">
                <li><xsl:apply-templates/></li>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:date">
        <span class="date"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="@type='edition'">
                <a class="ref {@type}" href="t__{@target}"><xsl:apply-templates/></a>
            </xsl:when>
            <xsl:otherwise>
                <a class="ref {@type}" href="{@target}"><xsl:apply-templates/></a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:note">
        <xsl:choose>
            <xsl:when test="@place='foot'">
                <a class="anchorFoot" id="{@xml:id}_inline"></a>
                <a href="#{@xml:id}" title="Fu??note {@n}" class="nounderline">
                    <sup><xsl:value-of select="@n"/></sup>
                </a>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:notatedMusic">
        <xsl:choose>
            <xsl:when test="parent::tei:p">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <figure class="figure padding-20">
                    <xsl:apply-templates/>
                </figure>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:graphic">
        <xsl:choose>
            <xsl:when test="ancestor::tei:p">
                <img class="figure padding-20" src="{@url}" alt="Grafik eines Notenbeispiels"/>
            </xsl:when>
            <xsl:otherwise>
                <img src="{@url}" alt="Grafik eines Notenbeispiels"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:lg">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:l">
        <xsl:apply-templates/><xsl:text> / </xsl:text>
    </xsl:template>
    <xsl:template match="tei:listPerson">
        <xsl:for-each select="./tei:person">
            <div class="modal fade" id="{@xml:id}" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="{concat(./tei:persName/tei:surname, ', ', ./tei:persName/tei:forename)}" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="staticBackdropLabel"><xsl:value-of select="concat(./tei:persName/tei:surname, ', ', ./tei:persName/tei:forename)"/></h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <table class="table">
                                <tbody>
                                    <tr>
                                        <th>
                                            GND
                                        </th>
                                        <td>
                                            <a href="{./tei:idno[@type='GND']}" target="_blank">
                                                <xsl:value-of select="./tei:idno[@type='GND']"/>
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>
                                            Weiterlesen
                                        </th>
                                        <td>
                                            <a href="{concat(@xml:id, '.html')}">
                                                Details
                                            </a>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:listPlace">
        <xsl:for-each select="./tei:place">
            <div class="modal fade" id="{@xml:id}" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="{if(./tei:settlement) then(./tei:settlement/tei:placeName) else (./tei:placeName)}" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="staticBackdropLabel"><xsl:value-of select="if(./tei:settlement) then(./tei:settlement/tei:placeName) else (./tei:placeName)"/></h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <table class="table">
                                <tbody>
                                    <tr>
                                        <th>
                                            Land
                                        </th>
                                        <td>
                                            <xsl:value-of select="./tei:country"/>
                                        </td>
                                    </tr>
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
                                    <tr>
                                        <th>
                                            Weiterlesen
                                        </th>
                                        <td>
                                            <a href="{concat(@xml:id, '.html')}">
                                                Details
                                            </a>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="tei:listBibl">
        <xsl:for-each select="./tei:bibl">
            <div class="modal fade" id="{@xml:id}" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="{./tei:title[@type='main']}" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="staticBackdropLabel"><xsl:value-of select="./tei:title"/></h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <table class="table">
                                <tbody>
                                    
                                    <tr>
                                        <th>
                                            Autor(en)
                                        </th>
                                        <td>
                                            <ul>
                                                <xsl:for-each select="./tei:author">
                                                    <li>
                                                        <a href="{@xml:id}.html">
                                                            <xsl:value-of select="./tei:persName"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </td>
                                    </tr>
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
                                    <tr>
                                        <th>
                                            Weiterlesen
                                        </th>
                                        <td>
                                            <a href="{concat(@xml:id, '.html')}">
                                                Details
                                            </a>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>