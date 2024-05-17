<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:import href="partials/html_navbar.xsl"/>
    <xsl:import href="partials/aot-options.xsl"/>
    <xsl:import href="partials/chapters.xsl"/>
    <xsl:import href="partials/book-edition.xsl"/>
    <xsl:import href="partials/view-type.xsl"/>
    <xsl:import href="partials/view-type-content.xsl"/>
    <xsl:import href="partials/entities-modal.xsl"/>
    <xsl:import href="partials/next-prev-page.xsl"/>
    <xsl:import href="partials/document-download.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:titleStmt//tei:title[@type='main'][1]/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
                <link rel="stylesheet" href="css/de-micro-editor.css"></link>
            </head>
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid" style="max-width:75%; margin: 2em auto;">
                        <xsl:call-template name="view-type">
                            <xsl:with-param name="anotation-options" select="'true'"/>
                            <xsl:with-param name="editor-widget" select="'true'"/>
                            <xsl:with-param name="back-btn" select="'true'"/>
                            <xsl:with-param name="book-chapters" select="'false'"/>
                            <xsl:with-param name="book-editions" select="'false'"/>
                            <xsl:with-param name="footnotes" select="'true'"/>
                            <xsl:with-param name="footnotes-xpath"
                                as="item()*"
                                select="//tei:body//tei:note[@type='footnote']"/>
                            <xsl:with-param name="body-xpath" as="item()*" select="//tei:body"/>
                            <xsl:with-param name="edition-project-class">
                                <xsl:text>section-critics</xsl:text>
                            </xsl:with-param>
                            <xsl:with-param name="front-page" select="'false'"/>
                            <xsl:with-param name="back-page" select="'true'"/>
                            <xsl:with-param name="next-prev-page" select="'true'"/>
                            <xsl:with-param name="document-download" select="'true'"/>
                            <xsl:with-param name="document-download-edition" select="'kritiken'"/>
                        </xsl:call-template>
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/mark.js/8.11.1/mark.min.js"></script>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.0.0/openseadragon.min.js"></script>
                <script type="text/javascript" src="js/mark.js"></script>
                <script type="text/javascript" src="js/run_editions.js"></script>
                <script type="text/javascript" src="js/osd.js"></script>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="tei:div[parent::tei:body]">
        <p class="yes-index meta-head">
            <xsl:value-of select="//tei:sourceDesc//tei:monogr/tei:title[@type='main']"/><br/>
            <xsl:value-of select="//tei:sourceDesc//tei:monogr/tei:title[@type='sub']"/><br/>
            <xsl:value-of select="//tei:sourceDesc//tei:analytic/tei:title"/><br/>
            <!--<xsl:value-of select="//tei:sourceDesc//tei:date"/>-->
        </p>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:p[not(@prev)]">
        <p class="yes-index">
            <xsl:apply-templates/>
            <xsl:if test="following-sibling::tei:p[1]/@prev = 'true'">
                <xsl:for-each select="following-sibling::tei:p[1]">
                    <xsl:call-template name="pb-prev"/>
                    <xsl:apply-templates/>
                    <xsl:call-template name="prev-true"/>
                </xsl:for-each>
            </xsl:if>
        </p>
    </xsl:template>
    <xsl:template match="//text()[ancestor::tei:body]">
        <xsl:choose>
            <xsl:when test="following-sibling::tei:*[1]/@break='no'">
                <xsl:value-of select="replace(., '\s+$', '')"/>
            </xsl:when>
            <xsl:when test="matches(., '-$', 'm')">
                <xsl:value-of select="replace(., '\s+$', '')"/>
            </xsl:when>
            <xsl:when test="following-sibling::tei:*[1]/@type='footnote'">
                <xsl:value-of select="replace(., '\s+$', '')"/>
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
                <xsl:variable name="graphic-url" select="substring-before(id(data(substring-after(@facs, '#')))/tei:graphic/@url, '.jpg')"/>
                <span class="anchor-pb" source="hsl-nfp/{$graphic-url}"></span>
                <span class="pb pb-prev">[<xsl:value-of select="@n"/>]</span>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:p[@prev]">
        <!--  do not display independently -->
    </xsl:template>
    <!--<xsl:template match="text()[following-sibling::tei:*[1]/@break = 'no']">
        <span class="wrd-brk-txt"><xsl:value-of select="normalize-space(.)"/></span>
    </xsl:template>-->
    <xsl:template match="tei:space">
        <span class="space">
            <xsl:value-of select="string-join((for $i in 1 to @quantity return '&#x00A0;'),'')"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:head[ancestor::tei:body]">
        <xsl:choose>
            <xsl:when test="@type='h1'">
                <h1 class="yes-index"><xsl:apply-templates/></h1>
            </xsl:when>
            <xsl:when test="@type='h2'">
                <h2 class="yes-index"><xsl:apply-templates/></h2>
            </xsl:when>
            <xsl:when test="@type='h3'">
                <h3 class="yes-index"><xsl:apply-templates/></h3>
            </xsl:when>
            <xsl:when test="@type='h4'">
                <h4 class="yes-index"><xsl:apply-templates/></h4>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:choice">
        <span class="choice" title="{./tei:corr}"><xsl:value-of select="./tei:sic"/></span>
    </xsl:template>
    <xsl:template match="tei:lb">
        <xsl:if test="@break='no'">
            <span class="pb wrdbreak">-</span>
        </xsl:if>
        <xsl:if test="ancestor::tei:p and not(ancestor::tei:note)">
            <br class="pb"/>
            <a>
                <xsl:variable name="para" as="xs:int">
                    <xsl:number level="any" from="tei:body" count="tei:p"/>
                </xsl:variable>
                <xsl:variable name="lines" as="xs:int">
                    <xsl:number level="any" from="tei:body" count="tei:lb"/>
                </xsl:variable>
                <xsl:attribute name="href">
                    <xsl:text>#</xsl:text><xsl:value-of select="ancestor::tei:div/@xml:id"/><xsl:text>__p</xsl:text><xsl:value-of select="$para"/><xsl:text>__lb</xsl:text><xsl:value-of select="$lines"/>
                </xsl:attribute>
                <xsl:attribute name="name">
                    <xsl:value-of select="ancestor::tei:div/@xml:id"/><xsl:text>__p</xsl:text><xsl:value-of select="$para"/><xsl:text>__lb</xsl:text><xsl:value-of select="$lines"/>
                </xsl:attribute>
                <xsl:attribute name="id">
                    <xsl:value-of select="ancestor::tei:div/@xml:id"/><xsl:text>__p</xsl:text><xsl:value-of select="$para"/><xsl:text>__lb</xsl:text><xsl:value-of select="$lines"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="($lines mod 5) = 0">
                        <xsl:attribute name="class">
                            <xsl:text>linenumbersVisible linenumbers pb</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="data-lbnr">
                            <xsl:value-of select="$lines"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">
                            <xsl:text>linenumbersTransparent linenumbers pb</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="format-number($lines, '0000')"/>
            </a>  
        </xsl:if>
        <xsl:if test="ancestor::tei:note and position() = 1">
            
        </xsl:if>
        <xsl:if test="ancestor::tei:note and position() != 1">
            <br class="pb"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:hi">
        <xsl:choose>
            <xsl:when test="@rendition='#em'">
                <span class="italic"><xsl:apply-templates/></span>
            </xsl:when>
            <xsl:when test="@rendition='#bold'">
                <span class="bold"><xsl:apply-templates/></span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:rs">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="tokens" select="tokenize(@ref, ' ')"/>
        <xsl:variable name="rendition" select="substring-after(@rendition, '#')"/>
        <xsl:choose>
            <xsl:when test="count($tokens) > 1 and not(@prev)">
                <xsl:variable name="role" select="id(data(substring-after($tokens[1], '#')))/@role"/>
                <xsl:choose>
                    <xsl:when test="@type='person'">
                        <xsl:for-each select="$tokens">
                            <xsl:choose>
                                <xsl:when test="$role = 'fictional'">
                                    <span class="figures entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{.}">
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="persons entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{.}">
                                    </span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="@type='place'">
                        <xsl:for-each select="$tokens">
                            <span class="places entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{.}">
                            </span>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="@type='bibl'">
                        <xsl:for-each select="$tokens">
                            <span class="works entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{.}">
                            </span>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="count($tokens) = 1 and not(@prev)">
                <xsl:choose>
                    <xsl:when test="@type='person'">
                        <xsl:variable name="role" select="id(data(substring-after(@ref, '#')))/@role"/>
                        <xsl:choose>
                            <xsl:when test="$role = 'fictional'">
                                <span class="figures entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="persons entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="@type='place'">
                        <span class="places entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='bibl'">
                        <span class="works entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                        </span>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@prev">
                <xsl:apply-templates/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:pb[following-sibling::tei:p[1]/@prev = 'true']">
        <!--  do not display independently -->
    </xsl:template>
    <xsl:template match="tei:pb[not(following-sibling::tei:p[1]/@prev = 'true')]">
        <xsl:variable name="graphic-url" select="substring-before(id(data(substring-after(@facs, '#')))/tei:graphic/@url, '.jpg')"/>
        <span class="anchor-pb" source="hsl-nfp/{$graphic-url}"></span>
        <span class="pb">[<xsl:value-of select="@n"/>]</span>
    </xsl:template>
    <xsl:template match="tei:cit">
        <span class="cit"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:quote">
        <span class="quote"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:list[@type='unordered']">
        <xsl:choose>
            <xsl:when test="parent::tei:p|ancestor::tei:body">
                <ul>
                    <xsl:apply-templates/>
                </ul>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:item">
        <xsl:choose>
            <xsl:when test="parent::tei:list[@type='unordered']|ancestor::tei:body">
                <li><xsl:apply-templates/></li>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:date">
        <span class="date"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:ref">
        <span class="ref {@type}"><a href="{@target}"><xsl:apply-templates/></a></span>
    </xsl:template>
    <xsl:template match="tei:note" name="footnote">
        <xsl:param name="node-xpath"></xsl:param>
        <xsl:param name="inline" select="'true'"/>
        <xsl:variable name="id" select="generate-id()"/>
        <xsl:choose>
            <xsl:when test="$inline = 'true'">
                <xsl:choose>
                    <xsl:when test="@type='footnote'">
                        <span>
                            <a class="anchorFoot" id="{$id}_inline"></a>
                            <a href="#{$id}" title="{concat('footnote: ', @n)}"
                               class="nounderline">
                               <sup><xsl:value-of select="@n"/></sup>
                            </a>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <a class="anchorFoot" id="{$id}"></a>
                <span class="footnote_link">
                    <a href="#{$id}_inline" class="nounderline">
                        <xsl:value-of select="@n"/>
                    </a>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:lg">
        <span class="vrsgrp"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:l">
        <span class="vrs"><xsl:apply-templates/><span class="vrsSep"> / </span></span>
    </xsl:template>

</xsl:stylesheet>