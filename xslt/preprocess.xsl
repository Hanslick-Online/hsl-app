<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:body">
        <xsl:copy>
            <div>
                <xsl:apply-templates select="node()|@*"/>
            </div>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:div[parent::tei:body]">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>
    <xsl:template match="tei:head[parent::tei:div]">
        <h2 xml:id="{generate-id()}">
            <xsl:apply-templates select="node()|@*"/>
        </h2>
    </xsl:template>
    
</xsl:stylesheet>