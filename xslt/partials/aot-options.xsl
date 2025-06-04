<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl tei" version="2.0">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            <h1>Widget annotation options.</h1>
            <p>Contact person: daniel.elsner@oeaw.ac.at</p>
            <p>Applied with call-templates in html:body.</p>
            <p>Custom template to create interactive options for text annotations.</p>
        </desc>    
    </doc>
    <xsl:template name="annotation-options">
        <xsl:param name="showSlider" />
        <div id="aot-navBarNavDropdown" class="navBarNavDropdown dropstart">
            <!-- Your menu goes here -->
            <a title="Annotationen" href="#" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false" role="button">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-pencil-square" viewBox="0 0 16 16">
                    <path d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z"/>
                    <path fill-rule="evenodd" d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5v11z"/>
                </svg>
            </a>                    
            <ul class="dropdown-menu">
                <!--<li class="dropdown-item">
                    <full-size opt="edition-fullsize"></full-size>
                </li>-->
                <li class="dropdown-item">
                    <image-switch opt="edition-switch"></image-switch>
                </li>
                <li class="dropdown-item">
                    <font-size opt="fs"></font-size>
                </li>
                <li class="dropdown-item">
                    <font-family opt="ff"></font-family>
                </li>
                <li class="dropdown-item" style="border-top: 2px dashed lightgrey !important;">
                    <annotation-slider opt="entities-features"></annotation-slider>
                </li>
                <li class="dropdown-item">
                    <annotation-slider opt="prs"></annotation-slider>
                </li>
                <li class="dropdown-item">
                    <annotation-slider opt="prsf"></annotation-slider>
                </li>
                <li class="dropdown-item">
                    <annotation-slider opt="plc"></annotation-slider>
                </li>
                <li class="dropdown-item">
                    <annotation-slider opt="wrk"></annotation-slider>
                </li>
                <xsl:if test="$showSlider = 'true'">
                    <li class="dropdown-item text-muted">
                        <annotation-slider opt="term"></annotation-slider>
                    </li>
                </xsl:if>
                <li class="dropdown-item">
                    <annotation-slider opt="pbs"></annotation-slider>
                </li>
            </ul>                                                    
        </div>
        <script type="text/javascript">
            $('#aot-navBarNavDropdown .dropdown-menu .nav-item').click(function(e) {
                e.stopPropagation();
            });
        </script>
        
    </xsl:template>
</xsl:stylesheet>
