<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar_i18n.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer_i18n.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title_de" select="'Volltextsuche'"/>
        <xsl:variable name="doc_title_en" select="'Full Text Search'"/>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="de" data-has-english="true" data-title-de="{$doc_title_de}" data-title-en="{$doc_title_en}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title_de"></xsl:with-param>
                </xsl:call-template>
                <link rel="stylesheet" href="vendor/instantsearch-themes/algolia-min.css"/>
                <link rel="stylesheet" type="text/css" href="css/ts_search.css"/>
            </head>
            
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar_i18n"/>
                    
                    <div class="container-fluid">
                        <div class="search-panel">
                            <div class="search-panel__results">
                                <div class="row">
                                    <div class="col-md-4">
                                        <div id="stats-container"></div>
                                        <h4 data-lang="de" id="content">Volltextsuche</h4>
                                        <h4 data-lang="en" hidden="hidden" id="content-en">Full Text Search</h4>
                                        <div id="searchbox"></div>
                                        <div id="clear-refinements"></div>
                                        <h4 data-lang="de">Edition</h4>
                                        <h4 data-lang="en" hidden="hidden">Edition</h4>
                                        <div id="menu-edition"></div>
                                        <h4 data-lang="de">Personen</h4>
                                        <h4 data-lang="en" hidden="hidden">Persons</h4>
                                        <div id="refinement-list-persons"></div>
                                        <h4 data-lang="de">Orte</h4>
                                        <h4 data-lang="en" hidden="hidden">Places</h4>
                                        <div id="refinement-list-places"></div>
                                        <h4 data-lang="de">Werke</h4>
                                        <h4 data-lang="en" hidden="hidden">Works</h4>
                                        <div id="refinement-list-works"></div>
                                        <h4 data-lang="de">Jahr</h4>
                                        <h4 data-lang="en" hidden="hidden">Date</h4>
                                        <div id="range-input"></div>
                                    </div>
                                    <div class="col-md-8">
                                        <div id="sort-by"></div>
                                        <div id="current-refinements"></div>
                                        <div id="pagination-top"></div>
                                        <div id="hits"></div>
                                        <div id="pagination-bottom"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <xsl:call-template name="html_footer_i18n"/>
                    
                </div>
                
                <script src="vendor/instantsearch/instantsearch.production.min.js"></script>
                <script src="vendor/typesense-instantsearch-adapter/typesense-instantsearch-adapter.min.js"></script>
                <script src="js/ts_search.js"></script>
                <script src="js/ts_update_url.js"></script>
            </body>
            
        </html>
    </xsl:template>
</xsl:stylesheet>
