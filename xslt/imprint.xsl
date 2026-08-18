<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:hsl="https://hanslick.acdh.oeaw.ac.at/ns/hsl"
    version="2.0" exclude-result-prefixes="#all">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/i18n-utils.xsl"/>
    <xsl:import href="./partials/html_navbar_i18n.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer_i18n.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title_de" select="'Impressum'"/>
        <xsl:variable name="doc_title_en" select="'Imprint'"/>
        <xsl:variable name="doc_en" select="document(replace(document-uri(/), 'imprint\.xml$', 'imprint_en.xml'))"/>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="de" data-has-english="true" data-title-de="{$doc_title_de}" data-title-en="{$doc_title_en}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title_de"></xsl:with-param>
                </xsl:call-template>
            </head>
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar_i18n"/>
                    
                    <div class="container-fluid" style="margin: 3em auto;">
                        <h1 data-lang="de" id="content"><xsl:value-of select="$doc_title_de"/></h1>
                        <h1 data-lang="en" hidden="hidden" id="content-en"><xsl:value-of select="$doc_title_en"/></h1>

                        <div data-lang="de">
                            <xsl:for-each select=".//div">
                                <xsl:apply-templates select="." mode="imprint-content">
                                    <xsl:with-param name="content-lang" tunnel="yes" select="'de'"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </div>
                        <div data-lang="en" hidden="hidden">
                            <xsl:for-each select="$doc_en//div">
                                <xsl:apply-templates select="." mode="imprint-content">
                                    <xsl:with-param name="content-lang" tunnel="yes" select="'en'"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </div>
                    </div>
                    
                    <xsl:call-template name="html_footer_i18n"/>
                    
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="div" mode="imprint-content">
        <div><xsl:apply-templates mode="imprint-content"/></div>
    </xsl:template>
    <xsl:template match="p" mode="imprint-content">
        <p><xsl:apply-templates mode="imprint-content"/></p>
    </xsl:template>
    <xsl:template match="h2" mode="imprint-content">
        <h2><xsl:apply-templates mode="imprint-content"/></h2>
    </xsl:template>
    <xsl:template match="h3" mode="imprint-content">
        <h3><xsl:apply-templates mode="imprint-content"/></h3>
    </xsl:template>
    <xsl:template match="hr" mode="imprint-content">
        <hr/>
    </xsl:template>
    <xsl:template match="br" mode="imprint-content">
        <br/>
    </xsl:template>
    <xsl:template match="a" mode="imprint-content">
        <xsl:param name="content-lang" tunnel="yes" as="xs:string"/>
        <a href="{hsl:localize-target(string(@href), $content-lang)}"><xsl:apply-templates mode="imprint-content"/></a>
    </xsl:template>
    <xsl:template match="text()" mode="imprint-content"><xsl:value-of select="."/></xsl:template>
</xsl:stylesheet>