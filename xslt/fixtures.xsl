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
    
    <xsl:template match="tei:lb"/>

    <xsl:template match="tei:p[not(@prev)]">
        <xsl:copy>
            <xsl:apply-templates/>
            <xsl:if test="following-sibling::tei:p[1]/@prev = 'true'">
                <xsl:for-each select="following-sibling::tei:p[1]">
                    <xsl:call-template name="pb-prev"/>
                    <xsl:apply-templates/>
                    <xsl:call-template name="prev-true"/>
                </xsl:for-each>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="//text()[ancestor::tei:body]">
        <xsl:choose>
            <xsl:when test="following-sibling::tei:*[1]/@break='no'">
                <xsl:value-of select="replace(replace(., '\n', ''), '\s+$', '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="prev-true">
        <xsl:if test="following-sibling::tei:p[1]/@prev = 'true'">
            <xsl:for-each select="following-sibling::tei:p[1]">
                <xsl:if test="preceding-sibling::tei:p[1]/@prev ='true'">
                    <xsl:call-template name="pb-prev"/>
                    <xsl:apply-templates/>
                    <xsl:call-template name="prev-true"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template name="pb-prev">
        <xsl:if test="preceding-sibling::tei:*[2]/name() = 'pb'">
            <xsl:for-each select="preceding-sibling::tei:*[2]">
                <pb facs="{@facs}" n="{@n}" xml:id="{@xml:id}"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:p[@prev]">
        <!--  do not display independently -->
    </xsl:template>
    <xsl:template match="tei:space">
        <xsl:value-of select="string-join((for $i in 1 to @quantity return '&#x00A0;'),'')"/>
    </xsl:template>
    <xsl:template match="tei:pb[following-sibling::tei:p[1]/@prev = 'true']">
        <!--  do not display independently -->
    </xsl:template>
    
</xsl:stylesheet>