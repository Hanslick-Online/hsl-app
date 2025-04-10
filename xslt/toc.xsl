<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Inhaltsverzeichnis'"/>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/bs4/jq-3.3.1/jszip-2.5.0/dt-1.11.0/b-2.0.0/b-html5-2.0.0/cr-1.5.4/r-2.2.9/sp-1.4.0/datatables.min.css"></link>
            </head>
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">
                        <div class="card">
                            <div class="card-header">
                                <h1>Inhaltsverzeichnis</h1>
                            </div>
                            <div class="card-body">
                                <table class="table table-striped display" id="tocTable" style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Zeitschrift</th>
                                            <th scope="col">Ausgabe</th>
                                            <th scope="col">Nr. / Datum</th>
                                            <th scope="col">Titel</th>
                                            <th scope="col">Untertitel</th>
                                            <th scope="col">Datum</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="collection('../data/critics/editions')//tei:TEI">
                                            <xsl:variable name="full_path">
                                                <xsl:value-of select="document-uri(/)"/>
                                            </xsl:variable>
                                            <tr>
                                                <td>
                                                    <xsl:value-of select=".//tei:sourceDesc//tei:biblStruct/tei:monogr/tei:title[@type='main']/text()"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select=".//tei:sourceDesc//tei:biblStruct/tei:monogr/tei:title[@type='sub']/text()"/>
                                                </td>
                                                <td>                                        
                                                    <a>
                                                        <xsl:attribute name="href">                                                
                                                            <xsl:value-of select="replace(tokenize($full_path, '/')[last()], '.xml', '.html')"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of select=".//tei:sourceDesc//tei:biblStruct/tei:analytic/tei:title[1]/text()"/>
                                                    </a>
                                                </td>
                                                <td>
                                                    <xsl:for-each select="//tei:body/tei:div/tei:head[@type='h1']">
                                                        <xsl:value-of select="."/>
                                                        <xsl:if test="position() != last()">
                                                            <br/>
                                                        </xsl:if>
                                                    </xsl:for-each>
                                                </td>
                                                <td>
                                                    <xsl:for-each select="//tei:body/tei:div/tei:head[@type='h2']">
                                                        <xsl:apply-templates select="node()"/>
                                                        <xsl:if test="position() != last()">
                                                            <br/>
                                                        </xsl:if>
                                                    </xsl:for-each>
                                                </td>
                                                <td>
                                                    <xsl:value-of select=".//tei:sourceDesc//tei:biblStruct/tei:monogr/tei:imprint/tei:date/@when"/>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    
                    <xsl:call-template name="html_footer"/>
                    <script>
                        $(document).ready(function () {
                            createDataTable('tocTable', [[5, 'asc']], 50);
                        });
                    </script>
                </div>
                <script type="text/javascript" src="js/run.js"></script>
                <script type="text/javascript" src="https://cdn.datatables.net/v/bs4/jszip-2.5.0/dt-1.11.0/b-2.0.0/b-html5-2.0.0/cr-1.5.4/r-2.2.9/sp-1.4.0/datatables.min.js"></script>
                <script type="text/javascript" src="js/dt.js"></script>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:div//tei:head">
        <h2 id="{generate-id()}"><xsl:apply-templates/></h2>
    </xsl:template>
    
    <xsl:template match="tei:p">
        <p id="{generate-id()}"><xsl:apply-templates/></p>
    </xsl:template>
     <xsl:template match="text()[ancestor::tei:body]" priority="1">
        <xsl:choose>
            <xsl:when test="following-sibling::tei:*[1][@break='no']">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:when test="matches(., '-$')">|
                HYPHEN-MATCH<xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:lb[@break='no']" />
    <xsl:template match="tei:list">
        <ul id="{generate-id()}"><xsl:apply-templates/></ul>
    </xsl:template>
    
    <xsl:template match="tei:item">
        <li id="{generate-id()}"><xsl:apply-templates/></li>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="starts-with(data(@target), 'http')">
                <a>
                    <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>