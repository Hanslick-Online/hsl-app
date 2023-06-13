<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar_en.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer_en.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Volltextsuche'"/>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/instantsearch.css@7/themes/algolia-min.css"/>
                <link rel="stylesheet" type="text/css" href="css/ts_search.css"/>
            </head>
            
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar_en"/>
                    
                    <div class="container-fluid">
                        <div class="search-panel">
                            <div class="search-panel__results">
                                <div class="row">
                                    <div class="col-md-4">
                                        <div id="stats-container"></div>
                                        <h4>Full Text Search</h4>
                                        <div id="searchbox"></div>
                                        <div id="clear-refinements"></div>
                                        <h4>Persons</h4>
                                        <div id="refinement-list-persons"></div>
                                        <h4>Places</h4>
                                        <div id="refinement-list-places"></div>
                                        <h4>Works</h4>
                                        <div id="refinement-list-works"></div>
                                        <h4>Date</h4>
                                        <div id="range-input"></div>
                                    </div>
                                    <div class="col-md-8">
                                        <div id="sort-by"></div>
                                        <div id="current-refinements"></div>
                                        <div id="pagination"></div>
                                        <div id="hits"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <xsl:call-template name="html_footer_en"/>
                    
                </div>
            </body>
            
            <script src="https://cdn.jsdelivr.net/npm/instantsearch.js@4.44.0"></script>
            <script src="https://cdn.jsdelivr.net/npm/typesense-instantsearch-adapter@2/dist/typesense-instantsearch-adapter.min.js"></script>
            <script src="js/ts_search.js"></script>
            <script src="js/ts_update_url.js"></script>
            <script type="text/javascript" src="js/run.js"></script>
        </html>
    </xsl:template>
</xsl:stylesheet>