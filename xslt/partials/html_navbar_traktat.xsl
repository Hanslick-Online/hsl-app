<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs" version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template match="/" name="nav_bar">
        <div class="wrapper-fluid wrapper-navbar sticky-top" id="wrapper-navbar">
            <a class="skip-link screen-reader-text sr-only" href="#content">Skip to content</a>
            <nav class="navbar navbar-expand-lg bg-light">
                <div class="container-fluid">
                    <!-- Your site title as branding in the menu -->
                    <a href="index.html" class="navbar-brand custom-logo-link" rel="home" itemprop="url"><img src="{$project_logo}" class="img-fluid" title="{$project_short_title}" alt="{$project_short_title}" itemprop="logo" /></a><!-- end custom logo -->
                    <!--<a class="navbar-brand site-title-with-logo" rel="home" href="index.html" title="{$project_short_title}" itemprop="url"><xsl:value-of select="$project_short_title"/></a>-->
                    <span class="badge bg-light text-dark">in development</span>
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse d-flex justify-content-end" id="navbarSupportedContent">
                        <ul class="navbar-nav mb-2 mb-lg-0">
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Projekt
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="bedeutung-hanslick.html">
                                            Hanslicks historische Bedeutung
                                        </a>
                                    </li>
                                    
                                    <li>
                                        <a class="dropdown-item" href="projektgeschichte.html">
                                            Geschichte von "Hanslick im Kontext"
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="projektziele.html">
                                            Projektziele von "Hanslick Online"
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Traktat
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="einfuehrung-vms.html"
                                            title="Einführung VMS">
                                            Hanslick Ästhetik: Entstehung und Einführung
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="01_VMS_1854_TEI_AW_26-01-21-TEI-P5.html"
                                            title="Auflage 1">
                                            Applikation und Digitalisate
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="editionsrichtlinien-und-how-to-cite.html"
                                            title="Editionsrichtlinine">
                                            Editionsrichtlinine und How to Cite
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Aktivitäten
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="publikationen.html"
                                            title="Publikationen">
                                            Publikationen
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="einzelvortraege.html"
                                            title="Einzelvorträge">
                                            Einzelvorträge
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="veranstaltungen.html"
                                            title="Veranstaltungen">
                                            Veranstaltungen
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            
                            <li class="nav-item">
                                <a class="nav-link" href="team.html">Team</a>
                            </li>
                            
                            <li class="nav-item">
                                <a class="nav-link disabled">| Traktat: </a>
                            </li>
                            
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Auflage
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="01_VMS_1854_TEI_AW_26-01-21-TEI-P5.html">Auflage 1 (1854)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="02_VMS_1858_TEI_AW_26-01-21-TEI-P5.html">Auflage 2 (1858)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="03_VMS_1865_TEI_AW_26-01-21-TEI-P5.html">Auflage 3 (1865)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="04_VMS_1874_TEI_AW_26-01-21-TEI-P5.html">Auflage 4 (1874)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="05_VMS_1876_TEI_AW_26-01-21-TEI-P5.html">Auflage 5 (1876)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="06_VMS_1881_TEI_AW_26-01-21-TEI-P5.html">Auflage 6 (1881)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="07_VMS_1885_TEI_AW_26-01-21-TEI-P5.html">Auflage 7 (1885)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="08_VMS_1891_TEI_AW_26-01-21-TEI-P5.html">Auflage 8 (1891)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="09_VMS_1896_TEI_AW_26-01-21-TEI-P5.html">Auflage 9 (1896)</a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="10_VMS_1902_TEI_AW_26-01-21-TEI-P5.html">Auflage 10 (1902)</a>
                                    </li>
                                    <!--<xsl:for-each select="collection('../../data/traktat/editions')//tei:TEI">
                                        <li>
                                            <a class="dropdown-item" href="{replace(tokenize(document-uri(/), '/')[last()], '.xml', '.html')}"
                                                title="">
                                                <xsl:value-of select="concat('Auflage ', position(), ' (', //tei:sourceDesc//tei:imprint//tei:date/@when, ')')"/>
                                            </a>
                                        </li>
                                    </xsl:for-each>-->
                                </ul>
                            </li>
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Kapitel
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="#index_xml-body.1_div.0">
                                            [Titelseite]
                                        </a>
                                    </li>
                                    <xsl:for-each select=".//tei:body/tei:div/tei:head">
                                        <li>
                                            <a class="dropdown-item" href="#index_xml-body.1_div.{position()}">
                                                <xsl:choose>
                                                    <xsl:when test="contains(. ,'a)')">
                                                        <xsl:variable name="chapter" select="tokenize(., 'I')"/>
                                                        I. <xsl:value-of select="$chapter[2]"/>
                                                        <br/>
                                                        I. <xsl:value-of select="$chapter[3]"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="."/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </a>
                                        </li>
                                    </xsl:for-each>
                                    <li>
                                        <a class="dropdown-item" href="#index_xml-body.1_div.999">
                                            [Fußnoten]
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Indexes
                                </a>
                                <ul class="dropdown-menu">
                                    <xsl:for-each select="collection('../../data/traktat/indices')//tei:TEI">
                                        <li>
                                            <a class="dropdown-item" href="{replace(tokenize(document-uri(/), '/')[last()], '.xml', '.html')}"
                                                title="">
                                                <xsl:value-of select="//tei:titleStmt/tei:title"/>
                                            </a>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            
            <!-- .site-navigation -->
        </div>
    </xsl:template>
</xsl:stylesheet>