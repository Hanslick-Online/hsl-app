<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:graphics"
    version="2.0"
    exclude-result-prefixes="tei xsl xs local">

    <xsl:variable name="is-german" as="xs:boolean" select="exists(/tei:TEI/tei:text/tei:body[@xml:lang = 'de-AT'])"/>

    <xsl:function name="local:text" as="xs:string">
        <xsl:param name="de" as="xs:string"/>
        <xsl:param name="en" as="xs:string"/>
        <xsl:sequence select="if ($is-german) then $de else $en"/>
    </xsl:function>

    <xsl:function name="local:person-label" as="xs:string">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:sequence select="normalize-space(string-join((($person/tei:persName[@type='main'][1], $person/tei:persName[1])[1])//text(), ' '))"/>
    </xsl:function>
</xsl:stylesheet>
