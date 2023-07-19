<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs" version="2.0">

    <xsl:template match="/" name="nav_bar_en">
        <div class="wrapper-fluid wrapper-navbar sticky-top" id="wrapper-navbar">
            <a class="skip-link screen-reader-text sr-only" href="#content">Skip to content</a>
            <nav class="autohide navbar navbar-expand-lg bg-light">
                <div class="container">
                    <!-- Your site title as branding in the menu -->
                    <a href="index-en.html?lang=en" class="navbar-brand custom-logo-link" rel="home" itemprop="url"><img src="{$project_logo}" class="img-fluid" title="{$project_short_title}" alt="{$project_short_title}" itemprop="logo" /></a><!-- end custom logo -->
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse justify-content-end" id="navbarSupportedContent">
                        
                        <!--  ENGLISH navigation list -->
                        <ul class="navbar-nav mb-2 mb-lg-0 translate-en">
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Project
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="bedeutung-hanslick-engl.html?lang=en">
                                            Hanslick’s Historical Relevance
                                        </a>
                                    </li>
                                    
                                    <li>
                                        <a class="dropdown-item" href="projektgeschichte-engl.html?lang=en">
                                            History of "Hanslick in Context"
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="projektziele-engl.html?lang=en">
                                            Project Targets
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Edition
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="t__01_VMS_1854_TEI_AW_26-01-21-TEI-P5.html?lang=en"
                                            title="Treatise">
                                            Treatise
                                        </a>
                                    </li>
                                    <!-- <li>
                                        <a class="dropdown-item" href="toc.html?lang=en"
                                            title="Critics">
                                            Critics
                                        </a>
                                    </li> -->
                                    <li>
                                        <a class="dropdown-item" href="editionsrichtlinien-und-how-to-cite-engl.html?lang=en"
                                            title="Editorial Conventions">
                                            Editorial Conventions and How to Cite
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Indexes
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="listplace.html?lang=en"
                                            title="">
                                            Places
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="listperson.html?lang=en"
                                            title="">
                                            Persons
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="listbibl.html?lang=en"
                                            title="">
                                            Works
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            
                            <li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    Activities
                                </a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a class="dropdown-item" href="publikationen-engl.html?lang=en"
                                            title="Publications">
                                            Publications
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="einzelvortraege-engl.html?lang=en"
                                            title="Lectures">
                                            Lectures
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="veranstaltungen-engl.html?lang=en"
                                            title="Events">
                                            Events
                                        </a>
                                    </li>
                                </ul>
                            </li>
                            
                            <li class="nav-item">
                                <a class="nav-link" href="team-engl.html?lang=en">Team</a>
                            </li>
                            
                            <li class="nav-item">
                                <a class="nav-link" href="search-engl.html?lang=en">Search</a>
                            </li>
                            
                            <li class="nav-item" style="display:inline!important;margin:.4em auto;">
                                <multi-language opt="de"></multi-language>
                                <multi-language opt="en"></multi-language>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            
            <!-- .site-navigation -->
        </div>
    </xsl:template>
</xsl:stylesheet>