<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl tei" version="2.0">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            <h1>Widget dcoument download.</h1>
            <p>Contact person: daniel.elsner@oeaw.ac.at</p>
            <p>Applied with call-templates in html:body.</p>
            <p>Custom template to make download options available.</p>
        </desc>    
    </doc>
    
    <xsl:template name="document-download">
        <xsl:param name="edition"/>
        <div id="document-download">
            <div id="aot-navBarNavDropdown" class="navBarNavDropdown dropstart">
                <!-- Your menu goes here -->
                <a aria-label="Downloads" href="#" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false" role="button">
                    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="currentColor" class="bi bi-file-earmark-arrow-down" viewBox="0 0 16 16">
                        <path d="M8.5 6.5a.5.5 0 0 0-1 0v3.793L6.354 9.146a.5.5 0 1 0-.708.708l2 2a.5.5 0 0 0 .708 0l2-2a.5.5 0 0 0-.708-.708L8.5 10.293z"/>
                        <path d="M14 14V4.5L9.5 0H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2M9.5 3A1.5 1.5 0 0 0 11 4.5h2V14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h5.5z"/>
                    </svg>
                </a>                    
                <ul class="dropdown-menu">
                    <li class="dropdown-item">
                        <xsl:choose>
                            <xsl:when test="$edition = 'traktat'">
                            <ul>
                                <li><a href="{concat('https://id.acdh.oeaw.ac.at/hanslick-vms/', //tei:TEI/@xml:id, '?format=raw')}"
                                    aria-label="TEI/XML Document Download">
                                    TEI/XML 
                                </a></li>
                                <li><a href="{concat('pdf/', substring-before(//tei:TEI/@xml:id, '.xml'), '.pdf')}"
                                    aria-label="PDF Document Download">
                                    PDF (beta)
                                </a></li>
                            </ul>
                            </xsl:when>
                            <xsl:when test="$edition = 'kritiken'">
                                <a target="_blank"
                                    href="{concat('https://raw.githubusercontent.com/Hanslick-Online/hsl-data-ct/main/data/editions/', substring-after(//tei:TEI/@xml:id, 'c__'))}"
                                    aria-label="TEI/XML Document Download"
                                    download="{substring-before(//tei:TEI/@xml:id, '.xml')}">
                                    TEI/XML 
                                </a>
                            </xsl:when>
                            <xsl:when test="$edition = 'vms'">
                                <a target="_blank"
                                    href="{concat('https://raw.githubusercontent.com/Hanslick-Online/hsl-data-vms/main/data/editions/', substring-after(//tei:TEI/@xml:id, 'v__'))}"
                                    aria-label="TEI/XML Document Download"
                                    download="{substring-before(//tei:TEI/@xml:id, '.xml')}">
                                    TEI/XML 
                                </a>
                            </xsl:when>
                              <xsl:when test="$edition = 'doc'">
                                <a target="_blank"
                                    href="{concat('https://raw.githubusercontent.com/Hanslick-Online/hsl-vms-docs/main/data/editions/', substring-after(//tei:TEI/@xml:id, 'd__'))}"
                                    aria-label="TEI/XML Document Download"
                                    download="{substring-before(//tei:TEI/@xml:id, '.xml')}">
                                    TEI/XML 
                                </a>
                            </xsl:when>
                       </xsl:choose>
                    </li>
                </ul>                                                    
            </div>
        </div> 
    </xsl:template>
</xsl:stylesheet>
