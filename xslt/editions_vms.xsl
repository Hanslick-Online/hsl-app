<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
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
                <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.0.0/openseadragon.min.js"></script>
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
                                <xsl:text>section-vms</xsl:text>
                            </xsl:with-param>
                            <xsl:with-param name="front-page" select="'false'"/>
                            <xsl:with-param name="back-page" select="'true'"/>
                            <xsl:with-param name="next-prev-page" select="'true'"/>
                            <xsl:with-param name="document-download" select="'true'"/>
                            <xsl:with-param name="document-download-edition" select="'vms'"/>
                        </xsl:call-template>
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
                <script type="text/javascript" src="js/run_editions.js"></script>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/mark.js/8.11.1/mark.min.js"></script>
                <script type="text/javascript" src="js/mark.js"></script>
                <script type="text/javascript" src="js/osd.js"></script>
            </body>
        </html>
    </xsl:template>
    
    <!--    
        TEI FRONT
    -->
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
    
    <xsl:template match="tei:docTitle">
        <div class="docTitle">
            <a class="anchor" id="index.xml-body.1_div.0"></a>
            <!--<span class="anchor-pb" source="{tokenize(//tei:front//tei:pb/@facs, '/')[last()]}"><br/><br/></span>-->
            <!--<span class="pb"></span>-->
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:titlePart">
        <div class="titlePart {@type}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:docAuthor">
        <span class="docAuthor">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:docEdition">
        <div class="docEdition">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:docImprint">
        <div class="docImprint">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:milestone">
        <div class="milestone">
            <xsl:text>***</xsl:text>
        </div>
    </xsl:template>
    
    <!--    
        TEI BODY
    -->
    <xsl:template match="tei:byline">
        <xsl:if test="ancestor::tei:body">
            <p class="yes-index"><xsl:apply-templates/></p>
        </xsl:if>
        <xsl:if test="ancestor::tei:front">
            <div class="byline">
                <xsl:apply-templates/>
            </div>
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

    <xsl:template match="tei:head">
        <h3 class="yes-index">
            <!--<xsl:choose>
                <xsl:when test="contains(. ,'a)')">
                    <xsl:variable name="chapter" select="tokenize(., 'I')"/>
                    I. <xsl:value-of select="$chapter[2]"/>
                    <br/>
                    I. <xsl:value-of select="$chapter[3]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>-->
            <xsl:apply-templates/>
        </h3>
    </xsl:template>   
    
    <xsl:template match="tei:p">
        <p id="{@xml:id}" class="indentedP yes-index">
            <a>
                <xsl:choose>
                    <xsl:when test="@n">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('diff_', @n, '.html')"/>
                        </xsl:attribute>
                        <xsl:attribute name="class">
                            <xsl:text>parNum nounderline</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">
                            <xsl:text>noParNum nounderline</xsl:text>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="replace(@n, 'xyz', '')"/>
            </a>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:lb">
        <xsl:if test="@break">
            <span class="pb wrdbreak">-</span>
        </xsl:if>
        <br class="pb" />
    </xsl:template>
    <xsl:template match="tei:space">
        <span class="space">
            <xsl:value-of select="string-join((for $i in 1 to @quantity return '&#x00A0;'),'')"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:emph">
        <!--<xsl:choose>
            <xsl:when test="starts-with(following-sibling::text()[1], ',') or 
                starts-with(following-sibling::text()[1], '’') or
                starts-with(following-sibling::text()[1], '.')">
                <em class="comma"><xsl:apply-templates/></em>
            </xsl:when>
            <xsl:when test="matches(preceding-sibling::text()[1], '\w+')">
                <em class="prev-text"><xsl:apply-templates/></em>
            </xsl:when>
            <xsl:otherwise>
                <em><xsl:apply-templates/></em>
            </xsl:otherwise>
        </xsl:choose>-->
        <em><xsl:apply-templates/></em>
    </xsl:template>
    <xsl:template match="tei:rs">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="tokens" select="tokenize(@ref, ' ')"/>
        <xsl:variable name="rendition" select="substring-after(@rendition, '#')"/>
        <xsl:choose>
            <xsl:when test="count($tokens) > 1">
                <xsl:variable name="role" select="id(data(substring-after($tokens[1], '#')))/@role"/>
                <xsl:apply-templates/>
                <xsl:choose>
                    <xsl:when test="@type='person'">
                        <xsl:for-each select="$tokens">
                            <xsl:choose>
                                <xsl:when test="$role = 'fictional'">
                                    <sup class="figures entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{.}">
                                    </sup>
                                </xsl:when>
                                <xsl:otherwise>
                                    <sup class="persons entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{.}">
                                    </sup>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="@type='place'">
                        <xsl:for-each select="$tokens">
                            <sup class="places entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{.}">
                            </sup>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="@type='bibl'">
                        <xsl:for-each select="$tokens">
                            <sup class="works entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{.}">
                                <xsl:value-of select="position()"/>
                            </sup>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
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
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:pb">
        <xsl:variable name="facs" select="substring-after(data(@facs), '#')"/>
        <xsl:variable name="facs_url" select="replace(ancestor::tei:TEI//tei:surface[@xml:id=$facs]/tei:graphic/@url, '.jpeg', '')"/>
        <span class="anchor-pb" source="hsl-vms/{$facs_url}"></span>
        <span class="pb"><br/><br/><xsl:value-of select="@n"/></span>
    </xsl:template>
    <xsl:template match="tei:cit">
        <cite><xsl:apply-templates/></cite>
    </xsl:template>
    <xsl:template match="tei:quote">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:list[@type='unordered']">
        <xsl:choose>
            <xsl:when test="parent::tei:p|ancestor::tei:body">
                <ul class="yes-index">
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
        <xsl:choose>
            <xsl:when test="@type='edition'">
                <a class="ref {@type}" href="t__{@target}"><xsl:apply-templates/></a>
            </xsl:when>
            <xsl:otherwise>
                <a class="ref {@type}" href="{@target}"><xsl:apply-templates/></a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:note" name="footnote">
        <xsl:param name="inline" select="'true'"/>
        <xsl:variable name="id" select="generate-id()"/>
        <xsl:choose>
            <xsl:when test="$inline = 'true'">
                <xsl:choose>
                    <xsl:when test="@place='foot'">
                        <span>
                            <a class="anchorFoot" id="{$id}_inline"></a>
                            <a href="#{$id}" title="{.//text()}" class="nounderline">
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
    <xsl:template match="tei:notatedMusic">
        <xsl:choose>
            <xsl:when test="parent::tei:p">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <figure class="figure padding-20">
                    <xsl:apply-templates/>
                </figure>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:graphic">
        <xsl:choose>
            <xsl:when test="ancestor::tei:p">
                <img class="figure padding-20 w-100" src="{@url}" alt="Grafik eines Notenbeispiels"/>
            </xsl:when>
            <xsl:otherwise>
                <img class="w-100" src="{@url}" alt="Grafik eines Notenbeispiels"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:lg">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:l">
        <xsl:apply-templates/><xsl:text> / </xsl:text>
    </xsl:template>
</xsl:stylesheet>
