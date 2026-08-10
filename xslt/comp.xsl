<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:hsl="https://hanslick.acdh.oeaw.ac.at/ns/hsl"
    version="2.0" exclude-result-prefixes="xsl tei xs hsl">
    <xsl:import href="./partials/i18n-utils.xsl"/>
    <xsl:import href="./partials/html_navbar_i18n.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer_i18n.xsl"/>
    <xsl:import href="partials/osd-container.xsl"/>
    <xsl:import href="partials/tei-facsimile.xsl"/>

    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@type='main'][1]/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="de" data-has-english="true" data-title-de="{$doc_title}" data-title-en="{$doc_title}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <style>
                    .container-fluid {
                        max-width: 100%;
                        padding: 0 2em;
                    }
                </style>
            </head>

            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar_i18n"/>

                    <div class="container-fluid">
                        <div class="row">

                            <div class="col-md-12 comp-card">
                                <div class="card-header">
                                    <h2 data-lang="de">
                                        <xsl:value-of select="//tei:titleStmt/tei:title[1]"/>
                                    </h2>
                                    <h2 data-lang="en" hidden="hidden">
                                        <xsl:value-of select="//tei:titleStmt/tei:title[1]"/>
                                    </h2>
                                    <hr></hr>
                                </div>
                                <div class="card-body">
                                    <div class="dropdown">
                                        <button class="btn btn-primary btn-sm dropdown-toggle" type="button" id="selectParNoButton" data-bs-toggle="dropdown" aria-expanded="false">
                                            <span data-lang="de">Paragraph auswaehlen</span>
                                            <span data-lang="en" hidden="hidden">Select paragraph</span>
                                        </button>
                                        <ul class="dropdown-menu" id="selPar" aria-labelledby="selectParNoButton">
                                            <xsl:for-each select="//tei:list[@type='selectPar']/tei:item[starts-with(.,'V')]">
                                                <xsl:sort select="xs:integer(substring-after(substring-before(.,'.'),'V'))"/>
                                                <xsl:copy>
                                                    <a class="dropdown-item" href="{hsl:localize-target(concat('diff_', ., '.html'), 'de')}" data-href-de="{hsl:localize-target(concat('diff_', ., '.html'), 'de')}" data-href-en="{hsl:localize-target(concat('diff_', ., '.html'), 'en')}">
                                                        <xsl:value-of select="replace(., 'xyz', '')"/>
                                                    </a>
                                                </xsl:copy>
                                            </xsl:for-each>
                                            <xsl:for-each select="//tei:list[@type='selectPar']/tei:item[not(starts-with(.,'V'))]">
                                                <xsl:sort select="xs:integer(substring-before(.,'.'))"/>
                                                <xsl:copy>
                                                    <a class="dropdown-item" href="{hsl:localize-target(concat('diff_', ., '.html'), 'de')}" data-href-de="{hsl:localize-target(concat('diff_', ., '.html'), 'de')}" data-href-en="{hsl:localize-target(concat('diff_', ., '.html'), 'en')}">
                                                        <xsl:value-of select="replace(., 'xyz', '')"/>
                                                    </a>
                                                </xsl:copy>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                    <div class="table-wrapper">
                                        <table class="table">
                                            <tbody>
                                                <tr class="label">
                                                    <xsl:for-each select="//tei:cell[parent::tei:row[@role='label']]">
                                                        <th>
                                                            <xsl:for-each select="./tei:seg[@type='sourceNav']">
                                                                <span class="sourceNav">
                                                                    <xsl:if test="./tei:ref[@type='prevLink']">
                                                                        <a class="prevLink" href="{hsl:localize-target(string(./tei:ref[@type='prevLink']/@target), 'de')}" data-href-de="{hsl:localize-target(string(./tei:ref[@type='prevLink']/@target), 'de')}" data-href-en="{hsl:localize-target(string(./tei:ref[@type='prevLink']/@target), 'en')}">
                                                                            <xsl:value-of select="./tei:ref[@type='prevLink']"/>
                                                                        </a>
                                                                    </xsl:if>
                                                                    <xsl:if test="./tei:ref[not(@type)]">
                                                                        <xsl:variable name="target" select="tokenize(./tei:ref[not(@type)]/@target, '#')"/>
                                                                        <xsl:variable name="parts" select="tokenize($target[1], '_')"/>
                                                                        <xsl:variable name="file" select="concat('t__VMS_Auflage_', $parts[3], '_', $parts[5], '.html')"/>
                                                                        <a class="link_ref" href="{hsl:localize-target(concat($file,'#',$target[last()]), 'de')}" data-href-de="{hsl:localize-target(concat($file,'#',$target[last()]), 'de')}" data-href-en="{hsl:localize-target(concat($file,'#',$target[last()]), 'en')}">
                                                                            <xsl:value-of select="./tei:ref[not(@type)]"/>
                                                                        </a>
                                                                    </xsl:if>
                                                                    <xsl:if test="./tei:ref[@type='nextLink']">
                                                                        <a class="nextlink" href="{hsl:localize-target(string(./tei:ref[@type='nextLink']/@target), 'de')}" data-href-de="{hsl:localize-target(string(./tei:ref[@type='nextLink']/@target), 'de')}" data-href-en="{hsl:localize-target(string(./tei:ref[@type='nextLink']/@target), 'en')}">
                                                                            <xsl:value-of select="./tei:ref[@type='nextLink']"/>
                                                                        </a>
                                                                    </xsl:if>
                                                                </span>
                                                            </xsl:for-each>
                                                        </th>
                                                    </xsl:for-each>
                                                </tr>
                                                <tr class="data">
                                                    <xsl:for-each select="//tei:cell[parent::tei:row[@role='data']]">
                                                        <td id="{@xml:id}">
                                                            <xsl:value-of select="./text()"/>
                                                        </td>
                                                    </xsl:for-each>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <div class="card-footer">
                                    <div class="row align-items-end">
                                        <div class="col-md-4">
                                            <label for="selectV1">
                                                <span data-lang="de">Vergleichen</span>
                                                <span data-lang="en" hidden="hidden">Compare</span>
                                            </label>
                                            <select class="form-select" id="selectV1">
                                                <xsl:for-each select="//tei:cell[parent::tei:row[@role='data']]">
                                                    <xsl:variable name="p" select="position()"/>
                                                    <option value="{@xml:id}">
                                                        <xsl:value-of select="ancestor::tei:table//tei:cell[parent::tei:row[@role='label']][$p]//tei:seg/tei:ref[not(@type)]"/>
                                                    </option>
                                                </xsl:for-each>
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <label for="selectV2">
                                                <span data-lang="de">... mit</span>
                                                <span data-lang="en" hidden="hidden">... with</span>
                                            </label>
                                            <select class="form-select" id="selectV2">
                                                <xsl:for-each select="//tei:cell[parent::tei:row[@role='data']]">
                                                    <xsl:variable name="p" select="position()"/>
                                                    <option value="{@xml:id}">
                                                        <xsl:if test="position() eq 2">
                                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                                        </xsl:if>
                                                        <xsl:value-of select="ancestor::tei:table//tei:cell[parent::tei:row[@role='label']][$p]//tei:seg/tei:ref[not(@type)]"/>
                                                    </option>
                                                </xsl:for-each>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <label for="diffLevel">
                                                <span data-lang="de">Vergleichsbasis</span>
                                                <span data-lang="en" hidden="hidden">Comparison basis</span>
                                            </label>
                                            <select class="form-select" id="diffLevel">
                                                <option value="words" data-label-de="Woerter" data-label-en="Words">Woerter</option>
                                                <option value="sentences" data-label-de="Saetze" data-label-en="Sentences">Saetze</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <button class="btn btn-primary" id="compBtn" onclick="compare()">
                                                <span data-lang="de">vergleichen</span>
                                                <span data-lang="en" hidden="hidden">compare</span>
                                            </button>
                                        </div>
                                    </div>
                                    <div class="row p-2">
                                        <div id="display"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <xsl:call-template name="html_footer_i18n"/>
                </div>
                <script type="text/javascript" src="assets/js/diff.js"/>
                <script type="text/javascript" src="assets/js/comp.js"/>
                <script type="text/javascript">
                    document.addEventListener("DOMContentLoaded", function () {
                        var lang = window.hslSiteLang || new URLSearchParams(window.location.search).get("lang") || "de";
                        document.querySelectorAll("#diffLevel option[data-label-de]").forEach(function (node) {
                            node.textContent = node.getAttribute(lang === "en" ? "data-label-en" : "data-label-de");
                        });
                    });
                </script>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>