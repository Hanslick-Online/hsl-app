<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:import href="./partials/i18n-utils.xsl"/>

    <xsl:template match="/">
        <xsl:call-template name="redirect-page">
            <xsl:with-param name="canonicalPath" select="'toc_t.html'"/>
            <xsl:with-param name="defaultLang" select="'en'"/>
            <xsl:with-param name="htmlTitle" select="'Redirecting to table of contents'"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>