<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs" version="2.0">

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
                    <div class="collapse navbar-collapse justify-content-end" id="navbarSupportedContent">
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
                                        <a class="dropdown-item" href="t__01_VMS_1854_TEI_AW_26-01-21-TEI-P5.html"
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
                                    Kritiken
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="einfuehrung-vms.html"
                                            title="Einführung VMS">
                                            Hanslick Ästhetik: Entstehung und Einführung
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="toc.html"
                                            title="Übersicht">
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
                                    Indexes
                                </a>
                                <ul class="dropdown-menu">
                                    <xsl:for-each select="collection('../../data/indices')//tei:TEI">
                                        <li>
                                            <a class="dropdown-item" href="{replace(tokenize(document-uri(/), '/')[last()], '.xml', '.html')}"
                                                title="">
                                                <xsl:value-of select="tokenize(//tei:titleStmt/tei:title, '\s')[1]"/>
                                            </a>
                                        </li>
                                    </xsl:for-each>
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
                                <a class="nav-link" href="search.html">Suche</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            
            <!-- .site-navigation -->
        </div>
    </xsl:template>
</xsl:stylesheet>