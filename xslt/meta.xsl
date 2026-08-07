<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:hsl="https://hanslick.acdh.oeaw.ac.at/ns/hsl"
    version="2.0" exclude-result-prefixes="tei xsl xs hsl">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/i18n-utils.xsl"/>
    <xsl:import href="./partials/html_navbar_i18n.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer_i18n.xsl"/>
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="starts-with(string((//tei:body/@xml:lang)[1]), 'en')">
                <xsl:call-template name="redirect-page">
                    <xsl:with-param name="canonicalPath" select="hsl:canonical-html-from-source(tokenize(document-uri(/), '/')[last()])"/>
                    <xsl:with-param name="defaultLang" select="'en'"/>
                    <xsl:with-param name="htmlTitle" select="'Redirecting to page'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="doc_title_de" select="string(.//tei:title[1])"/>
                <xsl:variable name="partnerUri" select="hsl:partner-meta-uri(document-uri(/))"/>
                <xsl:variable name="doc_en" select="if ($partnerUri) then document($partnerUri) else ()"/>
                <xsl:variable name="doc_title_en" select="if ($doc_en) then string($doc_en//tei:title[1]) else $doc_title_de"/>

                <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
                <html xmlns="http://www.w3.org/1999/xhtml" lang="de" data-has-english="{if ($doc_en) then 'true' else 'false'}" data-title-de="{$doc_title_de}" data-title-en="{$doc_title_en}">
                    <head>
                        <xsl:call-template name="html_head">
                            <xsl:with-param name="html_title" select="$doc_title_de"></xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="meta_extra_head"/>
                    </head>
                    <body class="page">
                        <div class="hfeed site" id="page">
                            <xsl:call-template name="nav_bar_i18n"/>
                            
                            <div class="container-fluid" style="margin-top:1em;">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="main" data-lang="de" id="content">
                                            <xsl:apply-templates select="//tei:body/tei:div[@type='main']" mode="meta-content">
                                                <xsl:with-param name="content-lang" tunnel="yes" select="'de'"/>
                                                <xsl:with-param name="id-prefix" tunnel="yes" select="'de-'"/>
                                            </xsl:apply-templates>
                                        </div>
                                        <xsl:if test="$doc_en">
                                            <div class="main" data-lang="en" hidden="hidden" id="content-en">
                                                <xsl:apply-templates select="$doc_en//tei:body/tei:div[@type='main']" mode="meta-content">
                                                    <xsl:with-param name="content-lang" tunnel="yes" select="'en'"/>
                                                    <xsl:with-param name="id-prefix" tunnel="yes" select="'en-'"/>
                                                </xsl:apply-templates>
                                            </div>
                                        </xsl:if>
                                    </div>
                                </div>
                            </div>
                            
                            <xsl:call-template name="html_footer_i18n"/>
                        </div>
                        <xsl:call-template name="meta_extra_scripts"/>
                    </body>
                </html>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="meta_extra_head"/>

    <xsl:template name="meta_extra_scripts"/>

    <xsl:template match="tei:div[@type='main']/tei:head" mode="meta-content">
        <xsl:param name="id-prefix" tunnel="yes" as="xs:string"/>
        <h1 id="{concat($id-prefix, generate-id())}" class="py-4 meta-h"><xsl:apply-templates mode="meta-content"/></h1>
    </xsl:template>    
    <xsl:template match="tei:div[@type='block']/tei:head" mode="meta-content">
        <xsl:param name="id-prefix" tunnel="yes" as="xs:string"/>
        <h2 id="{concat($id-prefix, generate-id())}" class="py-4 meta-h"><xsl:apply-templates mode="meta-content"/></h2>
    </xsl:template>
    <xsl:template match="tei:div[@type='sub']/tei:head" mode="meta-content">
        <xsl:param name="id-prefix" tunnel="yes" as="xs:string"/>
        <h2 id="{concat($id-prefix, generate-id())}" class="py-4 meta-h"><xsl:apply-templates mode="meta-content"/></h2>
    </xsl:template>
    <xsl:template match="tei:byline" mode="meta-content">
        <h5 class="meta-h"><xsl:apply-templates mode="meta-content"/></h5>
    </xsl:template>
    <xsl:template match="tei:figure/tei:head" mode="meta-content">
        <span class="figure_text"><small><xsl:apply-templates mode="meta-content"/></small></span>
    </xsl:template>
    <xsl:template match="tei:div[@type='inline']" mode="meta-content">
        <div class="seg-inline"><xsl:apply-templates mode="meta-content"/></div>
    </xsl:template>
    <xsl:template match="tei:div[@type='block']" mode="meta-content">
        <div class="seg-block"><xsl:apply-templates mode="meta-content"/></div>
    </xsl:template>
    <xsl:template match="tei:div[@type='sub']" mode="meta-content">
        <div class="seg-sub"><xsl:apply-templates mode="meta-content"/></div>
    </xsl:template>
    <xsl:template match="tei:p" mode="meta-content">
        <xsl:param name="id-prefix" tunnel="yes" as="xs:string"/>
        <p id="{concat($id-prefix, generate-id())}" class="meta-p"><xsl:apply-templates mode="meta-content"/></p>
    </xsl:template>
    <xsl:template match="tei:list" mode="meta-content">
        <xsl:param name="id-prefix" tunnel="yes" as="xs:string"/>
        <ul id="{concat($id-prefix, generate-id())}" class="meta-l {if(parent::tei:item) then('') else('pad-4')}"><xsl:apply-templates mode="meta-content"/></ul>
    </xsl:template>
    <xsl:template match="tei:hi" mode="meta-content">
        <span class="{@rend}"><xsl:apply-templates mode="meta-content"/></span>
    </xsl:template>
    <xsl:template match="tei:emph" mode="meta-content">
        <span class="italic"><xsl:apply-templates mode="meta-content"/></span>
    </xsl:template>
    <xsl:template match="tei:item" mode="meta-content">
        <xsl:param name="id-prefix" tunnel="yes" as="xs:string"/>
        <li id="{concat($id-prefix, generate-id())}"><xsl:apply-templates mode="meta-content"/></li>
    </xsl:template>
    <xsl:template match="tei:ref" mode="meta-content">
        <xsl:param name="content-lang" tunnel="yes" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="@type='mail'">
                <a>
                    <xsl:attribute name="href"><xsl:value-of select="concat('mailto:', @target)"/></xsl:attribute>
                    <xsl:apply-templates mode="meta-content"/>
                </a>
            </xsl:when>
            <xsl:when test="@type='video'">
                <xsl:apply-templates mode="meta-content"/>
                <br></br>
                <iframe width="480" height="270" src="{@target}" title="{text()}"></iframe>
            </xsl:when>
            <xsl:when test="child::tei:figure">
                <a class="ref-figure" target="_blank">
                    <xsl:attribute name="href"><xsl:value-of select="hsl:localize-target(string(@target), $content-lang)"/></xsl:attribute>
                    <xsl:apply-templates mode="meta-content"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <a target="_blank">
                    <xsl:attribute name="href"><xsl:value-of select="hsl:localize-target(string(@target), $content-lang)"/></xsl:attribute>
                    <xsl:apply-templates mode="meta-content"/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:figure" mode="meta-content">
        <figure class="figure-inline">
            <xsl:apply-templates mode="meta-content"/>
        </figure>
    </xsl:template>
    <xsl:template match="tei:graphic" mode="meta-content">
        <img src="{@url}" alt="{parent::tei:figure/tei:head}"></img>
    </xsl:template>
    <xsl:template match="text()" mode="meta-content">
        <xsl:value-of select="."/>
    </xsl:template>
    
</xsl:stylesheet>