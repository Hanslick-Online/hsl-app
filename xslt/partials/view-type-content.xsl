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
    
    <xsl:template name="view-type-content">
        <xsl:param name="node_xpath" as="item()*"/>
        <xsl:if test="$node_xpath">
            <div class="card-body yes-index my-4">
                <a class="anchor" id="index.xml-body.1_div.999"></a>
                <h5>Fußnoten</h5>
                <ul class="footnotes">
                    <xsl:for-each select="$node_xpath">
                        <li>
                            <!-- in main edition.xsl -->
                            <xsl:call-template name="footnote">
                                <xsl:with-param name="inline" select="'false'"/>
                            </xsl:call-template>
                            <span class="footnote_text">
                                <xsl:apply-templates select="node() except tei:pb"/>
                            </span>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>