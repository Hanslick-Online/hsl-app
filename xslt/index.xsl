<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:hsl="https://hanslick.acdh.oeaw.ac.at/ns/hsl"
    version="2.0" exclude-result-prefixes="tei xsl xs hsl">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/i18n-utils.xsl"/>
    <xsl:import href="./partials/html_navbar_i18n.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer_i18n.xsl"/>
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="starts-with(//tei:body/@xml:lang, 'en')">
                <xsl:call-template name="redirect-page">
                    <xsl:with-param name="canonicalPath" select="'index.html'"/>
                    <xsl:with-param name="defaultLang" select="'en'"/>
                    <xsl:with-param name="htmlTitle" select="'Redirecting to homepage'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="doc_title_de" select="string(.//tei:titleStmt//tei:title[1])"/>
                <xsl:variable name="partnerUri" select="hsl:partner-meta-uri(document-uri(/))"/>
                <xsl:variable name="doc_en" select="if ($partnerUri) then document($partnerUri) else ()"/>
                <xsl:variable name="doc_title_en" select="if ($doc_en) then string($doc_en//tei:titleStmt//tei:title[1]) else $doc_title_de"/>

                <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
                <html xmlns="http://www.w3.org/1999/xhtml" lang="de" data-has-english="{if ($doc_en) then 'true' else 'false'}" data-title-de="{$doc_title_de}" data-title-en="{$doc_title_en}">
                    <head>
                        <xsl:call-template name="html_head">
                            <xsl:with-param name="html_title" select="$doc_title_de"></xsl:with-param>
                        </xsl:call-template>
                    </head>
                    <body class="page">
                        <div class="hfeed site" id="page">
                            <xsl:call-template name="nav_bar_i18n"/>

                            <div class="row" style="margin:0 auto;padding:0;">
                                <div class="col-md-5 intro_colum" style="margin:0;padding:0;">
                                    <xsl:call-template name="render-index-copy">
                                        <xsl:with-param name="doc" select="/"/>
                                        <xsl:with-param name="lang" select="'de'"/>
                                    </xsl:call-template>
                                    <xsl:if test="$doc_en">
                                        <xsl:call-template name="render-index-copy">
                                            <xsl:with-param name="doc" select="$doc_en"/>
                                            <xsl:with-param name="lang" select="'en'"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </div>
                                <div class="col-md-7 i_img_cl" style="margin:0;padding:0;">
                                    <div class="intro_image">
                                        <img src="images/thumbnail.jpg" alt="Hanslick Online Hintergrundbild"/>
                                    </div>
                                </div>
                            </div>

                            <xsl:call-template name="html_footer_i18n"/>
                        </div>
                        <script src="js/hide-md.js"></script>
                    </body>
                </html>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="render-index-copy">
        <xsl:param name="doc" as="node()"/>
        <xsl:param name="lang" as="xs:string"/>
        <xsl:variable name="isDe" select="$lang = 'de'"/>
        <xsl:variable name="heading" select="if ($isDe) then 'Digitale Edition' else 'Digital Edition'"/>
        <xsl:variable name="treatise" select="if ($isDe) then 'Traktat' else 'Treatise'"/>
        <xsl:variable name="reviews" select="if ($isDe) then 'Kritiken' else 'Reviews'"/>
        <xsl:variable name="vms" select="if ($isDe) then 'Kritiken von ' else 'Reviews of '"/>
        <xsl:variable name="docs" select="if ($isDe) then 'Dokumente zu ' else 'Documents on '"/>
        <xsl:variable name="showMore" select="if ($isDe) then 'mehr anzeigen' else 'show more'"/>
        <xsl:variable name="showLess" select="if ($isDe) then 'weniger anzeigen' else 'show less'"/>
        <div class="intro_text" data-lang="{$lang}">
            <xsl:if test="not($isDe)">
                <xsl:attribute name="hidden">hidden</xsl:attribute>
            </xsl:if>
            <h1 id="{concat('content-', $lang)}"><xsl:value-of select="$heading"/></h1>
            <a href="{concat('toc_t.html?lang=', $lang)}"><button type="button" class="btn text-light btn-index"><xsl:value-of select="$treatise"/><br/>(<i class="italics">VMS</i>)</button></a>
            <a href="{concat('toc.html?lang=', $lang)}"><button type="button" class="btn text-light btn-index"><xsl:value-of select="$reviews"/><br/>(<span class="italics">Neue Freie Presse</span>)</button></a>
            <a href="{concat('toc_vms.html?lang=', $lang)}"><button type="button" class="btn btn-index"><xsl:value-of select="$vms"/><i class="italics">VMS</i></button></a>
            <a href="{concat('toc_doc.html?lang=', $lang)}"><button type="button" class="btn btn-index"><xsl:value-of select="$docs"/><i class="italics">VMS</i></button></a>
            <xsl:for-each select="$doc//tei:body/tei:div/tei:p">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <p class="index_text">
                            <xsl:apply-templates select="node()" mode="index-content">
                                <xsl:with-param name="content-lang" tunnel="yes" select="$lang"/>
                            </xsl:apply-templates>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p class="index_text about-text-hidden fade-lang">
                            <xsl:apply-templates select="node()" mode="index-content">
                                <xsl:with-param name="content-lang" tunnel="yes" select="$lang"/>
                            </xsl:apply-templates>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <p class="show-text" data-show-more="{$showMore}" data-show-less="{$showLess}"><xsl:value-of select="$showMore"/></p>
        </div>
    </xsl:template>

    <xsl:template match="tei:div//tei:head" mode="index-content">
        <h2><xsl:apply-templates mode="index-content"/></h2>
    </xsl:template>
    <xsl:template match="tei:div" mode="index-content">
        <div><xsl:apply-templates mode="index-content"/></div>
    </xsl:template>
    <xsl:template match="tei:emph" mode="index-content">
        <em><xsl:apply-templates mode="index-content"/></em>
    </xsl:template>
    <xsl:template match="tei:list" mode="index-content">
        <ul><xsl:apply-templates mode="index-content"/></ul>
    </xsl:template>
    <xsl:template match="tei:item" mode="index-content">
        <li><xsl:apply-templates mode="index-content"/></li>
    </xsl:template>
    <xsl:template match="tei:ref" mode="index-content">
        <xsl:param name="content-lang" tunnel="yes" as="xs:string"/>
        <a target="_blank" href="{hsl:localize-target(string(@target), $content-lang)}"><xsl:apply-templates mode="index-content"/></a>
    </xsl:template>
    <xsl:template match="text()" mode="index-content">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>
