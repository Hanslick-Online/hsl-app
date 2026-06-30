<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="tei xsl xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_navbar_en.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/html_footer_en.xsl"/>
    <xsl:import href="./partials/graphics_common.xsl"/>
    <xsl:import href="./partials/graphics_net.xsl"/>
    <xsl:import href="./partials/graphics_chart.xsl"/>
    <xsl:import href="./partials/graphics_vms_chart.xsl"/>

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
                <link rel="stylesheet" href="css/graphics.css" />
                <xsl:if test="contains($doc_title, 'Chart')">
                    <link rel="stylesheet" href="css/charts.css"/>
                </xsl:if>
            </head>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:choose>
                        <xsl:when test="//tei:body[@xml:lang='de-AT']">
                            <xsl:call-template name="nav_bar"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="nav_bar_en"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <div class="container-fluid" style="margin-top:1em;">
                        <div class="row">
                            <div class="col-md-12">
                                   <div class="main">
                                        <xsl:if test="contains($doc_title, 'Network')">
                                            <xsl:call-template name="net_container"/>
                                        </xsl:if>
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
                    
                    <xsl:choose>
                        <xsl:when test="//tei:body[@xml:lang='de-AT']">
                            <xsl:call-template name="html_footer"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="html_footer_en"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
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
