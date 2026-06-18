(function () {
    'use strict';

    function buildElements(nodeData) {
        var elements = [];
        var center = null;

        nodeData.forEach(function (node) {
            if (node.group === 'hanslick') {
                center = node.id;
            }

            elements.push({
                data: {
                    id: node.id,
                    label: node.label,
                    url: node.url,
                    group: node.group,
                    relTotal: node.relTotal,
                    relPub: node.relPub,
                    relDocMentions: node.relDocMentions,
                    relDocAuthored: node.relDocAuthored
                }
            });
        });

        if (!center && nodeData.length) {
            center = nodeData[0].id;
        }

        nodeData.forEach(function (node) {
            if (node.id === center) {
                return;
            }

            elements.push({
                data: {
                    id: 'edge-' + center + '-' + node.id,
                    source: center,
                    target: node.id,
                    weight: Math.max(1, node.relTotal)
                }
            });
        });

        return {
            elements: elements,
            center: center
        };
    }

    function parseIntOr(value, fallback) {
        var parsed = parseInt(value, 10);
        if (Number.isNaN(parsed)) {
            return fallback;
        }
        return parsed;
    }

    function parseNodeData(container) {
        return Array.prototype.slice.call(container.querySelectorAll('.person-network-node')).map(function (el) {
            return {
                id: el.getAttribute('data-id') || '',
                label: el.getAttribute('data-label') || '',
                url: el.getAttribute('data-url') || '',
                group: el.getAttribute('data-group') || 'pub-person',
                relTotal: parseIntOr(el.getAttribute('data-rel-total'), 0),
                relPub: parseIntOr(el.getAttribute('data-rel-pub'), 0),
                relDocMentions: parseIntOr(el.getAttribute('data-rel-doc-mentions'), 0),
                relDocAuthored: parseIntOr(el.getAttribute('data-rel-doc-authored'), 0)
            };
        }).filter(function (entry) {
            return entry.id.length > 0;
        });
    }

    function applyThreshold(cy, centerId, threshold) {
        cy.batch(function () {
            cy.nodes().forEach(function (node) {
                var isCenter = node.id() === centerId;
                var relTotal = parseIntOr(node.data('relTotal'), 0);
                var visible = isCenter || relTotal >= threshold;
                node.style('display', visible ? 'element' : 'none');
            });

            cy.edges().forEach(function (edge) {
                var sourceVisible = edge.source().style('display') !== 'none';
                var targetVisible = edge.target().style('display') !== 'none';
                edge.style('display', sourceVisible && targetVisible ? 'element' : 'none');
            });
        });

        cy.layout({
            name: 'concentric',
            fit: true,
            padding: 35,
            animate: false,
            concentric: function (node) {
                if (node.id() === centerId) {
                    return 999;
                }
                return parseIntOr(node.data('relTotal'), 0);
            },
            levelWidth: function () {
                return 1;
            },
            spacingFactor: 1.05
        }).run();
    }

    function initialize() {
        var host = document.getElementById('person-network');
        var dataContainer = document.getElementById('person-network-data');
        var slider = document.getElementById('person-network-min-rel');
        var sliderValue = document.getElementById('person-network-min-rel-value');

        if (!host || !dataContainer || !slider || !sliderValue || typeof cytoscape === 'undefined') {
            return;
        }

        var nodeData = parseNodeData(dataContainer);
        if (!nodeData.length) {
            return;
        }

        var assembled = buildElements(nodeData);
        var centerId = dataContainer.getAttribute('data-hanslick-id') || assembled.center;

        var cy = cytoscape({
            container: host,
            elements: assembled.elements,
            minZoom: 0.2,
            maxZoom: 4,
            wheelSensitivity: 0.16,
            layout: {
                name: 'concentric',
                fit: true,
                padding: 35,
                animate: false,
                concentric: function (node) {
                    if (node.id() === centerId) {
                        return 999;
                    }
                    return parseIntOr(node.data('relTotal'), 0);
                },
                levelWidth: function () {
                    return 1;
                },
                spacingFactor: 1.05
            },
            style: [
                {
                    selector: 'node',
                    style: {
                        'label': 'data(label)',
                        'font-size': 10,
                        'text-wrap': 'wrap',
                        'text-max-width': 120,
                        'text-valign': 'center',
                        'text-halign': 'center',
                        'color': '#1f2937',
                        'background-color': '#1d4e89',
                        'width': 'mapData(relTotal, 1, 30, 24, 56)',
                        'height': 'mapData(relTotal, 1, 30, 24, 56)',
                        'border-width': 1,
                        'border-color': '#ffffff'
                    }
                },
                {
                    selector: 'node[group = "hanslick"]',
                    style: {
                        'background-color': '#111111',
                        'color': '#ffffff',
                        'font-size': 12,
                        'width': 64,
                        'height': 64,
                        'z-index': 20
                    }
                },
                {
                    selector: 'node[group = "pub-person"]',
                    style: {
                        'background-color': '#1d4e89'
                    }
                },
                {
                    selector: 'node[group = "pub-character"]',
                    style: {
                        'background-color': '#5f93c2'
                    }
                },
                {
                    selector: 'node[group = "doc-author"]',
                    style: {
                        'background-color': '#ba4a00'
                    }
                },
                {
                    selector: 'node[group = "doc-person"]',
                    style: {
                        'background-color': '#e67e22'
                    }
                },
                {
                    selector: 'node[group = "doc-character"]',
                    style: {
                        'background-color': '#f5b041'
                    }
                },
                {
                    selector: 'edge',
                    style: {
                        'curve-style': 'bezier',
                        'width': 'mapData(weight, 1, 30, 1, 4)',
                        'line-color': '#7c8ea5',
                        'opacity': 0.8
                    }
                },
                {
                    selector: ':selected',
                    style: {
                        'overlay-opacity': 0,
                        'border-width': 3,
                        'border-color': '#f59e0b'
                    }
                }
            ]
        });

        cy.on('tap', 'node', function (evt) {
            var node = evt.target;
            var url = node.data('url');
            if (url) {
                window.location.href = url;
            }
        });

        var initialThreshold = parseIntOr(slider.value, 1);
        sliderValue.textContent = String(initialThreshold);
        applyThreshold(cy, centerId, initialThreshold);

        slider.addEventListener('input', function () {
            var threshold = parseIntOr(slider.value, 1);
            sliderValue.textContent = String(threshold);
            applyThreshold(cy, centerId, threshold);
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize);
    } else {
        initialize();
    }
})();
