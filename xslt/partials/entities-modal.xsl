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
                                    <xsl:if test="./tei:listBibl[@type = 'characterOf']/tei:bibl/text()">
                                        <tr>
                                            <th>Werk</th>
                                            <td><xsl:value-of select="./tei:listBibl/tei:bibl/text()"/></td>
                                        </tr>
                                    </xsl:if>
                                    <tr>
                                        <th> GND </th>
                                        <td>
                                            <a href="{./tei:idno[@type='GND']}" target="_blank">
                                              <xsl:value-of select="./tei:idno[@type = 'GND']"/>
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th> Weiterlesen </th>
                                        <td>
                                            <a href="{concat(@xml:id, '.html')}"> Details </a>
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
                                    <tr>
                                        <th> Land </th>
                                        <td>
                                            <xsl:value-of select="./tei:country"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th> Geonames ID </th>
                                        <td>
                                            <a href="{./tei:idno[@type='GEONAMES']}"
                                              target="_blank">
                                              <xsl:value-of
                                              select="tokenize(./tei:idno[@type = 'GEONAMES'], '/')[4]"
                                              />
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th> Weiterlesen </th>
                                        <td>
                                            <a href="{concat(@xml:id, '.html')}"> Details </a>
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

                                    <tr>
                                        <th> Autor(en) </th>
                                        <td>
                                            <ul>
                                              <xsl:for-each select="./tei:author">
                                              <li>
                                              <a href="{@xml:id}.html">
                                              <xsl:value-of select="./tei:persName"/>
                                              </a>
                                              </li>
                                              </xsl:for-each>
                                            </ul>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th> Alternativtitel </th>
                                        <td>
                                            <xsl:value-of
                                              select="./tei:title[@type = 'alternative']"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th> Wikidata ID </th>
                                        <td>
                                            <a href="{./tei:idno[@type='WIKIDATA']}"
                                              target="_blank">
                                              <xsl:value-of
                                              select="tokenize(./tei:idno[@type = 'WIKIDATA'], '/')[last()]"
                                              />
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th> Weiterlesen </th>
                                        <td>
                                            <a href="{concat(@xml:id, '.html')}"> Details </a>
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