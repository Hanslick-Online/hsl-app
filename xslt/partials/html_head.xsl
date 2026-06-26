<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl xs"
    version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template match="/" name="html_head">
        <xsl:param name="html_title"></xsl:param>
        <meta charset="utf-8"/>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-title" content="{$project_short_title}" />
        <link rel="profile" href="http://gmpg.org/xfn/11"></link>
        <link rel="shortcut icon" href="images/favicon.png" sizes="96x70"/>
        <link rel="icon" type="image/png" href="images/favicon.png" sizes="32x23"/>
        <link rel="icon" type="image/png" href="images/favicon.png" sizes="96x70"/>
        <link rel="apple-touch-icon" sizes="180x180" href="images/favicon.png"/>
        <meta name="msapplication-TileColor" content="#ffffff"/>
        <meta name="msapplication-TileImage" content="images/Auden_Musulin_Papers_Logo_rechteckig_favicon_144.png"/>
        <title><xsl:value-of select="$project_short_title"/></title>
        <link rel="stylesheet" href="vendor/fontawesome-free-7.3.0-web/css/all.min.css" />
        <link href="vendor/bootstrap-5.3.5-dist/css/bootstrap.min.css" rel="stylesheet" />
        <link rel="stylesheet" href="css/style.css" type="text/css" />
        <!--<script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script> -->
        <script src="vendor/popper-2.10.2/popper.min.js" />
        <script src="vendor/bootstrap-5.3.5-dist/js/bootstrap.min.js" />
        <script src="vendor/jquery/jquery-3.7.1.min.js" />
    </xsl:template>
</xsl:stylesheet>
