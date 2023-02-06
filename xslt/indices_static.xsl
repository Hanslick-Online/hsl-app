<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="no" omit-xml-declaration="yes"/>
    
    <!--<xsl:import href="./partials/html_navbar.xsl"/>-->
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@type='main'][1]/text()"/>
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
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = 'bookSection'">
                        <h3>Buchkapitel</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'journalArticle'">
                        <h3>Artikel</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'book'">
                        <h3>Bücher</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'encyclopediaArticle'">
                        <h3>Enzyklopädie Artikel</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'thesis'">
                        <h3>Thesis</h3>
                    </xsl:when>
                </xsl:choose>

                <ul class="publications {current-grouping-key()}">
                    <xsl:for-each select="current-group()[not(current-grouping-key() = 'presentation')]">
                        <xsl:sort select=".//tei:imprint/tei:date" order="descending"/>
                        <xsl:sort select=".//tei:author[1]/tei:surname" order="descending"/>
                        <xsl:if test=".//tei:imprint/tei:date != 'forthcoming'">
                            <li class="list-item">
                                <xsl:choose>
                                    <xsl:when test="current-grouping-key() = 'bookSection'">
                                        <xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:author">
                                            <xsl:for-each select=".//tei:author">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select=".//tei:title[@level='a']"/>
                                        <xsl:text>. In </xsl:text>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='m']"/></span>
                                        <xsl:text>, hg. </xsl:text>
                                        <xsl:for-each select=".//tei:editor">
                                            <xsl:value-of select="./tei:surname"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="./tei:forename"/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text>, </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = 'journalArticle'">
                                        <xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>
                                        <xsl:for-each select=".//tei:author">
                                            <xsl:value-of select=".//tei:surname"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:forename"/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text>, </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:if test=".//tei:author">
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select=".//tei:title[@level='a']"/>
                                        <xsl:text>. In </xsl:text>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='j']"/></span>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='issue']">
                                            <xsl:text>/</xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='issue']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = 'thesis'">
                                        <xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:editor">
                                            <xsl:for-each select=".//tei:editor">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:if test=".//tei:respStmt">
                                            <xsl:for-each select=".//tei:respStmt">
                                                <xsl:value-of select="./tei:persName/tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:persName/tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:if test=".//tei:author">
                                            <xsl:for-each select=".//tei:author">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='m']"/></span>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = 'book'">
                                        <xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:editor">
                                            <xsl:for-each select=".//tei:editor">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:if test=".//tei:respStmt">
                                            <xsl:for-each select=".//tei:respStmt">
                                                <xsl:value-of select="./tei:persName/tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:persName/tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:if test=".//tei:author">
                                            <xsl:for-each select=".//tei:author">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='m']"/></span>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = 'encyclopediaArticle'">
                                        <xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>
                                        <xsl:for-each select=".//tei:author">
                                            <xsl:value-of select=".//tei:surname"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:forename"/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text>, </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:if test=".//tei:author">
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select=".//tei:title[@level='a']"/>
                                        <xsl:text>. In </xsl:text>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='m']"/></span>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='issue']">
                                            <xsl:text>/</xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='issue']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
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
                
                <xsl:choose>
                    <xsl:when test="current-grouping-key() = 'bookSection'">
                        <h3>Buchkapitel</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'journalArticle'">
                        <h3>Artikel</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'book'">
                        <h3>Bücher</h3>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'encyclopediaArticle'">
                        
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 'thesis'">
                        
                    </xsl:when>
                </xsl:choose>
                
                <ul class="publications {current-grouping-key()}">
                    <xsl:for-each select="current-group()[not(current-grouping-key() = 'presentation')]">
                        <xsl:sort select=".//tei:imprint/tei:date" order="descending"/>
                        <xsl:sort select=".//tei:author[1]/tei:surname" order="descending"/>
                        <xsl:if test=".//tei:imprint/tei:date = 'forthcoming'">
                            <li class="list-item">
                                <xsl:choose>
                                    <xsl:when test="current-grouping-key() = 'bookSection'">
                                        <!--<xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>-->
                                        <xsl:if test=".//tei:author">
                                            <xsl:for-each select=".//tei:author">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select=".//tei:title[@level='a']"/>
                                        <xsl:text>. In </xsl:text>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='m']"/></span>
                                        <xsl:text>, hg. </xsl:text>
                                        <xsl:for-each select=".//tei:editor">
                                            <xsl:value-of select="./tei:surname"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="./tei:forename"/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text>, </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = 'journalArticle'">
                                        <!--<xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>-->
                                        <xsl:for-each select=".//tei:author">
                                            <xsl:value-of select=".//tei:surname"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:forename"/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text>, </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:if test=".//tei:author">
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select=".//tei:title[@level='a']"/>
                                        <xsl:text>. In </xsl:text>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='j']"/></span>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='issue']">
                                            <xsl:text>/</xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='issue']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = 'thesis'">
                                        <!--<xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>-->
                                        <xsl:if test=".//tei:editor">
                                            <xsl:for-each select=".//tei:editor">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:if test=".//tei:respStmt">
                                            <xsl:for-each select=".//tei:respStmt">
                                                <xsl:value-of select="./tei:persName/tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:persName/tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:if test=".//tei:author">
                                            <xsl:for-each select=".//tei:author">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='m']"/></span>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = 'book'">
                                        <!--<xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>-->
                                        <xsl:if test=".//tei:editor">
                                            <xsl:for-each select=".//tei:editor">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:if test=".//tei:respStmt">
                                            <xsl:for-each select=".//tei:respStmt">
                                                <xsl:value-of select="./tei:persName/tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:persName/tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:if test=".//tei:author">
                                            <xsl:for-each select=".//tei:author">
                                                <xsl:value-of select="./tei:surname"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="./tei:forename"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='m']"/></span>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:when test="current-grouping-key() = 'encyclopediaArticle'">
                                        <!--<xsl:value-of select=".//tei:imprint/tei:date"/>
                                        <xsl:text>. </xsl:text>-->
                                        <xsl:for-each select=".//tei:author">
                                            <xsl:value-of select=".//tei:surname"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:forename"/>
                                            <xsl:if test="position() != last()">
                                                <xsl:text>, </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <xsl:if test=".//tei:author">
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
                                        <xsl:value-of select=".//tei:title[@level='a']"/>
                                        <xsl:text>. In </xsl:text>
                                        <span class="italic"><xsl:value-of select=".//tei:title[@level='m']"/></span>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='volume']">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='volume']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='issue']">
                                            <xsl:text>/</xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='issue']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:biblScope[@unit='page']">
                                            <xsl:text>, S. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:biblScope[@unit='page']"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:imprint/tei:publisher">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:pubPlace"/>
                                            <xsl:text>: </xsl:text>
                                            <xsl:value-of select=".//tei:imprint/tei:publisher"/>
                                        </xsl:if>
                                        <xsl:if test=".//tei:series">
                                            <xsl:text>. </xsl:text>
                                            <xsl:value-of select=".//tei:title[@level='s']"/>
                                            <xsl:if test=".//tei:series/tei:biblScope[@unit='volume']">
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select=".//tei:series/tei:biblScope[@unit='volume']"/>
                                            </xsl:if>
                                        </xsl:if>
                                        <xsl:text>. </xsl:text>
                                        <xsl:if test=".//tei:note[@type='url']">
                                            <a href="{.//tei:note[@type='url']}"><xsl:value-of select=".//tei:note[@type='url']"/></a>
                                            <xsl:text>. </xsl:text>
                                        </xsl:if>
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
    
</xsl:stylesheet>
