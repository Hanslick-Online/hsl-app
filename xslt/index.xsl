<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="tei xsl xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/html_navbar_en.xsl"/>
    <xsl:import href="./partials/html_footer_en.xsl"/>
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
                    <xsl:choose>
                        <xsl:when test="starts-with(//tei:body/@xml:lang, 'de')">
                            <xsl:call-template name="nav_bar"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="nav_bar_en"/>
                        </xsl:otherwise>
                    </xsl:choose>

                    <div class="row" style="margin:0 auto;padding:0;">
                        <div class="col-md-5 intro_colum" style="margin:0;padding:0;">
                            <div class="intro_text">
                                <xsl:variable name="h1" select="
                                    if(starts-with(//tei:body/@xml:lang, 'de')) 
                                    then('Digitale Edition') 
                                    else('Digital Edition')"/>
                                <xsl:variable name="treatise" select="
                                    if(starts-with(//tei:body/@xml:lang, 'de')) 
                                    then('Traktat') 
                                    else('Treatise')"/>
                                <xsl:variable name="reviews">
                                    <xsl:choose>
                                        <xsl:when test="starts-with(//tei:body/@xml:lang, 'de')">
                                            Kritiken
                                        </xsl:when>
                                        <xsl:otherwise>
                                            Reviews
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="vms" select="
                                    if(starts-with(//tei:body/@xml:lang, 'de')) 
                                    then('Kritiken von') 
                                    else('Reviews of')"/>
                                <xsl:variable name="docs" select="
                                    if(starts-with(//tei:body/@xml:lang, 'de')) 
                                    then('Dokumente zu') 
                                    else('Documents on')"/>
                                <xsl:variable name="more" select="
                                    if(starts-with(//tei:body/@xml:lang, 'de')) 
                                    then('mehr anzeigen') 
                                    else('show more')"/>
                                <xsl:variable name="lang" select="
                                    if(starts-with(//tei:body/@xml:lang, 'de')) then('?lang=de') else('?lang=en')"/>
                                <h1>
                                    <xsl:value-of select="$h1"/>
                                </h1>
                                <xsl:choose>
                                    <xsl:when test="starts-with(//tei:body/@xml:lang, 'de')">
                                        <button type="button" class="btn text-light btn-index">
                                            <a href="toc_t.html{$lang}">
                                                <xsl:value-of select="$treatise"/><br/>(<i class="italics">VMS</i>) 
                                            </a>
                                        </button>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <button type="button" class="btn text-light btn-index">
                                            <a href="toc_t_en.html{$lang}">
                                                <xsl:value-of select="$treatise"/><br/>(<span class="italics">VMS</span>) 
                                            </a>
                                        </button>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="starts-with(//tei:body/@xml:lang, 'de')">
                                        <a href="toc.html{$lang}">
                                        <button type="button" class="btn text-light btn-index">
                                                <xsl:value-of select="$reviews"/><br/>(<span class="italics">Neue Freie Presse</span>)                                            
                                        </button>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                     <a href="toc_en.html{$lang}">
                                        <button type="button" class="btn text-light btn-index">
                                                <xsl:value-of select="$reviews"/><br/>(<span class="italics">Neue Freie Presse</span>)  
                                        </button>
                                        </a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <a href="toc_vms.html{$lang}">
                                <button type="button" class="btn btn-index">
                                        <xsl:value-of select="$vms"/><xsl:text> </xsl:text> <i class="italics">VMS</i>
                                    <!-- <xsl:value-of select="$vms"/>
                                    btn-index-secondary -->
                                </button>
                                 </a>
                                  <a href="toc_doc.html{$lang}">
                                <button type="button" class="btn btn-index">
                                        <xsl:value-of select="$docs"/><xsl:text> </xsl:text> <i class="italics">VMS</i>                      
                                    <!-- <xsl:value-of select="$vms"/>
                                    btn-index-secondary -->
                                </button></a>
                                <xsl:for-each select="//tei:body">
                                    <xsl:for-each select="./tei:div/tei:p">
                                        <xsl:choose>
                                            <xsl:when test="position() = 1">
                                                <p class="index_text">
                                                    <xsl:apply-templates/>
                                                </p>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <p class="index_text about-text-hidden fade-lang">
                                                    <xsl:apply-templates/>
                                                </p>
                                            </xsl:otherwise>
                                        </xsl:choose>

                                    </xsl:for-each>
                                    <p id="show-text">
                                        <xsl:value-of select="$more"/>
                                    </p>
                                </xsl:for-each>

                            </div>
                        </div>
                        <div class="col-md-7 i_img_cl" style="margin:0;padding:0;">
                            <div class="intro_image">
                                <img src="images/thumbnail.jpg" alt="Hanslick Online Hintergrundbild"/>
                            </div>
                        </div>
                    </div>

                    <xsl:choose>
                        <xsl:when test="starts-with(//tei:body/@xml:lang, 'de')">
                            <xsl:call-template name="html_footer"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="html_footer_en"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <script type="text/javascript" src="js/run.js"></script>
                <script src="js/hide-md.js"></script>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:div//tei:head">
        <h2 id="{generate-id()}">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    <xsl:template match="tei:div">
        <div id="{generate-id()}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:emph">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    <xsl:template match="tei:list">
        <ul id="{generate-id()}">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="tei:item">
        <li id="{generate-id()}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="tei:ref">
        <a target="_blank" href="{@target}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
</xsl:stylesheet>
