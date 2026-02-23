<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs xsl tei" version="2.0">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>

    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            <h1>Widget image source.</h1>
            <p>Applied with call-templates in html:body.</p>
            <p>Shows a button that opens a modal displaying the facsimile source
               for the currently visible page image.</p>
        </desc>
    </doc>

    <!-- Dropdown widget: placed inside #editor-widget, same style as document-download -->
    <xsl:template name="image-source">
        <div id="image-source-widget">
            <div class="navBarNavDropdown dropstart">
                <a title="Bildquelle / Image source" href="#" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false" role="button">
                    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="currentColor" class="bi bi-image" viewBox="0 0 16 16">
                        <path d="M6.002 5.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0"/>
                        <path d="M2.002 1a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V3a2 2 0 0 0-2-2zm12 1a1 1 0 0 1 1 1v6.5l-3.777-1.947a.5.5 0 0 0-.577.093l-3.71 3.71-2.66-1.772a.5.5 0 0 0-.63.062L1.002 12V3a1 1 0 0 1 1-1z"/>
                    </svg>
                </a>
                <ul class="dropdown-menu">
                    <li class="dropdown-item">
                        <span class="translate-de">Bildquelle: </span>
                        <span class="translate-en">Image source: </span>
                        <span id="image-source-link">
                            <xsl:variable name="firstSource" select="(//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='facsimiles-source']/tei:relatedItem[@type='facsimile'])[1]"/>
                            <xsl:choose>
                                <xsl:when test="$firstSource">
                                    <a href="{$firstSource/@target}" target="_blank" rel="noopener noreferrer"><xsl:value-of select="$firstSource/@subtype"/></a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <em class="translate-de">Keine Quellenangabe vorhanden.</em>
                                    <em class="translate-en">No source information available.</em>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </li>
                </ul>
            </div>
            <!-- Hidden data container: one span per relatedItem[@type='facsimile'] -->
            <div id="image-source-data" style="display:none;">
                <xsl:for-each select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='facsimiles-source']/tei:relatedItem[@type='facsimile']">
                    <span class="image-source-item"
                          data-subtype="{@subtype}"
                          data-target="{@target}"/>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>

    <!-- Keep empty template so other XSLs that call it don't break -->
    <xsl:template name="image-source-modal"/>
</xsl:stylesheet>
