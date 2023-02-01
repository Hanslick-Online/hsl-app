<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:import href="partials/html_navbar.xsl"/>
    <xsl:import href="partials/aot-options.xsl"/>
    <!--<xsl:import href="partials/osd-container.xsl"/>-->
    <!--<xsl:import href="partials/tei-facsimile.xsl"/>-->
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@type='main'][1]/text()"/>
        </xsl:variable>
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
                        <div class="section">
                            <xsl:call-template name="annotation-options"></xsl:call-template>
                            
                            <div class="card-body">                                
                                <xsl:for-each select=".//tei:body">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <xsl:apply-templates/>
                                        </div>
                                    </div>
                                    
                                </xsl:for-each>
                            </div>
                        </div>                       
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
                <script src="https://unpkg.com/de-micro-editor@0.2.6/dist/de-editor.min.js"></script>
                <script type="text/javascript" src="js/run.js"></script>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="tei:p">
        <p class="indentedP yes-index">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:choice">
        <span class="choice" title="{./tei:corr}"><xsl:value-of select="./tei:sic"/></span>
    </xsl:template>
    <xsl:template match="tei:lb">
        <br/>
        <xsl:if test="ancestor::tei:p">
            <a>
                <xsl:variable name="para" as="xs:int">
                    <xsl:number level="any" from="tei:body" count="tei:p"/>
                </xsl:variable>
                <xsl:variable name="lines" as="xs:int">
                    <xsl:number level="any" from="tei:body"/>
                </xsl:variable>
                <xsl:attribute name="href">
                    <xsl:text>#</xsl:text><xsl:value-of select="ancestor::tei:div/@xml:id"/><xsl:text>__p</xsl:text><xsl:value-of select="$para"/><xsl:text>__lb</xsl:text><xsl:value-of select="$lines"/>
                </xsl:attribute>
                <xsl:attribute name="name">
                    <xsl:value-of select="ancestor::tei:div/@xml:id"/><xsl:text>__p</xsl:text><xsl:value-of select="$para"/><xsl:text>__lb</xsl:text><xsl:value-of select="$lines"/>
                </xsl:attribute>
                <xsl:attribute name="id">
                    <xsl:value-of select="ancestor::tei:div/@xml:id"/><xsl:text>__p</xsl:text><xsl:value-of select="$para"/><xsl:text>__lb</xsl:text><xsl:value-of select="$lines"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="($lines mod 5) = 0">
                        <xsl:attribute name="class">
                            <xsl:text>linenumbersVisible linenumbers yes-index</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="data-lbnr">
                            <xsl:value-of select="$lines"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">
                            <xsl:text>linenumbersTransparent linenumbers yes-index</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="format-number($lines, '0000')"/>
            </a>  
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:hi">
        <xsl:choose>
            <xsl:when test="@rendition='italic'">
                <span class="italic"><xsl:apply-templates/></span>
            </xsl:when>
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
        <span class="pb">[<xsl:value-of select="@n"/>]</span>
    </xsl:template>
    <xsl:template match="tei:cit">
        <span class="cit"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:quote">
        <span class="quote"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:list[@type='unordered']">
        <xsl:choose>
            <xsl:when test="parent::tei:p|ancestor::tei:body">
                <ul>
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
        <span class="ref {@type}"><a href="{@target}"><xsl:apply-templates/></a></span>
    </xsl:template>
    <xsl:template match="tei:note">
        <xsl:choose>
            <xsl:when test="@place='foot'">
                <span>
                    <a class="anchorFoot" id="{@xml:id}_inline"></a>
                    <a href="#{@xml:id}" title="{.//text()}" class="nounderline">
                        <sup><xsl:value-of select="@n"/></sup>
                    </a>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:lg">
        <span class="vrsgrp"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:l">
        <span class="vrs"><xsl:apply-templates/><span class="vrsSep"> / </span></span>
    </xsl:template>
</xsl:stylesheet>