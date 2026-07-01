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

    <xsl:function name="local:json-escape" as="xs:string">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:variable name="v0" as="xs:string" select="string($value)"/>
        <xsl:variable name="v1" as="xs:string" select="replace($v0, '\\', '\\\\')"/>
        <xsl:variable name="v2" as="xs:string" select="replace($v1, '&quot;', '\\&quot;')"/>
        <xsl:variable name="v3" as="xs:string" select="replace($v2, codepoints-to-string(10), '\\n')"/>
        <xsl:variable name="v4" as="xs:string" select="replace($v3, codepoints-to-string(13), '\\r')"/>
        <xsl:sequence select="replace($v4, codepoints-to-string(9), '\\t')"/>
    </xsl:function>

    <xsl:template name="net_container">
        <script src="https://unpkg.com/graphology@0.25.4/dist/graphology.umd.min.js" />
        <script src="https://unpkg.com/sigma@2.4.0/build/sigma.min.js" />
        <script src="js/person-network.js" />
        <div id="graphic-container" style="padding:.5em;">
            <xsl:variable name="graph-persons" as="element(tei:person)*" select="$net-person-index//tei:listPerson/tei:person"/>
            <xsl:variable name="graph-max-rel" as="xs:integer" select="max((1, for $person in $graph-persons return count(distinct-values((local:pub-targets($person), local:doc-mention-targets($person), local:doc-authored-targets($person))))))"/>

            <xsl:result-document href="person-network-data.json" method="text" encoding="UTF-8">
                <xsl:text>{"hanslickId":"</xsl:text>
                <xsl:value-of select="$hanslick-id"/>
                <xsl:text>","maxRel":</xsl:text>
                <xsl:value-of select="$graph-max-rel"/>
                <xsl:text>,"nodes":[</xsl:text>
                <xsl:for-each select="$graph-persons[string(@xml:id) = $hanslick-id or count(distinct-values((local:pub-targets(.), local:doc-mention-targets(.), local:doc-authored-targets(.)))) gt 0]">
                    <xsl:variable name="pub-targets" as="xs:string*" select="local:pub-targets(.)"/>
                    <xsl:variable name="doc-targets" as="xs:string*" select="local:doc-mention-targets(.)"/>
                    <xsl:variable name="authored-targets" as="xs:string*" select="local:doc-authored-targets(.)"/>
                    <xsl:variable name="relation-targets" as="xs:string*" select="distinct-values(($pub-targets, $doc-targets, $authored-targets))"/>
                    <xsl:variable name="total-rel" as="xs:integer" select="count($relation-targets)"/>
                    <xsl:if test="position() gt 1">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                    <xsl:text>{"id":"</xsl:text>
                    <xsl:value-of select="local:json-escape(string(@xml:id))"/>
                    <xsl:text>","label":"</xsl:text>
                    <xsl:value-of select="local:json-escape(local:person-label(.))"/>
                    <xsl:text>","url":"</xsl:text>
                    <xsl:value-of select="local:json-escape(concat(string(@xml:id), '.html'))"/>
                    <xsl:text>","group":"</xsl:text>
                    <xsl:value-of select="local:json-escape(local:node-group(., count($pub-targets), count($doc-targets), count($authored-targets)))"/>
                    <xsl:text>","relTotal":</xsl:text>
                    <xsl:value-of select="$total-rel"/>
                    <xsl:text>,"relPub":</xsl:text>
                    <xsl:value-of select="count($pub-targets)"/>
                    <xsl:text>,"relDocMentions":</xsl:text>
                    <xsl:value-of select="count($doc-targets)"/>
                    <xsl:text>,"relDocAuthored":</xsl:text>
                    <xsl:value-of select="count($authored-targets)"/>
                    <xsl:text>,"targets":[</xsl:text>
                    <xsl:for-each select="$relation-targets">
                        <xsl:if test="position() gt 1">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="local:json-escape(.)"/>
                        <xsl:text>"</xsl:text>
                    </xsl:for-each>
                    <xsl:text>]}</xsl:text>
                </xsl:for-each>
                <xsl:text>]}</xsl:text>
            </xsl:result-document>

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