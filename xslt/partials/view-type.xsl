<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl tei" version="2.0">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            <h1>Widget view-type.</h1>
            <p>Contact person: daniel.elsner@oeaw.ac.at</p>
            <p>Applied with call-templates in html:body.</p>
            <p>Custom template to create a editions view.</p>
        </desc>    
    </doc>
    <xsl:template name="view-type">
        <xsl:param name="showSlider" select="'false'"/>
        <xsl:param name="toc-address" />
        <xsl:param name="editor-widget" />
        <xsl:param name="back-btn" />
        <xsl:param name="anotation-options" />
        <xsl:param name="book-editions" />
        <xsl:param name="book-chapters" />
        <xsl:param name="front-page" />
        <xsl:param name="body-xpath" as="item()*"/>
        <xsl:param name="footnotes"/>
        <xsl:param name="footnotes-xpath" as="item()*"/>
        <xsl:param name="back-page" />
        <xsl:param name="edition-project-class" />
        <xsl:param name="next-prev-page" />
        <xsl:param name="document-download"/>
        <xsl:param name="document-download-edition"/>
        <div class="row">
            <div class="col-md-6 facsimiles">
                <div id="viewer-1">
                    <!--<div id="spinner_1" class="text-center">
                                        <div class="loader"></div>
                                    </div>-->
                    <div id="container_facs_1" style="padding:.5em;margin-top:2em;">
                        <!-- image container accessed by OSD script -->                               
                    </div>  
                </div>
            </div>
            <div class="col-md-6 text">
                <div class="row" style="margin: 2em auto;">
                    <div class="col-md-6" style="text-align:right;">
                        <input type="checkbox" name="opt[]" value="separateWordSearch" checked="checked"/> Wörter einzeln suchen
                    </div>
                    <div class="col-md-6" style="text-align:right;">
                        <input type="text" name="keyword" class="form-control input-sm" placeholder="Schlagwort eingeben..."/>
                    </div>
                </div>
                <div class="section {$edition-project-class}" id="section-1">
                    <xsl:if test="$editor-widget = 'true'">
                        <div id="editor-widget">
                            <xsl:if test="$back-btn = 'true'">
                                <a title="zurück zu allen Kritiken" href="{$toc-address}" class="nav-link btn btn-round btn-backlink">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-back" viewBox="0 0 16 16">
                                        <path d="M0 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v2h2a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-2H2a2 2 0 0 1-2-2V2zm2-1a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1H2z"/>
                                    </svg>
                                </a>
                            </xsl:if>
                            <xsl:if test="$anotation-options = 'true'">
                                <xsl:call-template name="annotation-options">
                                    <xsl:with-param name="showSlider" select="$showSlider"/>
                                </xsl:call-template>
                                <!-- loaded in main editions.xls -->
                            </xsl:if>
                            <xsl:if test="$book-editions = 'true'">
                                <xsl:call-template name="chapters"/>
                                <!-- loaded in main editions.xls -->
                            </xsl:if>
                            <xsl:if test="$book-chapters = 'true'">
                                <xsl:call-template name="book-editions"/>
                                <!-- loaded in main editions.xls -->
                            </xsl:if>
                            <xsl:if test="$document-download = 'true'">
                                <xsl:call-template name="document-download">
                                    <xsl:with-param name="edition" select="$document-download-edition"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="$next-prev-page = 'true'">
                                <xsl:call-template name="next-prev-page"/>
                                <!-- loaded in main editions.xls -->
                            </xsl:if>
                        </div>
                    </xsl:if>
                    <div id="mark-scroll" class="fade-lang">
                        <button data-search="next" disabled="disabled">&#x2193;</button>
                        <button data-search="prev" disabled="disabled">&#x2191;</button>
                        <button data-search="clear" disabled="disabled">✖</button>
                        <div id="results-div"></div>
                    </div>
                    <xsl:if test="$front-page = 'true'">
                        <div class="card-header yes-index">
                            <xsl:for-each select=".//tei:front/tei:titlePage">
                                <div class="vh"><xsl:apply-templates/></div>
                            </xsl:for-each>
                        </div>
                    </xsl:if>
                    <xsl:if test="$body-xpath">
                        <div class="card-body yes-index">
                            <xsl:for-each select="$body-xpath">
                                <xsl:if test="contains($edition-project-class, 'traktat')">
                                    <a class="anchor" id="index.xml-body.1_div.{position()}"></a>
                                </xsl:if>
                                <xsl:apply-templates/>
                            </xsl:for-each>
                        </div>
                    </xsl:if>
                    <xsl:if test="$footnotes ='true'">
                        <xsl:call-template name="view-type-content">
                            <xsl:with-param name="node_xpath" as="item()*" select="$footnotes-xpath"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="$back-page ='true'">
                        <xsl:for-each select="//tei:back">
                            <div class="tei-back">
                                <xsl:call-template name="entities-modal"/>
                            </div>
                        </xsl:for-each>
                    </xsl:if>
                </div>
            </div>
        </div>
        
    </xsl:template>
</xsl:stylesheet>
