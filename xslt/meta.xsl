<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="tei xsl xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[1]/text()"/>
        </xsl:variable>

        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
            </head>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid" style="margin-top:1em;">
                        <div class="row">
                            <div class="col-md-12">
                               <xsl:for-each select="//tei:body/tei:div[@type='main']">
                                   <div class="main">
                                       <xsl:apply-templates/>
                                   </div>
                               </xsl:for-each>
                            </div>
                        </div>
                        
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:div/tei:head">
        <h2 id="{generate-id()}" class="meta-h"><xsl:apply-templates/></h2>
    </xsl:template>
    <xsl:template match="tei:byline">
        <h5 class="meta-h"><xsl:apply-templates/></h5>
    </xsl:template>
    <xsl:template match="tei:figure/tei:head">
        <span class="figure_text"><small><xsl:apply-templates/></small></span>
    </xsl:template>
    <xsl:template match="tei:div[@type='inline']">
        <div class="seg-inline"><xsl:apply-templates/></div>
    </xsl:template>
    <xsl:template match="tei:div[@type='block']">
        <div class="seg-block"><xsl:apply-templates/></div>
    </xsl:template>
    <xsl:template match="tei:div[@type='sub']">
        <div class="seg-sub"><xsl:apply-templates/></div>
    </xsl:template>
    <xsl:template match="tei:p">
        <p id="{generate-id()}" class="meta-p"><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="tei:list">
        <ul id="{generate-id()}" class="meta-l"><xsl:apply-templates/></ul>
    </xsl:template>
    
    <xsl:template match="tei:item">
        <li id="{generate-id()}"><xsl:apply-templates/></li>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="child::tei:figure">
                <a class="ref-figure" target="_blank">
                    <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <a target="_blank">
                    <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:figure">
        <figure class="figure-inline">
            <xsl:apply-templates/>
        </figure>
    </xsl:template>
    <xsl:template match="tei:graphic">
        <img src="{@url}" alt="{parent::tei:figure/tei:head}"></img>
    </xsl:template>
    
</xsl:stylesheet>