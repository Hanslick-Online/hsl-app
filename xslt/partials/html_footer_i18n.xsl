<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl xs"
    version="2.0">
    <xsl:template match="/" name="html_footer_i18n">
        <div class="wrapper" id="wrapper-footer-full">
            <div class="container" id="footer-full-content" tabindex="-1">
                <div data-lang="de" class="footer-separator">KONTAKT<hr/></div>
                <div data-lang="en" hidden="hidden" class="footer-separator">CONTACT<hr/></div>
                <div class="row">
                    <div class="footer-widget col-lg-1 col-md-2 col-sm-2 col-xs-6 ml-auto text-center">
                        <div class="textwidget custom-html-widget">
                            <a href="https://www.oeaw.ac.at/acdh">
                                <img src="https://fundament.acdh.oeaw.ac.at/common-assets/images/acdh_logo.svg" class="image" alt="ACDH Logo" style="max-width: 100%; height: auto;" title="ACDH Logo"/>
                            </a>
                        </div>
                    </div>
                    <div class="footer-widget col-lg-4 col-md-3 col-sm-3">
                        <div class="textwidget custom-html-widget">
                            <p>
                                ACDH OEAW<br/>
                                <span data-lang="de">Austrian Centre for Digital Humanities<br/>Österreichische Akademie der Wissenschaften</span>
                                <span data-lang="en" hidden="hidden">Austrian Centre for Digital Humanities<br/>Austrian Academy of Sciences</span>
                            </p>
                            <p>
                                Bäckerstraße 13<br/>
                                <span data-lang="de">1010 Wien</span>
                                <span data-lang="en" hidden="hidden">1010 Vienna</span>
                            </p>
                            <p>
                                ☎ +43 1 51581-2200<br/>
                                🖂 <a href="mailto:acdh-officek@oeaw.ac.at">acdh-office@oeaw.ac.at</a>
                            </p>
                        </div>
                        <div class="textwidget custom-html-widget">
                            <h6 data-lang="de" class="font-weight-bold">HELPDESK</h6>
                            <h6 data-lang="en" hidden="hidden" class="font-weight-bold">HELPDESK</h6>
                            <p data-lang="de">ACDH betreibt einen Helpdesk, an den Sie gerne Ihre Fragen zu Digitalen Geisteswissenschaften stellen dürfen.</p>
                            <p data-lang="en" hidden="hidden">ACDH runs a helpdesk offering advice for questions related to various digital humanities topics.</p>
                        </div>
                    </div>
                    <div class="footer-widget col-lg-4 col-md-3 col-sm-4">
                        <h6 data-lang="de" class="font-weight-bold">PROJEKTPARTNER</h6>
                        <h6 data-lang="en" hidden="hidden" class="font-weight-bold">PROJECT PARTNERS</h6>
                        <div class="row">
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="flex-md-row mb-4 align-items-center d-flex justify-content-center">
                                    <a href="https://www.fwf.ac.at">
                                        <img class="card-img-right flex-auto d-md-block" src="https://www.fwf.ac.at/fileadmin/Website/Logos/FWF_Logo.png" alt="FWF Der Wissenschaftsfond Logo" style="max-width: 200px; height: auto; margin-top:1em;" title="FWF Der Wissenschaftsfond"/>
                                    </a>
                                </div>
                            </div>
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="flex-md-row mb-4 align-items-center d-flex justify-content-center">
                                    <a href="https://www.wien.gv.at">
                                        <img class="card-img-right flex-auto d-md-block" src="images/csm_Stadt-Wien_Logo_pos_rgb_ae2ce8a131.png" alt="Stadt Wien Logo" style="max-width: 140px; height: auto; margin-top:1em;" title="Stadt Wien"/>
                                    </a>
                                </div>
                            </div>
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="flex-md-row mb-4 align-items-center d-flex justify-content-center">
                                    <a href="https://www.oenb.at">
                                        <img class="card-img-right flex-auto d-md-block" src="images/Oesterreichische_Nationalbank_Logo.svg" alt="Österreichische Nationalbank Logo" style="max-width: 200px; height: auto; margin-top:1em;" title="Österreichische Nationalbank"/>
                                    </a>
                                </div>
                            </div>
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="flex-md-row mb-4 align-items-center d-flex justify-content-center">
                                    <a href="https://www.plus.ac.at/">
                                        <img class="card-img-right flex-auto d-md-block" src="images/PLUS_Logo.png" alt="Paris Lodron Universität Salzburg" style="max-width: 200px; height: auto; margin-top:1em;" title="Paris Lodron Universität Salzburg"/>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="footer-widget col-lg-3 col-md-4 col-sm-3 ml-auto">
                        <div class="row">
                            <div class="footer-widget col-lg-12 col-md-12 col-sm-12 ml-auto" style="margin-left:0 !important;">
                                <div class="row">
                                    <div class="textwidget custom-html-widget col-md-4">
                                        <a id="github-logo" title="GitHub" href="{$github_url}" class="nav-link" target="_blank">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24">
                                                <path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-4.466 19.59c-.405.078-.534-.171-.534-.384v-2.195c0-.747-.262-1.233-.55-1.481 1.782-.198 3.654-.875 3.654-3.947 0-.874-.312-1.588-.823-2.147.082-.202.356-1.016-.079-2.117 0 0-.671-.215-2.198.82-.64-.18-1.324-.267-2.004-.271-.68.003-1.364.091-2.003.269-1.528-1.035-2.2-.82-2.2-.82-.434 1.102-.16 1.915-.077 2.118-.512.56-.824 1.273-.824 2.147 0 3.064 1.867 3.751 3.645 3.954-.229.2-.436.552-.508 1.07-.457.204-1.614.557-2.328-.666 0 0-.423-.768-1.227-.825 0 0-.78-.01-.055.487 0 0 .525.246.889 1.17 0 0 .463 1.428 2.688.944v1.489c0 .211-.129.459-.528.385-3.18-1.057-5.472-4.056-5.472-7.59 0-4.419 3.582-8 8-8s8 3.581 8 8c0 3.533-2.289 6.531-5.466 7.59z"/>
                                            </svg>
                                        </a>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="custom-html-widget col-12 py-1 d-block">
                                        <label>App:</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.7825053">
                                            <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.7825053.svg" alt="DOI"/>
                                        </a>
                                    </div>
                                    <div class="custom-html-widget col-12 py-1 d-block">
                                        <label>VMS:</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.7825038">
                                            <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.7825038.svg" alt="DOI"/>
                                        </a>
                                    </div>
                                    <div class="custom-html-widget col-12 py-1 d-block">
                                        <label>NFP:</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.8033446">
                                            <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.8033446.svg" alt="DOI"/>
                                        </a>
                                    </div>
                                    <div class="custom-html-widget col-12 py-1 d-block">
                                        <label>Reviews of VMS:</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.15274665">
                                            <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.15274665.svg" alt="DOI"/>
                                        </a>
                                    </div>
                                    <div class="custom-html-widget col-12 py-1 d-block">
                                        <label>Documents:</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.15744324">
                                            <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.15744324.svg" alt="DOI"/>
                                        </a>
                                    </div>
                                    <div class="custom-html-widget col-12 py-1 d-block">
                                        <label>Entities:</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.22007952">
                                            <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.22007952.svg" alt="DOI"/>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="footer-imprint-bar bg-dark text-light" id="wrapper-footer-secondary" style="text-align:center; padding:0.4rem 0; font-size: 0.9rem;">
            <span>&#169; Copyright OEAW | </span>
            <a data-lang="de" href="imprint.html?lang=de">Impressum/Imprint</a>
            <a data-lang="en" hidden="hidden" href="imprint.html?lang=en">Impressum/Imprint</a>
        </div>
        <div id="cookie-overlay">
            <div class="container">
                <div data-lang="de" class="cookie-message">Diese Website verwendet Cookies, um Ihnen die bestmögliche Nutzung zu ermöglichen. <a href="imprint.html?lang=de">Weitere Informationen</a><br/></div>
                <div data-lang="en" hidden="hidden" class="cookie-message">This website uses cookies to ensure you get the best experience on our website. <a href="imprint.html?lang=en">More info</a><br/></div>
                <div class="cookie-buttons">
                    <div data-lang="de" class="cookie-accept-btn">Alle Cookies akzeptieren (funktional und Tracking)</div>
                    <div data-lang="en" hidden="hidden" class="cookie-accept-btn">Accept All Cookies (functional and tracking)</div>
                    <div data-lang="de" class="cookie-accept-necessary-btn">Nur notwendige Cookies akzeptieren</div>
                    <div data-lang="en" hidden="hidden" class="cookie-accept-necessary-btn">Accept Necessary Cookies Only</div>
                </div>
            </div>
        </div>
        <script src="js/site-language.js"></script>
        <script src="js/navbar-autohide.js"></script>
        <script src="js/cookie-consent.js"></script>
        <script src="js/nav-show-hide.js"></script>
    </xsl:template>
</xsl:stylesheet>
