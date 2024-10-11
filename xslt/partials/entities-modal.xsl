<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xsl tei" version="2.0">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>

    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>
            <h1>Widget entities modal.</h1>
            <p>Contact person: daniel.stoxreiter@oeaw.ac.at</p>
            <p>Applied with call-templates in html:body.</p>
            <p>Custom template to create modal templates for each entity.</p>
        </desc>
    </doc>

    <xsl:template name="entities-modal">
        <xsl:for-each select=".//tei:listPerson/tei:person">
            <xsl:variable name="norm-name">
                <xsl:value-of select="
                        if (./tei:persName[@type = 'main']/tei:forename/text() and ./tei:persName[@type = 'main']/tei:surname/text())
                        then
                        (concat(./tei:persName[@type = 'main']/tei:surname, ', ', ./tei:persName[@type = 'main']/tei:forename))
                        else
                            (./tei:persName[@type = 'main'])
                        "/>
            </xsl:variable>
            <div class="modal fade" id="{@xml:id}" data-bs-toggle="modal" tabindex="-1"
                aria-labelledby="{$norm-name}" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="staticBackdropLabel">
                                <xsl:value-of select="$norm-name"/>
                            </h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"
                                aria-label="Close"/>
                        </div>
                        <div class="modal-body">
                            <table>
                                <tbody>
                                    <xsl:if test="./tei:persName[@type='alternative']/tei:surname/text() or 
                                                    ./tei:persName[@type = 'alternative']/tei:surname/text()">
                                        <tr>
                                            <th> Name (alt) </th>
                                            <td>
                                                <xsl:if
                                                  test="./tei:persName[@type = 'alternative']/tei:surname/text()">
                                                  <xsl:value-of
                                                  select="./tei:persName[@type = 'alternative']/tei:surname"
                                                  />
                                                </xsl:if>
    
                                                <xsl:if test="
                                                        ./tei:persName[@type = 'alternative']/tei:surname/text() and
                                                        ./tei:persName[@type = 'alternative']/tei:forename/text()">
                                                  <xsl:text>, </xsl:text>
                                                </xsl:if>
                                                <xsl:if
                                                  test="./tei:persName[@type = 'alternative']/tei:forename/text()">
                                                  <xsl:value-of
                                                  select="./tei:persName[@type = 'alternative']/tei:forename"
                                                  />
                                                </xsl:if>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:birth/text()">
                                        <tr>
                                            <th>Lebensdaten</th>
                                            <td><xsl:value-of select="./tei:birth/text()"/></td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:occupation/text()">
                                        <tr>
                                            <th>Beschreibung</th>
                                            <td>
                                                <ul>
                                                    <xsl:for-each select="./tei:occupation">
                                                        <xsl:if test="position() lt 4">
                                                            <li><xsl:value-of select="./text()"/></li>
                                                        </xsl:if>
                                                    </xsl:for-each>
                                                </ul>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:listBibl[@type = 'characterOf']">
                                        <tr>
                                            <th>Werk</th>
                                            <td>
                                                <ul>
                                                    <xsl:for-each select="./tei:listBibl/tei:bibl">
                                                     <li><xsl:value-of select="./text()"/></li>
                                                    </xsl:for-each>
                                                </ul>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:idno[@subtype='GND']/text()">
                                        <tr>
                                            <th> GND </th>
                                            <td>
                                                <a href="{./tei:idno[@subtype='GND']}" target="_blank">
                                                    <xsl:value-of select="tokenize(./tei:idno[@subtype = 'GND'], '/')[last()]"/>
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:idno[@subtype='WIKIDATA']/text()">
                                        <tr>
                                            <th> WIKIDATA </th>
                                            <td>
                                                <a href="{./tei:idno[@subtype='WIKIDATA']}" target="_blank">
                                                    <xsl:value-of select="tokenize(./tei:idno[@subtype='WIKIDATA'], '/')[last()]"/>
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:idno[@subtype='PMB']/text()">
                                        <tr>
                                            <th> PMB </th>
                                            <td>
                                                <a href="{./tei:idno[@subtype='PMB']}" target="_blank">
                                                    <xsl:value-of select="tokenize(./tei:idno[@subtype='PMB'], '/')[last()]"/>
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:idno[@subtype='OEBL']/text()">
                                        <tr>
                                            <th> OEBL </th>
                                            <td>
                                                <a href="{./tei:idno[@subtype='OEBL']}" target="_blank">
                                                    <xsl:value-of select="concat(
                                                        tokenize(./tei:idno[@subtype='OEBL'], '/')[last() - 1],
                                                        '/',
                                                        replace(tokenize(./tei:idno[@subtype='OEBL'], '/')[last()], '.xml', '')
                                                        )"/>
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:idno[@subtype='OEML']/text()">
                                        <tr>
                                            <th> OEML </th>
                                            <td>
                                                <a href="{./tei:idno[@subtype='OEML']}" target="_blank">
                                                    <xsl:value-of select="concat(
                                                        tokenize(./tei:idno[@subtype='OEML'], '/')[last() - 1],
                                                        '/',
                                                        replace(tokenize(./tei:idno[@subtype='OEML'], '/')[last()], '.xml', '')
                                                        )"/>
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="@cert">
                                        <tr>
                                            <th>
                                                Überprüft
                                            </th>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="@cert='high'">
                                                        mehrfach
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        einmalig
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <tr>
                                        <th></th>
                                        <td style="padding-top: 1em;">
                                            <a href="{concat(@xml:id, '.html')}"> Weitere Details </a>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary"
                                data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
            </xsl:for-each>
        <xsl:for-each select=".//tei:listPlace/tei:place">
            <div class="modal fade" id="{@xml:id}" data-bs-toggle="modal" tabindex="-1"
                aria-labelledby="{if(./tei:settlement) then(./tei:settlement/tei:placeName[@type='main']) else (./tei:placeName[@type='main'])}"
                aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="staticBackdropLabel">
                                <xsl:value-of select="
                                        if (./tei:settlement) then
                                            (./tei:settlement/tei:placeName[@type = 'main'])
                                        else
                                            (./tei:placeName[@type = 'main'])"
                                />
                            </h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"
                                aria-label="Close"/>
                        </div>
                        <div class="modal-body">
                            <table>
                                <tbody>
                                    <xsl:if test=".//tei:placeName[@type='alternative']/text()">
                                        <tr>
                                            <th> Alternativname </th>
                                            <td>
                                                <xsl:value-of select="
                                                    if (./tei:settlement) then
                                                    (./tei:settlement/tei:placeName[@type = 'alternative'])
                                                    else
                                                    (./tei:placeName[@type = 'alternative'])"
                                                />
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:country/text()">
                                        <tr>
                                            <th> Land </th>
                                            <td>
                                                <xsl:value-of select="./tei:country"/>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:idno[@subtype='GEONAMES']/text()">
                                        <tr>
                                            <th> Geonames ID </th>
                                            <td>
                                                <a href="{./tei:idno[@subtype='GEONAMES']}"
                                                  target="_blank">
                                                  <xsl:value-of
                                                      select="tokenize(./tei:idno[@subtype = 'GEONAMES'], '/')[4]"
                                                  />
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="@cert">
                                        <tr>
                                            <th>
                                                Überprüft
                                            </th>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="@cert='high'">
                                                        mehrfach
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        einmalig
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <tr>
                                        <th></th>
                                        <td style="padding-top: 1em;">
                                            <a href="{concat(@xml:id, '.html')}"> Weitere Details </a>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary"
                                data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
            </xsl:for-each>
        <xsl:for-each select=".//tei:listBibl/tei:bibl">
            <div class="modal fade" id="{@xml:id}" data-bs-toggle="modal" tabindex="-1"
                aria-labelledby="{./tei:title[@type='main']}" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="staticBackdropLabel">
                                <xsl:value-of select="./tei:title[@type = 'main']"/>
                            </h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"
                                aria-label="Close"/>
                        </div>
                        <div class="modal-body">
                            <table>
                                <tbody>
                                    <xsl:if test="./tei:author">
                                        <tr>
                                            <th> Autor(en) </th>
                                            <td>
                                                <ul>
                                                    <xsl:for-each select="./tei:author">
                                                        <xsl:sort select="./tei:persName" order="ascending"/>
                                                        <li>
                                                            <a href="{@xml:id}.html">
                                                                <xsl:value-of select="./tei:persName"/>
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:title[@type = 'alternative']/text()">
                                        <tr>
                                            <th> Alternativtitel </th>
                                            <td>
                                                <xsl:value-of
                                                    select="./tei:title[@type = 'alternative']"/>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:idno[@subtype='GND']/text()">
                                        <tr>
                                            <th> GND ID </th>
                                            <td>
                                                <a href="{./tei:idno[@subtype='GND']}"
                                                  target="_blank">
                                                  <xsl:value-of
                                                      select="tokenize(./tei:idno[@subtype = 'GND'], '/')[last()]"
                                                  />
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:noteGrp[@type='Werkbezug']">
                                        <tr>
                                            <th> Werkbezug </th>
                                            <td>
                                                <ul>
                                                    <xsl:for-each select="./tei:noteGrp[@type='Werkbezug']/tei:note">
                                                        <li>
                                                            <a href="{@target}">
                                                                <xsl:value-of
                                                                    select="./text()"
                                                                />
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="./tei:idno[@subtype='Digitalisat']/text()">
                                        <tr>
                                            <th> Digitalisat </th>
                                            <td>vorhanden
                                                <!--<ul>
                                                    <xsl:for-each select="./tei:idno[@subtype = 'Digitalisat']">
                                                        <li>
                                                            <a href="{./text()}"
                                                                target="_blank">
                                                                <xsl:value-of
                                                                    select="./text()"
                                                                />
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>-->
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="@cert">
                                        <tr>
                                            <th>
                                                Überprüft
                                            </th>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="@cert='high'">
                                                        mehrfach
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        einmalig
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <tr>
                                        <th></th>
                                        <td style="padding-top: 1em;">
                                            <a href="{concat(@xml:id, '.html')}"> Weitere Details </a>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary"
                                data-bs-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
            </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
