<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:import href="./partials/html_navbar_i18n.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer_i18n.xsl"/>

    <xsl:template match="tei:space">
        <xsl:value-of select="' '"/>
    </xsl:template>

    <xsl:template match="/">
        <xsl:variable name="doc_title_de" select="'Inhaltsverzeichnis'"/>
        <xsl:variable name="doc_title_en" select="'Table of Contents'"/>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="de" data-has-english="true" data-title-de="{$doc_title_de}" data-title-en="{$doc_title_en}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title_de"></xsl:with-param>
                </xsl:call-template>
                <!-- <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/bs4/jq-3.3.1/jszip-2.5.0/dt-1.11.0/b-2.0.0/b-html5-2.0.0/cr-1.5.4/r-2.2.9/sp-1.4.0/datatables.min.css"></link> -->
                <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.21/css/dataTables.bootstrap4.min.css"/>
            </head>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar_i18n"/>

                    <div class="container-fluid">
                        <div class="card">
                            <div class="card-header">
                                <h1 id="content" data-lang="de">Inhaltsverzeichnis</h1>
                                <h1 id="content-en" data-lang="en" hidden="hidden">Table of Contents</h1>
                            </div>
                            <div class="card-body" data-lang="de">
                                <table class="table table-striped display" id="tocTable-de" style="width:100%">
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
                                        <xsl:for-each select="collection('../data/doc/editions')//tei:TEI">
                                            <xsl:variable name="full_path">
                                                <xsl:value-of select="document-uri(/)"/>
                                            </xsl:variable>
                                            <tr>
                                                <td>
                                                    <xsl:attribute name="class">italics</xsl:attribute>
                                                    <xsl:value-of select=".//tei:titleStmt/tei:title[@level='j']/text()"/>
                                                </td>
                                                <td>
                                                    <xsl:for-each select=".//tei:titleStmt/tei:author">
                                                        <xsl:value-of select="text()"/>
                                                        <xsl:if test="position() != last()">, </xsl:if>
                                                    </xsl:for-each>
                                                </td>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="concat(replace(tokenize($full_path, '/')[last()], '.xml', '.html'), '?lang=de')"/>
                                                        </xsl:attribute>
                                                        <xsl:apply-templates select=".//tei:titleStmt/tei:title[@level='a']"/>
                                                    </a>
                                                </td>
                                                <td>
                                                     <xsl:apply-templates select=".//tei:titleStmt/tei:title[@level='a'][@type='sub']"/>
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
                            <div class="card-body" data-lang="en" hidden="hidden">
                                <table class="table table-striped display" id="tocTable-en" style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Source</th>
                                            <th scope="col">Author</th>
                                            <th scope="col">Title</th>
                                            <th scope="col">Subtitle</th>
                                            <th scope="col">Date</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="collection('../data/doc/editions')//tei:TEI">
                                            <xsl:variable name="full_path">
                                                <xsl:value-of select="document-uri(/)"/>
                                            </xsl:variable>
                                            <tr>
                                                <td class="italics"><xsl:value-of select=".//tei:titleStmt/tei:title[@level='j']/text()"/></td>
                                                <td>
                                                    <xsl:for-each select=".//tei:titleStmt/tei:author">
                                                        <xsl:value-of select="text()"/>
                                                        <xsl:if test="position() != last()">, </xsl:if>
                                                    </xsl:for-each>
                                                </td>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="concat(replace(tokenize($full_path, '/')[last()], '.xml', '.html'), '?lang=en')"/>
                                                        </xsl:attribute>
                                                        <xsl:apply-templates select=".//tei:titleStmt/tei:title[@level='a']"/>
                                                    </a>
                                                </td>
                                                <td><xsl:apply-templates select=".//tei:titleStmt/tei:title[@level='a'][@type='sub']"/></td>
                                                <xsl:variable name="eventDate" select=".//tei:imprint/tei:date"/>
                                                <td tabulator-data-sort="{($eventDate/@when | .//tei:body//tei:date/@when)[1]}">
                                                    <xsl:choose>
                                                        <xsl:when test="$eventDate"><xsl:value-of select="$eventDate/text()"/></xsl:when>
                                                        <xsl:otherwise><xsl:text>n/a</xsl:text></xsl:otherwise>
                                                    </xsl:choose>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <xsl:call-template name="html_footer_i18n"/>
                    <script>
                            $(document).ready(function () {
                                var activeTable = window.hslSiteLang === 'en' ? 'tocTable-en' : 'tocTable-de';
                                createDataTable(activeTable, [[4, 'asc']], 50, window.hslSiteLang);
                            });
                    </script>
                </div>
                <!-- <script type="text/javascript" src="https://cdn.datatables.net/v/bs4/jszip-2.5.0/dt-1.11.0/b-2.0.0/b-html5-2.0.0/cr-1.5.4/r-2.2.9/sp-1.4.0/datatables.min.js" /> -->
                <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.21/js/jquery.dataTables.min.js" />
                <script type="text/javascript" src="js/dt.js"></script>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:div//tei:head">
        <h2 id="{generate-id()}">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>


    <xsl:template match="tei:*[@rend]">
        <xsl:choose>
            <xsl:when test="@rend='quotes'">
                <q><xsl:apply-templates/></q>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@rend"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- Handle <rs> by just outputting its content -->
<xsl:template match="tei:rs">
    <xsl:apply-templates/>
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
