<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:param name="collection" select="'../../data/traktat/edition'"/>
    <xsl:param name="compOutput" select="'../../data/traktat/comp'"/>
    <xsl:template match="node() | @*" mode="pre">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:output method="xml" indent="yes"/>
    

    <xsl:template match="tei:p[@n != '']" mode="pre">
        <xsl:variable name="prev" select="preceding::tei:p[@n != ''][1]/@n"/>
        <xsl:variable name="next" select="following::tei:p[@n != ''][1]/@n"/>
        <xsl:copy>
            <xsl:attribute name="source" select="root(.)//tei:sourceDesc//tei:edition/concat('VMS ',replace(@n,'^0+',''),' (',../tei:imprint/tei:date,')')"/>
            <xsl:attribute name="prev" select="$prev"/>
            <xsl:attribute name="next" select="$next"/>
            <xsl:attribute name="file" select="tokenize(base-uri(.),'/')[last()]"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:note" mode="pre"/>
    
    <xsl:template match="/">
        <xsl:for-each-group select="collection($collection)//tei:p[@n != '']" group-by="@n">
            <xsl:variable name="pre" as="element()+">
                <xsl:apply-templates select="current-group()" mode="pre"/>
            </xsl:variable>
            <xsl:result-document href="{$compOutput}/diff_{current-grouping-key()}.xml">
                <TEI xmlns="http://www.tei-c.org/ns/1.0">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>Concorance <xsl:value-of select="replace(current-grouping-key(), 'xyz', '')"/></title>
                            </titleStmt>
                            <publicationStmt>
                                <p>unpublished</p>
                            </publicationStmt>
                            <sourceDesc>
                                <p>born digital</p>
                            </sourceDesc>
                        </fileDesc>
                    </teiHeader>
                    <text>
                        <body>
<!--                            <xsl:if test="exists($prev) or exists($next)">-->
                                <list type="navigation">
                                   
                                    <item>
                                        <list type="selectPar">
                                            <head>Select Paragraph</head>
                                            <xsl:for-each select="distinct-values(collection($collection)//tei:p/@n[. != ''])">
                                                <item><xsl:value-of select="."/></item>
                                            </xsl:for-each>
                                        </list>
                                    </item>
                                </list>
                            <!--</xsl:if>-->
                            <table>
                                <row role="label">
                                    <xsl:for-each-group select="$pre" group-by="normalize-space(.)">
                                        <xsl:sort select="xs:integer(replace(@source,'\P{N}',''))" order="ascending"/>
                                        <cell>
                                            <xsl:for-each select="current-group()">
                                                <xsl:sort select="xs:integer(replace(@source,'\P{N}',''))" order="ascending"/>
                                                <seg type="sourceNav">
                                                    <xsl:if test="@prev != ''">
                                                         <ref type="prevLink" target="diff_{@prev}.html"><xsl:value-of select="replace(@prev, 'xyz', '')"/></ref>
                                                     </xsl:if>
                                                     <ref target="{@file}#{@xml:id}"><xsl:value-of select="@source"/></ref>
                                                     <xsl:if test="@next != ''">
                                                         <ref type="nextLink" target="diff_{@next}.html"><xsl:value-of select="replace(@next, 'xyz', '')"/></ref>
                                                     </xsl:if>
                                                </seg>
                                            </xsl:for-each>
                                        </cell>
                                    </xsl:for-each-group>
                                </row>
                                <row role="data">
                                    <xsl:for-each-group select="$pre" group-by="normalize-space(.)">
                                        <xsl:sort select="xs:integer(replace(@source,'\P{N}',''))" order="ascending"/>
                                        <cell xml:id="v{position()}"><xsl:value-of select="normalize-space(.)"/></cell>
                                    </xsl:for-each-group>
                                </row>
                            </table>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each-group>    
    </xsl:template>
</xsl:stylesheet>