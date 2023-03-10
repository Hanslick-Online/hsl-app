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
            <xsl:value-of select=".//tei:titleStmt//tei:title[@type='main'][1]/text()"/>
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
                    
                    <div class="row" style="margin:0 auto;padding:0;">
                        <div class="col-md-5 intro_colum" style="margin:0;padding:0;">
                            <div class="intro_text">
                                <h1>Digitale Edition</h1>
                                <button type="button" class="btn text-light btn-index">
                                    <a href="t__01_VMS_1854_TEI_AW_26-01-21-TEI-P5.html">Traktat</a>
                                </button>
                                <button type="button" class="btn text-light btn-index">
                                    <a href="toc.html">Kritiken</a>
                                </button>
                                
                                <xsl:for-each select="//tei:body">
                                    <xsl:for-each select="./tei:div/tei:p">
                                        <xsl:choose>
                                            <xsl:when test="position() = 1">
                                                <p class="index_text"><xsl:apply-templates/></p>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <p class="index_text about-text-hidden fade"><xsl:apply-templates/></p>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                    </xsl:for-each>
                                    <p id="show-text">mehr anzeigen</p>
                                </xsl:for-each>
                                
                            </div>
                        </div>
                        <div class="col-md-7 i_img_cl" style="margin:0;padding:0;">
                            <div class="intro_image">
                                <img src="images/thumbnail.jpg" alt="Hanslick Online Hintergrundbild"/>
                            </div>
                        </div>
                    </div>
                    
                    <!--<div class="container-fluid" style="margin-top:1em;">
                        
                        <div class="row">
                            <div class="col-md-12">
                               
                            </div>
                        </div>
                    </div>-->
                    <xsl:call-template name="html_footer"/>
                </div>
                <script src="js/hide-md.js"></script>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:div//tei:head">
        <h2 id="{generate-id()}"><xsl:apply-templates/></h2>
    </xsl:template>
    <xsl:template match="tei:div">
        <div id="{generate-id()}"><xsl:apply-templates/></div>
    </xsl:template>
    
    <!--<xsl:template match="tei:p">
        <p id="{generate-id()}"><xsl:apply-templates/></p>
    </xsl:template>-->
    
    <xsl:template match="tei:list">
        <ul id="{generate-id()}"><xsl:apply-templates/></ul>
    </xsl:template>
    
    <xsl:template match="tei:item">
        <li id="{generate-id()}"><xsl:apply-templates/></li>
    </xsl:template>
    <xsl:template match="tei:ref">
        <a>
            <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
            <xsl:value-of select="."/>
        </a>
    </xsl:template>
</xsl:stylesheet>