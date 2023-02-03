<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="#all">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Impressum'"/>
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
                    
                    <div class="container-fluid" style="margin: 3em auto;">
                        <h1><xsl:value-of select="$doc_title"/></h1>

                        <xsl:for-each select="//root">
                            <xsl:apply-templates/>
                        </xsl:for-each>
                    </div>
                    
                    <xsl:call-template name="html_footer"/>
                    
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="div">
        <div><xsl:apply-templates/></div>
    </xsl:template>
    <xsl:template match="p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <xsl:template match="h2">
        <h2><xsl:apply-templates/></h2>
    </xsl:template>
    <xsl:template match="h3">
        <h3><xsl:apply-templates/></h3>
    </xsl:template>
    <xsl:template match="hr">
        <hr/>
    </xsl:template>
    <xsl:template match="br">
        <br/>
    </xsl:template>
    <xsl:template match="a">
        <a href="{@href}"><xsl:apply-templates/></a>
    </xsl:template>
</xsl:stylesheet>