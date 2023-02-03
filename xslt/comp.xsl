<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar_traktat.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:import href="partials/osd-container.xsl"/>
    <xsl:import href="partials/tei-facsimile.xsl"/>
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
                        <div class="row">
                            
                            <div class="col-md-12 comp-card">
                                <div class="card-header">
                                    <h2><xsl:value-of select="//tei:titleStmt/tei:title[1]"/></h2>
                                    <hr></hr>
                                </div>
                                <div class="card-body">
                                    <div class="dropdown">
                                        <button class="btn btn-primary btn-sm dropdown-toggle" type="button" id="selectParNoButton" data-bs-toggle="dropdown" aria-expanded="false">
                                            <xsl:value-of select="//tei:list[@type='selectPar']/tei:head"/>
                                        </button>
                                        <ul class="dropdown-menu" id="selPar" aria-labelledby="selectParNoButton">
                                            <xsl:for-each select="//tei:list[@type='selectPar']/tei:item[starts-with(.,'V')]">
                                                <xsl:sort select="xs:integer(substring-after(substring-before(.,'.'),'V'))"/> 
                                                <xsl:copy><a class="dropdown-item"  href="diff_{.}.html"><xsl:value-of select="replace(., 'xyz', '')"/></a></xsl:copy>
                                            </xsl:for-each>
                                            <xsl:for-each select="//tei:list[@type='selectPar']/tei:item[not(starts-with(.,'V'))]">
                                                <xsl:sort select="xs:integer(substring-before(.,'.'))"/> 
                                                <xsl:copy><a class="dropdown-item"  href="diff_{.}.html"><xsl:value-of select="replace(., 'xyz', '')"/></a></xsl:copy>
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
                                                                        <a class="prevLink" href="{./tei:ref[@type='prevLink']/@target}">
                                                                            <xsl:value-of select="./tei:ref[@type='prevLink']"/>
                                                                        </a>
                                                                    </xsl:if>
                                                                    <xsl:if test="./tei:ref[not(@type)]">
                                                                        <a class="link_ref" href="{./tei:ref[not(@type)]/@target}">
                                                                            <xsl:value-of select="./tei:ref[not(@type)]"/>
                                                                        </a>
                                                                    </xsl:if>                                                                
                                                                    <xsl:if test="./tei:ref[@type='nextLink']">
                                                                        <a class="nextlink" href="{./tei:ref[@type='nextLink']/@target}">
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
                                            <label for="selectV1">Compare</label>
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
                                            <label for="selectV2">… with </label>
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
                                            <label for="diffLevel">Level of Comparison</label>
                                            <select class="form-select" id="diffLevel">
                                                <option value="words">words</option>
                                                <option value="sentences">sentences</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <button class="btn btn-primary" id="compBtn" onclick="compare()">compare</button>
                                        </div>
                                    </div>
                                    <div class="row p-2">
                                        <p id="display"></p>
                                    </div>
                                </div>
                            </div>
                        </div> 
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
                <script type="text/javascript" src="assets/js/diff.js"/>
                <script type="text/javascript" src="assets/js/comp.js"/>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>