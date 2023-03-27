<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="no" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:titleStmt//tei:title[@type='main'][1]/text()"/>
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
                        
                        <xsl:apply-templates select="//tei:body"/>

                    </div><!-- .container-fluid -->
                    <xsl:call-template name="html_footer"/>
                </div><!-- .site -->
                
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="tei:body">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:listBibl">
        <div class="index-list">
            <h1>Publikationen</h1>
            <h5>January 21, 2023</h5>
            <xsl:for-each-group select="./tei:biblStruct" group-by="@type">
                <xsl:sort select="current-grouping-key()" data-type="text"/>
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = '01_book'">
                        <h3>Bücher</h3>
                    </xsl:when>                  
                    <xsl:when test="current-grouping-key() = '02_thesis'">
                        <h3>Thesis</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = '03_journalArticle'">
                        <h3>Artikel</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = '04_bookSection'">
                        <h3>Buchkapitel</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = '05_encyclopediaArticle'">
                        <h3>Lexikon Artikel</h3>
                    </xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>

                <ul class="publications {current-grouping-key()}">
                    <xsl:for-each select="current-group()[not(current-grouping-key() = '06_presentation')]">
                        <xsl:sort select=".//tei:imprint/tei:date" order="descending" data-type="number"/>
                        <xsl:sort select=".//tei:author[1]/tei:surname" data-type="text"/>
                        <xsl:if test=".//tei:imprint/tei:date != 'forthcoming'">
                            <li class="list-item">
                                <xsl:choose>
                                    <xsl:when test="current-grouping-key() = '01_book'">
                                        
                                        <xsl:call-template name="date"/>
                                        <xsl:apply-templates select="tei:monogr" mode="book"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = '02_thesis'">
                                        
                                        <xsl:call-template name="date"/>
                                        <xsl:apply-templates select="tei:monogr" mode="book"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = '03_journalArticle'">
                                        
                                        <xsl:call-template name="date"/>
                                        <xsl:apply-templates select="tei:analytic" mode="any"/>
                                        <xsl:apply-templates select="tei:monogr" mode="journalArticle"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = '04_bookSection'">
                                        
                                        <xsl:call-template name="date"/>
                                        <xsl:apply-templates select="tei:analytic" mode="any"/>
                                        <xsl:apply-templates select="tei:monogr" mode="bookSection"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = '05_encyclopediaArticle'">
                                        
                                        <xsl:call-template name="date"/>
                                        <xsl:apply-templates select="tei:analytic" mode="any"/>
                                        <xsl:apply-templates select="tei:monogr" mode="book"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:otherwise></xsl:otherwise>
                                </xsl:choose>
                            </li>
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </xsl:for-each-group>
            <h2>Bevorstehend</h2>
            <xsl:for-each-group select="./tei:biblStruct" group-by="@type">
                <xsl:sort select="current-grouping-key()" data-type="text"/>
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = '01_book'">
                        <h3>Bücher</h3>
                    </xsl:when>                  
                    <xsl:when test="current-grouping-key() = '02_thesis'">
                        <!--<h3>Thesis</h3>-->
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = '03_journalArticle'">
                        <!--<h3>Artikel</h3>-->
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = '04_bookSection'">
                        <h3>Buchkapitel</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = '05_encyclopediaArticle'">
                        <!--<h3>Lexikon Artikel</h3>-->
                    </xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                    
                </xsl:choose>
                
                <ul class="publications {current-grouping-key()}">
                    <xsl:for-each select="current-group()[not(current-grouping-key() = 'presentation')]">
                        <xsl:sort select=".//tei:imprint/tei:date" order="descending" data-type="number"/>
                        <xsl:sort select=".//tei:author[1]/tei:surname" data-type="text"/>
                        <xsl:if test=".//tei:imprint/tei:date = 'forthcoming'">
                            <li class="list-item">
                                <xsl:choose>
                                    <xsl:when test="current-grouping-key() = '01_book'">
                                        
                                        <xsl:apply-templates select="tei:monogr" mode="book"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = '02_thesis'">
                                        
                                        <xsl:apply-templates select="tei:monogr" mode="book"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = '03_journalArticle'">
                                        
                                        <xsl:apply-templates select="tei:analytic" mode="any"/>
                                        <xsl:apply-templates select="tei:monogr" mode="journalArticle"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = '04_bookSection'">
                                        
                                        <xsl:apply-templates select="tei:analytic" mode="any"/>
                                        <xsl:apply-templates select="tei:monogr" mode="bookSection"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = '05_encyclopediaArticle'">
                                        
                                        <xsl:apply-templates select="tei:analytic" mode="any"/>
                                        <xsl:apply-templates select="tei:monogr" mode="book"/>
                                        <xsl:if test=".//tei:series">
                                            <xsl:apply-templates select="tei:series" mode="any"/>
                                        </xsl:if>
                                        <xsl:call-template name="url"/>
                                        
                                    </xsl:when>
                                    <xsl:otherwise></xsl:otherwise>
                                </xsl:choose>
                            </li>
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </xsl:for-each-group>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:analytic" mode="any">
        <xsl:if test="./tei:author">
            <xsl:for-each select="./tei:author">
                <span class="author">
                    <xsl:value-of select="./tei:surname"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="./tei:forename"/>
                </span>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>. </xsl:text>
        </xsl:if>
        <span class="title-a"><xsl:value-of select="./tei:title[@level='a']"/></span>
        <xsl:text>. </xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:monogr" mode="bookSection">
        <xsl:text>In </xsl:text>
        <span class="italic title-m"><xsl:value-of select="./tei:title[@level='m']"/></span>
        <xsl:text>, hg. </xsl:text>
        <xsl:if test="./tei:editor">
            <xsl:for-each select="./tei:editor">
                <span class="author">
                    <xsl:value-of select="./tei:surname"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="./tei:forename"/>
                </span>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
        <xsl:apply-templates select="tei:imprint"/>
        <xsl:text>. </xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:monogr" mode="journalArticle">
        <xsl:text>In </xsl:text>
        <span class="italic title-j"><xsl:value-of select="./tei:title[@level='j']"/></span>
        <xsl:apply-templates select="tei:imprint"/>
        <xsl:text>. </xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:monogr" mode="book">
        <xsl:if test="./tei:editor">
            <xsl:for-each select="./tei:editor">
                <span class="author">
                    <xsl:value-of select="./tei:surname"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="./tei:forename"/>
                </span>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>. </xsl:text>
        </xsl:if>
        <xsl:if test="./tei:respStmt">
            <xsl:for-each select="./tei:respStmt/tei:persName">
                <xsl:value-of select="./tei:surname"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="./tei:forename"/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>. </xsl:text>
        </xsl:if>
        <xsl:if test="./tei:author">
            <xsl:for-each select="./tei:author">
                <span class="author">
                    <xsl:value-of select="./tei:surname"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="./tei:forename"/>
                </span>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>. </xsl:text>
        </xsl:if>
        <span class="italic title-m"><xsl:value-of select="./tei:title[@level='m']"/></span>
        <xsl:apply-templates select="tei:imprint"/>
        <xsl:text>. </xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:series" mode="any">
        <span class="title-s"><xsl:value-of select="./tei:title[@level='s']"/></span>
        <xsl:if test="./tei:biblScope[@unit='volume']">
            <xsl:text> </xsl:text>
            <xsl:value-of select="./tei:biblScope[@unit='volume']"/>
        </xsl:if>
        <xsl:text>. </xsl:text>
    </xsl:template>
    
    <xsl:template name="url">
        <xsl:for-each select=".//tei:imprint/tei:note[@type='url']">
            <a class="url" href="{.}"><xsl:apply-templates/></a>
            <xsl:text>. </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="date">
        <xsl:for-each select=".//tei:imprint/tei:date">
            <span class="date"><xsl:apply-templates/></span>
            <xsl:text>. </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:imprint">
        <xsl:if test="./tei:biblScope[@unit='volume']">
            <xsl:text>, </xsl:text>
            <span class="bibl-vol">
                <xsl:value-of select="./tei:biblScope[@unit='volume']"/>
            </span>
        </xsl:if>
        <xsl:if test="./tei:biblScope[@unit='issue']">
            <xsl:text>/</xsl:text>
            <span class="bibl-issue">
                <xsl:value-of select="./tei:biblScope[@unit='issue']"/>
            </span>
        </xsl:if>
        <xsl:if test="./tei:biblScope[@unit='page']">
            <xsl:text>, S. </xsl:text>
            <span class="bibl-page">
                <xsl:value-of select="./tei:biblScope[@unit='page']"/>
            </span>
        </xsl:if>
        <xsl:if test="./tei:pubPlace">
            <xsl:text>. </xsl:text>
            <span class="bibl-pubPlace">
                <xsl:value-of select="./tei:pubPlace"/>
            </span>
            <xsl:choose>
                <xsl:when test="./tei:publisher">
                    <xsl:text>: </xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="./tei:publisher">
            <xsl:if test="not(./tei:pubPlace)">
                <xsl:text>. </xsl:text>
            </xsl:if>
            <span class="bibl-pub">
                <xsl:value-of select="./tei:publisher"/>
            </span>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
