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
            <!-- Corrected line -->
            <xsl:value-of select="/descendant::tei:titleStmt//tei:title[@type='main'][1]/text()"/>
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
                            <xsl:with-param name="toc-address" select="'toc_vms.html'" />
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
    <xsl:template match="text()[ancestor::tei:body]" priority="1">
        <xsl:choose>
        <xsl:when test="following-sibling::tei:*[1][@break='no']">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:when>
          <xsl:when test="following-sibling::tei:cb[1] and
                       following-sibling::tei:cb[1]/following-sibling::*[1][self::tei:lb][@break='no']">
            <xsl:value-of select="."/>
        </xsl:when>
            <xsl:when test="matches(., '-$')">|
                HYPHEN-MATCH<xsl:value-of select="."/>|
            </xsl:when>

            <xsl:when test="following-sibling::tei:*[1][self::tei:note]">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:apply-templates select="following-sibling::tei:*[1]" mode="inline"/>
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
    
    <xsl:template match="tei:p">
        <p id="{@xml:id}" class="indentedP yes-index">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:cb" />
    <!--    <xsl:choose>
            <xsl:when test="following-sibling::*[@break]">
                <xsl:text disable-output-escaping="yes" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template> -->

    <xsl:template match="tei:lb">
        <xsl:if test="parent::tei:rs">
            <span class="pb wrdbreak">-</span><br class="pb"/>
        </xsl:if>
        <xsl:if test="not(parent::tei:rs)">
            <xsl:if test="@break='no'">
                <span class="pb wrdbreak">-</span>
            </xsl:if>
            <br class="pb"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:space">
        <span class="space">
            <xsl:value-of select="string-join((for $i in 1 to @quantity return '&#x00A0;'),'')"/>
        </span>
    </xsl:template>
    <xsl:template match="tei:emph"><em><xsl:apply-templates/></em></xsl:template>
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
  <xsl:template match="tei:rs">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="tokens" select="tokenize(@ref, ' ')"/>
        <xsl:variable name="rendition" select="substring-after(@rendition, '#')"/>
        <xsl:choose>
            <xsl:when test="@prev">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="target" select="@ref"/>
                <xsl:variable name="entityClass">
                    <xsl:choose>
                        <xsl:when test="@type='person'">persons</xsl:when>
                        <xsl:when test="@type='place'">places</xsl:when>
                        <xsl:when test="@type='bibl'">works</xsl:when>
                        <xsl:otherwise>entity</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="modalTarget" select="concat('#', substring-after($target, '#'))"/>

                <span class="{$entityClass} entity {$rendition}" id="{$id}" data-bs-toggle="modal" data-bs-target="{$modalTarget}">
                </span><xsl:apply-templates/>
                
                <xsl:if test="following-sibling::node()[1][self::text()][normalize-space(.) = '']">
                    <xsl:text> </xsl:text>
                </xsl:if>
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
                <span id="{$id}" class="footnote">
                <a class="anchorFoot" id="{$id}"></a>
                    <span class="footnote_link">
                        <a href="#{$id}_inline" class="nounderline">
                            <xsl:choose>
                                <xsl:when test="starts-with(@n, '*')">*</xsl:when>
                                <xsl:otherwise><xsl:value-of select="@n"/></xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </span>
                    <span class="footnote_text">
                        <xsl:apply-templates/>
                    </span>
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
