<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:graphics"
    version="2.0"
    exclude-result-prefixes="tei xsl xs local">

    <xsl:template name="vms_net_container">
        <script src="vendor/graphology/graphology.umd.min.js" />
        <script src="vendor/sigma/sigma.min.js" />
        <script src="js/vms-network.js" />

        <div id="graphic-container" class="graphic-container-padded">
            <div class="person-network-panel">
                <div class="person-network-controls">
                    <label for="vms-network-relation-mode">
                        <xsl:value-of select="local:text('Kopräsenz-Ebene:', 'Copresence level:')"/>
                    </label>
                    <select id="vms-network-relation-mode" class="form-select form-select-sm person-network-control-select person-network-control-select-relmode">
                        <option value="paragraph">
                            <xsl:value-of select="local:text('Absatz', 'Paragraph')"/>
                        </option>
                        <option value="chapter">
                            <xsl:value-of select="local:text('Kapitel', 'Chapter')"/>
                        </option>
                    </select>

                    <div class="person-network-category-toggles">
                        <label>
                            <input type="checkbox" class="vms-network-kind-toggle" data-kind="person" checked="checked"/>
                            <xsl:value-of select="local:text('Personen', 'Persons')"/>
                        </label>
                        <label>
                            <input type="checkbox" class="vms-network-kind-toggle" data-kind="work" checked="checked"/>
                            <xsl:value-of select="local:text('Werke', 'Works')"/>
                        </label>
                         <label>
                            <input type="checkbox" class="vms-network-kind-toggle" data-kind="place" checked="checked"/>
                            <xsl:value-of select="local:text('Orte', 'Places')"/>
                        </label>
                        <span class="person-network-performance-note">
                            <xsl:value-of select="local:text('Klick auf einen Knoten setzt ihn als Zentrum. Klick auf die Fläche hebt das Zentrum auf.', 'Click a node to set it as center. Click the stage to clear the center.')"/>
                        </span>
                    </div>

                    <div class="person-network-search-row">
                        <label for="vms-network-node-search">
                            <xsl:value-of select="local:text('Knoten suchen:', 'Search node:')"/>
                        </label>
                        <input id="vms-network-node-search" class="person-network-search-input" type="text" list="vms-network-node-options" placeholder="Name eingeben"/>
                        <button id="vms-network-node-search-button" class="person-network-search-button" type="button">
                            <xsl:value-of select="local:text('Zentrieren', 'Center')"/>
                        </button>
                        <datalist id="vms-network-node-options"/>
                    </div>
                </div>

                <div id="vms-network"></div>
                <div id="vms-network-hint" class="person-network-hint">
                    <xsl:value-of select="local:text('Kanten zeigen Kopräsenz in derselben Einheit (Absatz oder Kapitel).', 'Edges represent copresence in the same unit (paragraph or chapter).')"/>
                </div>
                <div class="person-network-legend">
                    <span><i class="person-network-swatch-person"></i><xsl:value-of select="local:text('Person', 'Person')"/></span>
                    <span><i class="person-network-swatch-work-vms"></i><xsl:value-of select="local:text('Werk', 'Work')"/></span>
                    <span><i class="person-network-swatch-center"></i><xsl:value-of select="local:text('Aktuelles Zentrum', 'Current center')"/></span>
                    <span><i class="network-line-key network-line-single"></i><xsl:value-of select="local:text('einmalige Kopräsenz', 'single copresence')"/></span>
                    <span><i class="network-line-key network-line-multiple"></i><xsl:value-of select="local:text('mehrfache Kopräsenz', 'multiple copresences')"/></span>
                </div>
                <div id="vms-network-details" class="person-network-hint"></div>

                <div id="vms-network-data" class="d-none" data-source="data/vms-network-data.json"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
