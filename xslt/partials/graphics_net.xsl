<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:graphics"
    version="2.0"
    exclude-result-prefixes="tei xsl xs local">

    <xsl:variable name="hanslick-id" as="xs:string" select="'hsl_person_id_1'"/>
    <xsl:variable name="net-person-index" as="document-node()" select="doc(resolve-uri('../../data/indices/listperson.xml', static-base-uri()))"/>
    <xsl:variable name="net-doc-targets" as="xs:string*" select="distinct-values($net-person-index//tei:listPerson/tei:person/tei:noteGrp/tei:note[starts-with(string(@target), 'd__')]/string(@target))"/>
    <xsl:variable name="net-doc-editions" as="document-node()*">
        <xsl:for-each select="$net-doc-targets">
            <xsl:variable name="doc-uri" as="xs:anyURI" select="resolve-uri(concat('../../data/doc/editions/', .), static-base-uri())"/>
            <xsl:if test="doc-available($doc-uri)">
                <xsl:sequence select="doc($doc-uri)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <xsl:function name="local:normalize-target" as="xs:string">
        <xsl:param name="target" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($target, 't__')">t__VMS_TREATISE</xsl:when>
            <xsl:otherwise><xsl:sequence select="$target"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="local:pub-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:sequence select="distinct-values(for $target in $person/tei:noteGrp/tei:note[@type='mentions'][starts-with(string(@target), 'c__') or starts-with(string(@target), 't__')]/string(@target) return local:normalize-target($target))"/>
    </xsl:function>

    <xsl:function name="local:doc-mention-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:sequence select="distinct-values($person/tei:noteGrp/tei:note[@type='mentions'][starts-with(string(@target), 'd__')]/string(@target))"/>
    </xsl:function>

    <xsl:function name="local:doc-authored-targets" as="xs:string*">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:variable name="person-ref" as="xs:string" select="concat('#', string($person/@xml:id))"/>
        <xsl:sequence select="distinct-values(for $doc in $net-doc-editions[.//tei:teiHeader//tei:author[@ref = $person-ref]] return string((($doc/tei:TEI/@xml:id)[1], tokenize(base-uri($doc), '/')[last()])[1]))"/>
    </xsl:function>

    <xsl:function name="local:node-group" as="xs:string">
        <xsl:param name="person" as="element(tei:person)"/>
        <xsl:param name="pub-count" as="xs:integer"/>
        <xsl:param name="doc-mention-count" as="xs:integer"/>
        <xsl:param name="doc-authored-count" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="string($person/@xml:id) = $hanslick-id">hanslick</xsl:when>
            <xsl:when test="$doc-authored-count gt 0">doc-author</xsl:when>
            <xsl:when test="$doc-mention-count gt 0 and $person/@role = 'fictional'">doc-character</xsl:when>
            <xsl:when test="$doc-mention-count gt 0">doc-person</xsl:when>
            <xsl:when test="$pub-count gt 0 and $person/@role = 'fictional'">pub-character</xsl:when>
            <xsl:otherwise>pub-person</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="net_container">
        <script src="vendor/graphology/graphology.umd.min.js" />
        <script src="vendor/sigma/sigma.min.js" />
        <script src="js/person-network.js" />
        <div id="graphic-container" style="padding:.5em;">
            <xsl:variable name="graph-persons" as="element(tei:person)*" select="$net-person-index//tei:listPerson/tei:person"/>
            <xsl:variable name="graph-max-rel" as="xs:integer" select="max((1, for $person in $graph-persons return count(distinct-values((local:pub-targets($person), local:doc-mention-targets($person), local:doc-authored-targets($person))))))"/>

            <div class="person-network-panel">
                <div class="person-network-controls">
                    <label for="person-network-min-rel">Mindestanzahl Relationen:</label>
                    <input id="person-network-min-rel" type="number" min="1" max="{$graph-max-rel}" step="1" value="1"/>
                    <div class="person-network-node-limit">
                        <label for="person-network-node-limit">Knoten pro Kategorie:</label>
                        <input id="person-network-node-limit" type="number" min="1" step="1" value="25"/>
                        <span id="person-network-node-limit-max"></span>
                    </div>
                    <div class="person-network-category-toggles">
                        <label>
                            <input type="checkbox" class="person-network-category-toggle" data-group="pub-person" checked="checked"/>
Personen von Hanslick erwähnt</label>
                        <label>
                            <input type="checkbox" class="person-network-category-toggle" data-group="pub-character" checked="checked"/>
Figuren von Hanslick erwähnt</label>
                        <label>
                            <input type="checkbox" class="person-network-category-toggle" data-group="doc-author" checked="checked"/>
erwähnt Hanslick</label>
                        <label>
                            <input type="checkbox" class="person-network-category-toggle" data-group="doc-person" checked="checked"/>
Kopräsenz mit Hanslick (Person)</label>
                        <label>
                            <input type="checkbox" class="person-network-category-toggle" data-group="doc-character" checked="checked"/>
Kopräsenz mit Hanslick (Figur)</label>
                        <label>
                            <input type="checkbox" id="person-network-toggle-copresence"/>
Kopräsenz-Kanten zwischen Knoten</label>
                        <label class="person-network-copresence-min" for="person-network-min-copresence">Min. Kopräsenz:
                            <input id="person-network-min-copresence" type="number" min="1" step="1" value="2"/>
                        </label>
                        <span class="person-network-performance-note">Hinweis: Kopräsenz-Kanten sind bei großen Netzen aufwendig und standardmäßig deaktiviert.</span>
                    </div>
                </div>
                <div id="person-network"></div>
                <div class="person-network-hint">Klicken oder tippen Sie auf einen Knoten, um Details und den Link zur Personenseite anzuzeigen. Zoomen mit Mausrad oder Touch-Geste.</div>
                <div class="person-network-legend">
                    <span>
                        <i style="background:#1d4e89"></i>Personen von Hanslick erwähnt</span>
                    <span>
                        <i style="background:#5f93c2"></i>Figuren von Hanslick erwähnt</span>
                    <span>
                        <i style="background:#ba4a00"></i>erwähnt Hanslick</span>
                    <span>
                        <i style="background:#e67e22"></i>Kopräsenz mit Hanslick (Person)</span>
                    <span>
                        <i style="background:#f5b041"></i>Kopräsenz mit Hanslick (Figur)</span>
                </div>

                <div id="person-network-data" class="d-none" data-hanslick-id="{$hanslick-id}" data-max-rel="{$graph-max-rel}" data-source="person-network-data.json"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>