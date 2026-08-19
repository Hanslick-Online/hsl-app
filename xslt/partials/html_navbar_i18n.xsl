<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs"
    version="2.0">

    <xsl:template match="/" name="nav_bar_i18n">
        <div class="wrapper-fluid wrapper-navbar sticky-top" id="wrapper-navbar">
            <a class="skip-link screen-reader-text sr-only" href="#content">Skip to content</a>
            <nav class="autohide navbar navbar-expand-lg">
                <div class="container">
                    <a data-lang="de" href="index.html?lang=de" class="navbar-brand custom-logo-link" rel="home" itemprop="url">
                        <img src="{$project_logo}" class="img-fluid" title="{$project_short_title}" alt="{$project_short_title}" itemprop="logo"/>
                    </a>
                    <a data-lang="en" hidden="hidden" href="index.html?lang=en" class="navbar-brand custom-logo-link" rel="home" itemprop="url">
                        <img src="{$project_logo}" class="img-fluid" title="{$project_short_title}" alt="{$project_short_title}" itemprop="logo"/>
                    </a>
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse justify-content-end" id="navbarSupportedContent">
                        <ul class="navbar-nav mb-2 mb-lg-0">
                            <li class="nav-item dropdown">
                                <a data-lang="de" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Projekt</a>
                                <a data-lang="en" hidden="hidden" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Project</a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="bedeutung-hanslick.html?lang=de">Hanslicks historische Bedeutung</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="bedeutung-hanslick.html?lang=en">Hanslick's Historical Relevance</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="projektgeschichte.html?lang=de">Geschichte von <i>Hanslick Online</i></a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="projektgeschichte.html?lang=en">History of Hanslick Online</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="projektziele.html?lang=de">Projektziele von <i>Hanslick Online</i></a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="projektziele.html?lang=en">Project Targets</a>
                                    </li>
                                </ul>
                            </li>
                            <li class="nav-item dropdown">
                                <a data-lang="de" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Edition</a>
                                <a data-lang="en" hidden="hidden" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Edition</a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="toc_t.html?lang=de">Traktat (<i>VMS</i>)</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="toc_t.html?lang=en">Treatise (<i>VMS</i>)</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="toc.html?lang=de">Kritiken (<i>Neue Freie Presse</i>)</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="toc.html?lang=en">Reviews (<i>Neue Freie Presse</i>)</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="toc_vms.html?lang=de">Kritiken von <i>VMS</i></a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="toc_vms.html?lang=en">Reviews of <i>VMS</i></a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="toc_doc.html?lang=de">Dokumente zu <i>VMS</i></a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="toc_doc.html?lang=en">Documents on <i>VMS</i></a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="editionsrichtlinien-und-how-to-cite.html?lang=de" title="Editionsrichtlinine">Editionsrichtlinien und Zitiervorschlag</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="editionsrichtlinien-und-how-to-cite.html?lang=en" title="Editorial Conventions">Editorial Conventions and How to Cite</a>
                                    </li>
                                </ul>
                            </li>
                            <li class="nav-item dropdown">
                                <a data-lang="de" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Indizes</a>
                                <a data-lang="en" hidden="hidden" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Indexes</a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="listplace.html?lang=de">Ortsregister</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="listplace.html?lang=en">Places</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="listperson.html?lang=de">Personenregister</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="listperson.html?lang=en">Persons</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="listbibl.html?lang=de">Werkregister</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="listbibl.html?lang=en">Works</a>
                                    </li>
                                    <li>
                                        <span data-lang="de" class="dropdown-item text-muted">Begriffsregister</span>
                                        <span data-lang="en" hidden="hidden" class="dropdown-item text-muted">Terms</span>
                                    </li>
                                </ul>
                            </li>
                            <li class="nav-item dropdown">
                                <a data-lang="de" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Visualisierungen<sup  style="font-variant: small-caps;">beta</sup></a>
                                <a data-lang="en" hidden="hidden" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Visualizations<sup  style="font-variant: small-caps">beta</sup></a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="g_chart.html">Allgemeines Diagramm</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="g_chart.html">General chart</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="g_vmschart.html"><i>VMS</i>-Diagramm</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="g_vmschart.html"><i>VMS</i> chart</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="g_net.html">Allgemeiner Beziehungsgraph</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="g_net.html">General relationship graph</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="g_vmsnet.html"><i>VMS</i>-Beziehungsgraph</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="g_vmsnet.html"><i>VMS</i> relationship graph</a>
                                    </li>
                                </ul>
                            </li>
                            <li class="nav-item dropdown">
                                <a data-lang="de" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Aktivitäten</a>
                                <a data-lang="en" hidden="hidden" class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">Activities</a>
                                <ul class="dropdown-menu">
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="publikationen.html?lang=de" title="Publikationen">Publikationen</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="publikationen.html?lang=en" title="Publications">Publications</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="einzelvortraege.html?lang=de" title="Einzelvorträge">Einzelvorträge</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="einzelvortraege.html?lang=en" title="Lectures">Lectures</a>
                                    </li>
                                    <li>
                                        <a data-lang="de" class="dropdown-item" href="veranstaltungen.html?lang=de" title="Veranstaltungen">Veranstaltungen</a>
                                        <a data-lang="en" hidden="hidden" class="dropdown-item" href="veranstaltungen.html?lang=en" title="Events">Events</a>
                                    </li>
                                </ul>
                            </li>
                            <li class="nav-item">
                                <a data-lang="de" class="nav-link" href="team.html?lang=de">Team</a>
                                <a data-lang="en" hidden="hidden" class="nav-link" href="team.html?lang=en">Team</a>
                            </li>
                            <li class="nav-item">
                                <form class="form-inline my-3 my-lg-0" method="get" action="search.html?lang=de" data-action-de="search.html?lang=de" data-action-en="search.html?lang=en" role="search">
                                    <input class="form-control navbar-search" id="navbar-search" name="hsl[query]" type="text" placeholder="Suche" data-placeholder-de="Suche" data-placeholder-en="Search" value="" autocomplete="off"/>
                                    <button type="submit" class="navbar-search-icon">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-search" viewBox="0 0 16 16">
                                            <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z"/>
                                        </svg>
                                    </button>
                                </form>
                            </li>
                            <li class="nav-item" style="display:inline!important;margin:.4em auto;">
                                <a id="lang-switch-de" class="multi-lang nav-link pointer" href="#" data-set-lang="de">DE</a>
                                <a id="lang-switch-en" class="multi-lang nav-link pointer" href="#" data-set-lang="en">EN</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </div>
    </xsl:template>
</xsl:stylesheet>
