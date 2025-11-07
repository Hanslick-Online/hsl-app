<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl xs"
    version="2.0">
    <xsl:template match="/" name="html_footer">
        <!-- GERMAN verison-->
        <div class="wrapper translate-de" id="wrapper-footer-full">
            <div class="container" id="footer-full-content" tabindex="-1">
                <div class="footer-separator">
                    KONTAKT
                    <hr></hr>
                </div>
                <div class="row">
                    <div class="footer-widget col-lg-1 col-md-2 col-sm-2 col-xs-6  ml-auto text-center ">
                        <div class="textwidget custom-html-widget">
                            <a href="https://www.oeaw.ac.at/acdh"><img src="https://fundament.acdh.oeaw.ac.at/common-assets/images/acdh_logo.svg" class="image" alt="ACDH Logo" style="max-width: 100%; height: auto;" title="ACDH Logo"/></a>
                        </div>
                    </div>
                    <!-- .footer-widget -->
                    <div class="footer-widget col-lg-4 col-md-3 col-sm-3">
                        <div class="textwidget custom-html-widget">
                            <p>
                                ACDH OEAW
                                <br/>
                                Austrian Centre for Digital Humanities
                                <br/>
                                Österreichische Akademie der Wissenschaften
                            </p>
                            <p>
                                Bäckerstraße 13
                                <br/>
                                1010 Wien
                            </p>
                            <p>
                                T: +43 1 51581-2200
                                <br/>
                                E: <a href="mailto:acdh-office@oeaw.ac.at">acdh-office@oeaw.ac.at</a>
                            </p>
                        </div>
                    </div>
                    <div class="footer-widget col-lg-4 col-md-3 col-sm-4">
                        <h6 class="font-weight-bold">PROJEKTPARTNER</h6>
                        <div class="row">
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="flex-md-row mb-4 align-items-center d-flex justify-content-center">
                                    <a href="https://www.fwf.ac.at"><img class="card-img-right flex-auto d-md-block" src="https://www.fwf.ac.at/fileadmin/Website/Logos/FWF_Logo.png" alt="FWF Der Wissenschaftsfond Logo" style="max-width: 200px; height: auto; margin-top:1em;" title="FWF Der Wissenschaftsfond" /></a>
                                    <!--<div class="card-body d-flex flex-column align-items-start">
                                        <p class="card-text mb-auto">Project partner</p>
                                    </div>-->
                                </div>
                            </div>
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="flex-md-row mb-4 align-items-center d-flex justify-content-center">
                                    <a href="https://www.wien.gv.at"><img class="card-img-right flex-auto d-md-block" src="images/csm_Stadt-Wien_Logo_pos_rgb_ae2ce8a131.png" alt="Stadt Wien Logo" style="max-width: 140px; height: auto; margin-top:1em;" title="Stadt Wien" /></a>
                                    <!--<div class="card-body d-flex flex-column align-items-start">
                                        <p class="card-text mb-auto">Project partner</p>
                                    </div>-->
                                </div>
                            </div>
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="flex-md-row mb-4 align-items-center d-flex justify-content-center">
                                    <a href="https://www.oenb.at"><img class="card-img-right flex-auto d-md-block" src="images/Oesterreichische_Nationalbank_Logo.svg" alt="Österreichische Nationalbank Logo" style="max-width: 200px; height: auto; margin-top:1em;" title="Österreichische Nationalbank" /></a>
                                    <!--<div class="card-body d-flex flex-column align-items-start">
                                        <p class="card-text mb-auto">Project partner</p>
                                    </div>-->
                                </div>
                            </div>
                            <div class="col-lg-12 col-md-12 col-sm-12">
                                <div class="flex-md-row mb-4 align-items-center d-flex justify-content-center">
                                    <a href="https://www.plus.ac.at/"><img class="card-img-right flex-auto d-md-block" src="images/PLUS_Logo.png" alt="Paris Lodron Universität Salzburg" style="max-width: 200px; height: auto; margin-top:1em;" title="Paris Lodron Universität Salzburg" /></a>
                                    <!--<div class="card-body d-flex flex-column align-items-start">
                                        <p class="card-text mb-auto">Project partner</p>
                                    </div>-->
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- .footer-widget -->                       
                    <div class="footer-widget col-lg-3 col-md-4 col-sm-3 ml-auto">
                        <div class="row">
                            <div class="textwidget custom-html-widget">
                                <h6 class="font-weight-bold">HELPDESK</h6>
                                <p>ACDH betreibt einen Helpdesk, an den Sie gerne Ihre Fragen zu Digitalen Geisteswissenschaften stellen dürfen.</p>
                                <p>
                                    <a class="helpdesk-button" href="mailto:acdh-office@oeaw.ac.at">FRAG UNS!</a>
                                </p>
                            </div>
                        </div>
                        <div class="row">
                            <div class="footer-widget col-lg-12 col-md-12 col-sm-12 ml-auto" style="margin-left:0 !important;">
                                <div class="textwidget custom-html-widget">
                                    <p style="margin-bottom:0 !important;">Social: </p>                                    
                                </div>
                                <div class="row">                              
                                    <div class="textwidget custom-html-widget col-md-4">                                    
                                        <a id="github-logo" title="GitHub" href="{$github_url}" class="nav-link" target="_blank">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-4.466 19.59c-.405.078-.534-.171-.534-.384v-2.195c0-.747-.262-1.233-.55-1.481 1.782-.198 3.654-.875 3.654-3.947 0-.874-.312-1.588-.823-2.147.082-.202.356-1.016-.079-2.117 0 0-.671-.215-2.198.82-.64-.18-1.324-.267-2.004-.271-.68.003-1.364.091-2.003.269-1.528-1.035-2.2-.82-2.2-.82-.434 1.102-.16 1.915-.077 2.118-.512.56-.824 1.273-.824 2.147 0 3.064 1.867 3.751 3.645 3.954-.229.2-.436.552-.508 1.07-.457.204-1.614.557-2.328-.666 0 0-.423-.768-1.227-.825 0 0-.78-.01-.055.487 0 0 .525.246.889 1.17 0 0 .463 1.428 2.688.944v1.489c0 .211-.129.459-.528.385-3.18-1.057-5.472-4.056-5.472-7.59 0-4.419 3.582-8 8-8s8 3.581 8 8c0 3.533-2.289 6.531-5.466 7.59z"/></svg>                                
                                        </a>
                                    </div>                                                                        
                                </div>   
                                <div class="row">                         
                                    <div class="custom-html-widget col-12 py-2 d-block">   
                                        <label>App: </label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.7825053"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.7825053.svg" alt="DOI"/></a>
                                    </div>
                                    <div class="custom-html-widget col-12 py-2 d-block">   
                                        <label>Data (VMS):</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.7825038"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.7825038.svg" alt="DOI"/></a>
                                    </div>
                                    <div class="custom-html-widget col-12 py-2  d-block">   
                                        <label>Data (NFP):</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.8033446"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.8033446.svg" alt="DOI"/></a>
                                    </div>
	                            <div class="custom-html-widget col-12 py-2  d-block">   
                                        <label>Data (Reviews of VMS):</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.15274665"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.15274665.svg" alt="DOI"/></a>
                                    </div>
	                            <div class="custom-html-widget col-12 py-2  d-block">
                                        <label>Data (Documents):</label>
                                        <a class="d-block" href="https://doi.org/10.5281/zenodo.15744324"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.15744324.svg" alt="DOI"/></a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- .footer-widget -->
                </div>
            </div>
        </div>
       
        <!-- #wrapper-footer-full -->
        <div class="footer-imprint-bar bg-dark text-light" id="wrapper-footer-secondary" style="text-align:center; padding:0.4rem 0; font-size: 0.9rem;" >
            © Copyright OEAW | <a href="imprint.html?lang=de">Impressum/Imprint</a>
        </div>
        <div id="cookie-overlay">
            <div class="container">
                <div class="cookie-message">This website uses cookies to ensure you get the best experience on our website. <a href="imprint.html?lang=de">More info</a><br/></div>  
                <div class="cookie-buttons">
                    <div class="cookie-accept-btn">Accept All Cookies (functional and tracking)</div>
                    <div class="cookie-accept-necessary-btn">Accept Necessary Cookies Only</div>
                </div>
            </div>
        </div>
        <script type="text/javascript">
            $(document).ready(function() {
                $('li a.active').removeClass('active');
                $('a[href="' + location.pathname.split("/").at(-1) + '"]').addClass('active');
            });
        </script>
        <!--<script src="js/detect_language_set_params.js"></script>
        <script src="js/update_doc_language.js"></script>-->
        <script src="https://unpkg.com/de-micro-editor@0.3.1/dist/de-editor.min.js"></script>
        <!--<script type="text/javascript" src="dist/de-editor.min.js"></script>-->
        <script src="js/navbar-autohide.js"></script>
        <script src="js/cookie-consent.js"></script>
        <script src="js/nav-show-hide.js"></script>
    </xsl:template>
</xsl:stylesheet>
