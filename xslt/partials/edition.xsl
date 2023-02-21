<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl tei" version="2.0">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            <h1>Widget annotation options.</h1>
            <p>Contact person: daniel.stoxreiter@oeaw.ac.at</p>
            <p>Applied with call-templates in html:body.</p>
            <p>Custom template to create interactive options for text annoations.</p>
        </desc>    
    </doc>
    
    <xsl:template name="editions">
        <div id="edtion-navBarNavDropdown" class="dropdown navBarNavDropdown">
            <!-- Your menu goes here -->
            <a title="Auflage" href="#" data-bs-toggle="dropdown" data-bs-auto-close="true" aria-expanded="false" role="button" class="dropdown">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-journals" viewBox="0 0 16 16">
                    <path d="M5 0h8a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2 2 2 0 0 1-2 2H3a2 2 0 0 1-2-2h1a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V4a1 1 0 0 0-1-1H3a1 1 0 0 0-1 1H1a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v9a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1H5a1 1 0 0 0-1 1H3a2 2 0 0 1 2-2z"/>
                    <path d="M1 6v-.5a.5.5 0 0 1 1 0V6h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 1 0-1H1zm0 3v-.5a.5.5 0 0 1 1 0V9h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 1 0-1H1zm0 2.5v.5H.5a.5.5 0 0 0 0 1h2a.5.5 0 0 0 0-1H2v-.5a.5.5 0 0 0-1 0z"/>
                </svg>
            </a>                    
            <ul class="dropdown-menu">
                <xsl:for-each select="collection('../../data/traktat/editions')//tei:TEI">
                    <xsl:sort select="tokenize(document-uri(/), '/')[last()]" />
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <li>
                                <a class="dropdown-item active" aria-current="page" href="{replace(tokenize(document-uri(/), '/')[last()], '.xml', '.html')}"
                                    title="">
                                    <xsl:value-of select="concat('Auflage ', position(), ' (', //tei:sourceDesc//tei:imprint//tei:date/@when, ')')"/>
                                </a>
                            </li>
                        </xsl:when>
                        <xsl:otherwise>
                            <li>
                                <a class="dropdown-item" href="{replace(tokenize(document-uri(/), '/')[last()], '.xml', '.html')}"
                                    title="">
                                    <xsl:value-of select="concat('Auflage ', position(), ' (', //tei:sourceDesc//tei:imprint//tei:date/@when, ')')"/>
                                </a>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </ul>                                                    
        </div>
        <script type="text/javascript">
            $('#edition-navBarNavDropdown .dropdown-menu .nav-item').click(function(e) {
                e.stopPropagation();
            });
        </script>
        
    </xsl:template>
</xsl:stylesheet>