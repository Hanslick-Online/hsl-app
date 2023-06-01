<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:import href="partials/aot-options.xsl"/>
    <xsl:import href="partials/chapters.xsl"/>
    <xsl:import href="partials/book-edition.xsl"/>
    <xsl:import href="partials/view-type.xsl"/>
    <xsl:import href="partials/view-type-content.xsl"/>
    <xsl:import href="partials/entities-modal.xsl"/>
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
                <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.0.0/openseadragon.min.js"></script>
            </head>
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">
                        <xsl:call-template name="view-type">
                            <xsl:with-param name="anotation-options" select="'true'"/>
                            <xsl:with-param name="book-chapters" select="'true'"/>
                            <xsl:with-param name="book-editions" select="'true'"/>
                            <xsl:with-param name="editor-widget" select="'true'"/>
                            <xsl:with-param name="body-xpath" as="item()*" select="//tei:body//tei:div"/>
                            <xsl:with-param name="edition-project-class">
                                <xsl:text>section-traktat</xsl:text>
                            </xsl:with-param>
                            <xsl:with-param name="front-page" select="'true'"/>
                            <xsl:with-param name="footnotes" select="'true'"/>
                            <xsl:with-param name="footnotes-xpath"
                                    as="item()*"
                                    select="//tei:body//tei:note[@place='foot']"/>
                            <xsl:with-param name="back-page" select="'true'"/>
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
        <br/>
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
        <xsl:choose>
            <xsl:when test="count(tokenize(@ref, ' ')) > 1">
                <xsl:choose>
                    <xsl:when test="@type='person'">
                        <span class="persons {substring-after(@rendition, '#')}" id="{@xml:id}">
                            <xsl:apply-templates/>
                            <xsl:for-each select="tokenize(@ref, ' ')">
                                <sup class="entity" data-bs-toggle="modal" data-bs-target="{.}">
                                    <xsl:value-of select="position()"/>
                                </sup>
                                <xsl:if test="position() != last()">
                                    <sup class="entity">/</sup>
                                </xsl:if>
                            </xsl:for-each>
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='place'">
                        <span class="places {substring-after(@rendition, '#')}" id="{@xml:id}">
                            <xsl:apply-templates/>
                            <xsl:for-each select="tokenize(@ref, ' ')">
                                <sup class="entity" data-bs-toggle="modal" data-bs-target="{.}">
                                    <xsl:value-of select="position()"/>
                                </sup>
                                <xsl:if test="position() != last()">
                                    <sup class="entity">/</sup>
                                </xsl:if>
                            </xsl:for-each>
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='bibl'">
                        <span class="works {substring-after(@rendition, '#')}" id="{@xml:id}">
                            <xsl:apply-templates/>
                            <xsl:for-each select="tokenize(@ref, ' ')">
                                <sup class="entity" data-bs-toggle="modal" data-bs-target="{.}">
                                    <xsl:value-of select="position()"/>
                                </sup>
                                <xsl:if test="position() != last()">
                                    <sup class="entity">/</sup>
                                </xsl:if>
                            </xsl:for-each>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@type='person'">
                        <span class="persons entity {substring-after(@rendition, '#')}" id="{@xml:id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='place'">
                        <span class="places entity {substring-after(@rendition, '#')}" id="{@xml:id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:when test="@type='bibl'">
                        <span class="works entity {substring-after(@rendition, '#')}" id="{@xml:id}" data-bs-toggle="modal" data-bs-target="{@ref}">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:pb">
        <xsl:choose>
            <xsl:when test="ancestor::tei:p and not(preceding-sibling::tei:list)">
                <span class="anchor-pb" source="hsl-vms/{tokenize(@facs, '/')[last()]}"></span>
                <span class="pb"><br/><br/><xsl:value-of select="@n"/></span>
            </xsl:when>
            <xsl:when test="ancestor::tei:p and preceding-sibling::tei:list">
                <span class="anchor-pb" source="hsl-vms/{tokenize(@facs, '/')[last()]}"></span>
                <p class="indentedP"><span class="pb"><br/><br/><xsl:value-of select="@n"/></span></p>
            </xsl:when>
            <xsl:when test="ancestor::tei:list">
                <span class="anchor-pb" source="hsl-vms/{tokenize(@facs, '/')[last()]}"></span>
                <span class="pb"><br/><br/><xsl:value-of select="@n"/></span>
            </xsl:when>
            <xsl:when test="ancestor::tei:note">
                <span class="anchor-pb" source="hsl-vms/{tokenize(@facs, '/')[last()]}"></span>
                <span class="pb"><br/><br/><xsl:value-of select="@n"/></span>
            </xsl:when>
            <xsl:when test="ancestor::tei:front">
                <span class="anchor-pb" source="hsl-vms/{tokenize(@facs, '/')[last()]}"></span>
                <span class="pb"><br/><br/><xsl:value-of select="@n"/></span>
            </xsl:when>
            <xsl:otherwise>
                <p class="indentedP">
                    <span class="anchor-pb" source="hsl-vms/{tokenize(@facs, '/')[last()]}"></span>
                    <span class="pb"><br/><br/><xsl:value-of select="@n"/></span>
                </p>
            </xsl:otherwise>
        </xsl:choose>
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