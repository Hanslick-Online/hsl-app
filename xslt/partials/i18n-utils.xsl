<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:hsl="https://hanslick.acdh.oeaw.ac.at/ns/hsl"
    version="2.0"
    exclude-result-prefixes="xs xsl tei hsl">

    <xsl:function name="hsl:canonical-html-from-source" as="xs:string">
        <xsl:param name="sourceName" as="xs:string"/>
        <xsl:sequence select="
            if ($sourceName = 'index-engl.xml' or $sourceName = 'index.xml')
            then 'index.html'
            else if ($sourceName = 'imprint_en.xml' or $sourceName = 'imprint.xml')
            then 'imprint.html'
            else if (matches($sourceName, '-engl\.xml$'))
            then replace($sourceName, '-engl\.xml$', '.html')
            else replace($sourceName, '\.xml$', '.html')
        "/>
    </xsl:function>

    <xsl:function name="hsl:partner-meta-uri" as="xs:string?">
        <xsl:param name="sourceUri" as="xs:string"/>
        <xsl:variable name="sourceName" select="tokenize($sourceUri, '/')[last()]"/>
        <xsl:variable name="partnerName" select="
            if ($sourceName = 'index.xml')
            then 'index-engl.xml'
            else replace($sourceName, '\.xml$', '-engl.xml')
        "/>
        <xsl:variable name="partnerUri" select="replace($sourceUri, concat($sourceName, '$'), $partnerName)"/>
        <xsl:sequence select="if (doc-available($partnerUri)) then $partnerUri else ()"/>
    </xsl:function>

    <xsl:function name="hsl:document-lang" as="xs:string">
        <xsl:param name="doc" as="node()"/>
        <xsl:sequence select="if (starts-with(string(($doc//tei:body/@xml:lang)[1]), 'en')) then 'en' else 'de'"/>
    </xsl:function>

    <xsl:function name="hsl:localize-target" as="xs:string">
        <xsl:param name="target" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>
        <xsl:sequence select="
            if (matches($target, '^(https?:|mailto:|#)') or not(contains($target, '.html')))
            then $target
            else if (contains($target, 'lang='))
            then replace($target, 'lang=(en|de)', concat('lang=', $lang))
            else if (contains($target, '.html?'))
            then concat($target, '&amp;lang=', $lang)
            else concat($target, '?lang=', $lang)
        "/>
    </xsl:function>

    <xsl:template name="localized-text">
        <xsl:param name="de" as="xs:string"/>
        <xsl:param name="en" as="xs:string"/>
        <span data-lang="de"><xsl:value-of select="$de"/></span>
        <span data-lang="en" hidden="hidden"><xsl:value-of select="$en"/></span>
    </xsl:template>

    <xsl:template name="redirect-page">
        <xsl:param name="canonicalPath" as="xs:string"/>
        <xsl:param name="defaultLang" as="xs:string" select="'en'"/>
        <xsl:param name="htmlTitle" as="xs:string" select="'Redirecting'"/>

        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="en">
            <head>
                <meta charset="utf-8"/>
                <title><xsl:value-of select="$htmlTitle"/></title>
                <meta http-equiv="refresh" content="{concat('0; url=', $canonicalPath, '?lang=', $defaultLang)}"/>
                <link rel="canonical" href="{$canonicalPath}"/>
                <script>
                    (function () {
                        const current = new URL(window.location.href);
                        const target = new URL("<xsl:value-of select="$canonicalPath"/>", current.href);
                        current.searchParams.forEach((value, key) =&gt; target.searchParams.set(key, value));
                        if (!['de', 'en'].includes(target.searchParams.get('lang'))) {
                            target.searchParams.set('lang', '<xsl:value-of select="$defaultLang"/>');
                        }
                        window.location.replace(`${target.pathname}?${target.searchParams.toString()}`);
                    })();
                </script>
            </head>
            <body>
                <p>
                    <a href="{concat($canonicalPath, '?lang=', $defaultLang)}">Continue</a>
                </p>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>