<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="tei xsl xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar_i18n.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer_i18n.xsl"/>
    <xsl:import href="./partials/graphics_common.xsl"/>
    <xsl:import href="./partials/graphics_net.xsl"/>
    <xsl:import href="./partials/graphics_vms_net.xsl"/>
    <xsl:import href="./partials/graphics_chart.xsl"/>
    <xsl:import href="./partials/graphics_vms_chart.xsl"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title" as="xs:string" select="normalize-space(string(.//tei:title[1]))"/>
        <xsl:variable name="doc-title-lower" as="xs:string" select="lower-case($doc_title)"/>
        <xsl:variable name="is-vms-net" as="xs:boolean" select="contains($doc-title-lower, 'vms') and (contains($doc-title-lower, 'beziehungsgraph') or contains($doc-title-lower, 'network'))"/>

        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <link rel="stylesheet" href="css/graphics.css" />
                <xsl:if test="contains($doc_title, 'Chart')">
                    <link rel="stylesheet" href="css/charts.css"/>
                </xsl:if>
            </head>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar_i18n"/>    
                    
                    <div class="container-fluid" style="margin-top:1em;">
                        <div class="row">
                            <div class="col-md-12">
                                   <div class="main">
                                        <xsl:choose>
                                            <xsl:when test="$is-vms-net">
                                                <xsl:call-template name="vms_net_container"/>
                                            </xsl:when>
                                            <xsl:when test="contains($doc-title-lower, 'network') or contains($doc-title-lower, 'beziehungsgraph')">
                                                <xsl:call-template name="net_container"/>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:if test="contains($doc_title, 'Chart')">
                                            <xsl:choose>
                                                <xsl:when test="contains($doc_title, 'VMS Chart')">
                                                    <xsl:call-template name="vms_chart_container"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:call-template name="chart_container"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                    </div>
                            </div>
                        </div>
                    </div>
                </div>   
		<xsl:call-template name="html_footer_i18n"/> 
                <xsl:if test="contains($doc_title, 'Chart')">
                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
                    <xsl:choose>
                        <xsl:when test="contains($doc_title, 'VMS Chart')">
                            <script type="text/javascript" src="js/graphics-vms.js"></script>
                        </xsl:when>
                        <xsl:otherwise>
                            <script type="text/javascript" src="js/graphics.js"></script>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <script type="text/javascript" src="js/run.js"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
