<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>

    <xsl:template match="tei:space">
        <xsl:value-of select="' '"/>
    </xsl:template>

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
                                            <th scope="col">Autor</th>
                                            <th scope="col">Titel</th>
                                            <th scope="col">Untertitel</th>
                                            <th scope="col">Datum</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="collection('../data/vms/editions')//tei:TEI">
                                            <xsl:variable name="full_path">
                                                <xsl:value-of select="document-uri(/)"/>
                                            </xsl:variable>
                                            <tr>
                                                <td>
                                                    <xsl:attribute name="class">italics</xsl:attribute>
                                                    <xsl:value-of select=".//tei:titleStmt/tei:title[@level='j']/text()"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select=".//tei:titleStmt/tei:author/text()"/>
                                                </td>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="replace(tokenize($full_path, '/')[last()], '.xml', '.html')"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of select="string(.//tei:titleStmt/tei:title[@level='a'][@type='main'])"/>
                                                        <!-- <xsl:for-each select="//tei:body/tei:div/tei:head[@type='h1']">
                                                            <xsl:value-of select="replace(replace(replace(replace(., '\(', ''), '\)', ''), '„', ''), '“', '')"/>
                                                            <xsl:if test="position() != last()">
                                                                <br/>
                                                            </xsl:if>
                                                        </xsl:for-each> -->
                                                    </a>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="string(.//tei:titleStmt/tei:title[@level='a'][@type='sub'])"/>
                                                </td>
                                                <xsl:variable name="eventDate" select=".//tei:imprint/tei:date" />
                                                <td>
                                                    <xsl:attribute name="tabulator-data-sort">
                                                        <xsl:value-of select="($eventDate/@when | .//tei:body//tei:date/@when)[1]" />
                                                    </xsl:attribute>
                                                    <xsl:choose>
                                                        <xsl:when test="$eventDate">
                                                            <xsl:value-of select="$eventDate/text()" />
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text>k.A.</xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
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
                                createDataTable('tocTable', [[4, 'asc']], 50);
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
        <h2 id="{generate-id()}">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>


    <xsl:template match="tei:p">
        <p id="{generate-id()}">
            <xsl:apply-templates/>
        </p>
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
        <xsl:choose>
            <xsl:when test="starts-with(data(@target), 'http')">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>