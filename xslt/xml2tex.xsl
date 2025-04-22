<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xml="http://www.w3.org/XML/1998/namespace">
    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:text>\documentclass[a4paper]{book}&#10;</xsl:text>
        <xsl:text>\usepackage{polyglossia}&#10;</xsl:text>
        <xsl:text>\setmainlanguage[variant=austrian]{german}&#10;</xsl:text>
        <xsl:text>\usepackage{tracklang}&#10;</xsl:text>
        <xsl:text>\usepackage{fontspec,xltxtra,xunicode}&#10;</xsl:text>
        <xsl:text>\usepackage{microtype}&#10;</xsl:text>
        <xsl:text>\usepackage{geometry}&#10;</xsl:text>
        <xsl:text>\usepackage[pagestyles]{titlesec}&#10;</xsl:text>
        <xsl:text>\titleformat{\chapter}[display]{\normalfont\bfseries}{}{0pt}{\Large}&#10;</xsl:text>
        <xsl:text>\usepackage[useregional]{datetime2}&#10;</xsl:text>
        <xsl:text>\geometry{left=35mm, right=35mm, top=35mm, bottom=35mm}&#10;</xsl:text>
        <xsl:text>\setmainfont{Noto Serif}&#10;</xsl:text>
        <xsl:text>\newpagestyle{mystyle}{\sethead[\thepage][][\chaptertitle]{}{}{\thepage}}\pagestyle{mystyle}&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        
        <!-- Author and Date declarations -->
        <xsl:variable name="authors">
            <xsl:for-each select="//tei:titleStmt/tei:author">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:text>\author{</xsl:text>
        <xsl:value-of select="$authors"/>
        <xsl:text>}&#10;</xsl:text>

        <xsl:variable name="date" select="substring-before(//tei:monogr/tei:imprint/tei:date/@when, '-')"/>
        <xsl:text>\date{</xsl:text>
        <xsl:value-of select="$date"/>
        <xsl:text>}&#10;</xsl:text>

        <xsl:text>\begin{document}&#10;</xsl:text>
        
        <!-- Front Matter -->
        <xsl:text>\frontmatter&#10;</xsl:text>
        
        <!-- Title Page -->
        <xsl:text>\begin{titlepage}&#10;</xsl:text>
        <xsl:text>\centering&#10;</xsl:text>
        <xsl:text>\vspace*{\fill}&#10;&#10;</xsl:text>
        
        <!-- Main Title - using standard LaTeX size command -->
        <xsl:text>{\Huge </xsl:text>
        <xsl:for-each select="//tei:titlePage/tei:docTitle/tei:titlePart[@type='main']/text()">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() != last()">
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>}\\[2em]&#10;</xsl:text>
        
        <!-- Subtitle - using standard LaTeX size command -->
        <xsl:text>{\Large </xsl:text>
        <xsl:for-each select="//tei:titlePage/tei:docTitle/tei:titlePart[@type='sub']/text()">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() != last()">
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>}\\[3em]&#10;</xsl:text>
        
        <!-- Author Byline -->
        <xsl:text>{\large </xsl:text>
        <xsl:value-of select="normalize-space(//tei:titlePage/tei:byline[@resp='author'])"/>
        <xsl:text>}\\[3em]&#10;</xsl:text>
        
        <!-- Edition -->
        <xsl:text>{\normalsize </xsl:text>
        <xsl:value-of select="normalize-space(//tei:titlePage/tei:docEdition)"/>
        <xsl:text>}\\[3em]&#10;</xsl:text>
        
        <!-- Publication Info -->
        <xsl:text>{\normalsize </xsl:text>
        <xsl:value-of select="normalize-space(//tei:titlePage/tei:docImprint/tei:pubPlace)"/>
        <xsl:text>\\[1em]&#10;</xsl:text>
        <xsl:value-of select="normalize-space(//tei:titlePage/tei:docImprint/tei:publisher)"/>
        <xsl:text>\\[1em]&#10;</xsl:text>
        <xsl:value-of select="normalize-space(//tei:titlePage/tei:docImprint/tei:date)"/>
        <xsl:text>}&#10;&#10;</xsl:text>
        
        <xsl:text>\vspace*{\fill}&#10;</xsl:text>
        
        <!-- Dedication/Salute -->
        <xsl:if test="//tei:titlePage/tei:salute">
            <xsl:text>{\large </xsl:text>
            <xsl:value-of select="normalize-space(//tei:titlePage/tei:salute)"/>
            <xsl:text>}&#10;</xsl:text>
            <xsl:text>\vspace*{\fill}&#10;</xsl:text>
        </xsl:if>
        
        <xsl:text>\end{titlepage}&#10;&#10;</xsl:text>

        <!-- Front Matter Content -->
        <xsl:if test="//tei:front/tei:div[@type='foreword']">
            <xsl:text>\chapter*{</xsl:text>
            <xsl:value-of select="//tei:front/tei:div[@type='foreword']/tei:head"/>
            <xsl:text>}&#10;</xsl:text>
            <xsl:apply-templates select="//tei:front/tei:div[@type='foreword']/tei:p"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:if>

        <!-- Main Matter -->
        <xsl:text>\mainmatter&#10;</xsl:text>
        <!-- Body -->
        <xsl:apply-templates select="//tei:text//tei:body//tei:div"/>

        <!-- Back Matter -->
        <xsl:text>\backmatter&#10;</xsl:text>
        <xsl:apply-templates select="//tei:text//tei:back//tei:div"/>

        <xsl:text>&#10;\end{document}&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="tei:div">
        <xsl:text>&#10;\chapter{</xsl:text>
        <xsl:value-of select="tei:head"/>
        <xsl:text>}&#10;</xsl:text>
        <xsl:apply-templates select="tei:p"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="tei:p">
        <xsl:text>&#10;&#10;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:hi[@rendition='#em']">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="tei:lb">
        <xsl:text>\newline{}</xsl:text>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

</xsl:stylesheet>
