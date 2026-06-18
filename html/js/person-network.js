(function () {
    'use strict';

    var MAX_COPRESENCE_EDGES = 4500;
    var MAX_NODES_PER_TARGET = 90;

    function buildElements(nodeData) {
        var elements = [];
        var center = null;
        var targetToNodes = {};

        nodeData.forEach(function (node) {
            if (node.group === 'hanslick' || node.id === 'hsl_person_id_1') {
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

            if (node.targets && node.targets.length) {
                node.targets.forEach(function (targetId) {
                    if (!targetToNodes[targetId]) {
                        targetToNodes[targetId] = [];
                    }
                    targetToNodes[targetId].push(node.id);
                });
            }
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
                    weight: Math.max(1, node.relTotal),
                    kind: 'center'
                }
            });
        });

        return {
            elements: elements,
            center: center,
            targetToNodes: targetToNodes
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
                relDocAuthored: parseIntOr(el.getAttribute('data-rel-doc-authored'), 0),
                targets: (el.getAttribute('data-targets') || '').split('|').filter(function (value) {
                    return value.length > 0;
                })
            };
        }).filter(function (entry) {
            return entry.id.length > 0;
        });
    }

    function buildRankingData(nodeData, centerId) {
        var groups = ['pub-person', 'pub-character', 'doc-author', 'doc-person', 'doc-character'];
        var grouped = {};
        var nodeMetaById = {};

        groups.forEach(function (group) {
            grouped[group] = [];
        });

        nodeData.forEach(function (node) {
            nodeMetaById[node.id] = node;
            if (node.id === centerId) {
                return;
            }
            if (!grouped[node.group]) {
                grouped[node.group] = [];
            }
            grouped[node.group].push(node);
        });

        Object.keys(grouped).forEach(function (group) {
            grouped[group].sort(function (a, b) {
                if (b.relTotal !== a.relTotal) {
                    return b.relTotal - a.relTotal;
                }
                return String(a.label).localeCompare(String(b.label), 'de');
            });
        });

        return {
            groups: groups,
            grouped: grouped,
            nodeMetaById: nodeMetaById,
            maxGroupSize: Math.max.apply(null, groups.map(function (group) {
                return (grouped[group] || []).length;
            }).concat([1]))
        };
    }

    function collectEnabledGroups(categoryToggles) {
        var enabled = {};
        categoryToggles.forEach(function (checkbox) {
            var group = checkbox.getAttribute('data-group') || '';
            if (group.length > 0) {
                enabled[group] = checkbox.checked;
            }
        });
        return enabled;
    }

    function buildCopresenceEdges(cy, centerId, targetToNodes, visibleNodeIds, minCopresence) {
        var edgeWeights = {};
        var produced = 0;

        Object.keys(targetToNodes).forEach(function (targetId) {
            var sourceIds = targetToNodes[targetId] || [];
            var nodeIds = sourceIds.filter(function (id) {
                return visibleNodeIds[id] === true;
            });
            var uniqueIds = Array.from(new Set(nodeIds));
            var i;
            var j;
            var a;
            var b;
            var key;

            if (uniqueIds.length < 2 || uniqueIds.length > MAX_NODES_PER_TARGET) {
                return;
            }

            for (i = 0; i < uniqueIds.length; i += 1) {
                for (j = i + 1; j < uniqueIds.length; j += 1) {
                    a = uniqueIds[i];
                    b = uniqueIds[j];

                    if (a === centerId || b === centerId) {
                        continue;
                    }

                    key = a < b ? a + '|' + b : b + '|' + a;
                    if (!edgeWeights[key]) {
                        edgeWeights[key] = 0;
                    }
                    edgeWeights[key] += 1;
                }
            }
        });

        Object.keys(edgeWeights).forEach(function (pairKey) {
            var ids;
            if (produced >= MAX_COPRESENCE_EDGES) {
                return;
            }

            if (edgeWeights[pairKey] < minCopresence) {
                return;
            }

            ids = pairKey.split('|');
            cy.add({
                group: 'edges',
                data: {
                    id: 'edge-cop-' + ids[0] + '-' + ids[1],
                    source: ids[0],
                    target: ids[1],
                    weight: edgeWeights[pairKey],
                    kind: 'copresence'
                }
            });
            produced += 1;
        });
    }

    function applyFilters(cy, centerId, threshold, enabledGroups, options) {
        var visibleNodeIds = {};
        var visibleCount = 0;
        var limitedVisibleNodeIds = {};

        options.ranking.groups.forEach(function (group) {
            var shown = 0;
            var sorted = options.ranking.grouped[group] || [];

            if (enabledGroups[group] === false) {
                return;
            }

            sorted.forEach(function (node) {
                if (shown >= options.nodeLimitPerCategory) {
                    return;
                }
                if (node.relTotal >= threshold) {
                    limitedVisibleNodeIds[node.id] = true;
                    shown += 1;
                }
            });
        });

        cy.batch(function () {
            cy.edges('[kind = "copresence"]').remove();

            cy.nodes().forEach(function (node) {
                var isCenter = node.id() === centerId;
                var group = String(node.data('group') || '');
                var categoryVisible = isCenter || enabledGroups[group] !== false;
                var visible = isCenter || (categoryVisible && limitedVisibleNodeIds[node.id()] === true);
                node.style('display', visible ? 'element' : 'none');
                if (visible) {
                    visibleNodeIds[node.id()] = true;
                    visibleCount += 1;
                }
            });

            cy.edges().forEach(function (edge) {
                var sourceVisible = edge.source().style('display') !== 'none';
                var targetVisible = edge.target().style('display') !== 'none';
                edge.style('display', sourceVisible && targetVisible ? 'element' : 'none');
            });

            if (options.enableCopresence && visibleCount <= options.maxVisibleNodesForCopresence) {
                buildCopresenceEdges(cy, centerId, options.targetToNodes, visibleNodeIds, options.minCopresence);
            }
        });

        cy.fit(cy.elements(':visible'), 35);
    }

    function initialize() {
        var host = document.getElementById('person-network');
        var dataContainer = document.getElementById('person-network-data');
        var slider = document.getElementById('person-network-min-rel');
        var sliderValue = document.getElementById('person-network-min-rel-value');
        var nodeLimitSlider = document.getElementById('person-network-node-limit');
        var nodeLimitValue = document.getElementById('person-network-node-limit-value');
        var categoryToggles = Array.prototype.slice.call(document.querySelectorAll('.person-network-category-toggle'));
        var copresenceToggle = document.getElementById('person-network-toggle-copresence');
        var minCopresenceInput = document.getElementById('person-network-min-copresence');

        if (!host || !dataContainer || !slider || !sliderValue || !nodeLimitSlider || !nodeLimitValue || typeof cytoscape === 'undefined') {
            return;
        }

        var nodeData = parseNodeData(dataContainer);
        if (!nodeData.length) {
            return;
        }

        var assembled = buildElements(nodeData);
        var centerId = dataContainer.getAttribute('data-hanslick-id') || assembled.center;
        var ranking = buildRankingData(nodeData, centerId);
        var popupState = {
            nodeId: null,
            visible: false
        };

        host.innerHTML = '';

        var popup = document.createElement('div');
        popup.className = 'leaflet-popup leaflet-zoom-animated person-network-popup';
        popup.innerHTML = [
            '<div class="leaflet-popup-content-wrapper">',
            '  <button class="leaflet-popup-close-button" type="button" aria-label="Close" href="#close">',
            '    <span aria-hidden="true">x</span>',
            '  </button>',
            '  <div class="leaflet-popup-content"></div>',
            '</div>',
            '<div class="leaflet-popup-tip-container"><div class="leaflet-popup-tip"></div></div>'
        ].join('');
        host.appendChild(popup);

        var popupContent = popup.querySelector('.leaflet-popup-content');
        var popupClose = popup.querySelector('.leaflet-popup-close-button');

        var runtimeOptions = {
            targetToNodes: assembled.targetToNodes,
            enableCopresence: false,
            maxVisibleNodesForCopresence: 280,
            minCopresence: 2,
            ranking: ranking,
            nodeLimitPerCategory: 25
        };

        nodeLimitSlider.max = String(Math.max(25, ranking.maxGroupSize));
        nodeLimitSlider.value = '25';
        nodeLimitValue.textContent = '25';

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
                        'label': '',
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
                    selector: 'edge[kind = "copresence"]',
                    style: {
                        'line-color': '#9ca3af',
                        'line-style': 'dashed',
                        'opacity': 0.6,
                        'width': 'mapData(weight, 1, 30, 1, 3)'
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

        function hidePopup() {
            popup.style.display = 'none';
            popupState.visible = false;
            popupState.nodeId = null;
        }

        function placePopupForNode(node) {
            var pos;
            var popupRect;
            var x;
            var y;

            if (!node || node.empty() || !popupState.visible) {
                return;
            }

            if (node.style('display') === 'none') {
                hidePopup();
                return;
            }

            pos = node.renderedPosition();
            popup.style.display = 'block';
            popupRect = popup.getBoundingClientRect();

            x = pos.x - (popupRect.width / 2);
            y = pos.y - popupRect.height - 8;

            popup.style.left = String(Math.round(x)) + 'px';
            popup.style.top = String(Math.round(y)) + 'px';
        }

        function showPopupForNode(node) {
            var label = node.data('label') || '';
            var url = node.data('url') || '';
            var safeLabel = String(label)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;');

            popupContent.innerHTML = safeLabel + '<br/><a href="' + url + '">Read more</a>';
            popupState.visible = true;
            popupState.nodeId = node.id();
            placePopupForNode(node);
        }

        cy.on('tap', 'node', function (evt) {
            var node = evt.target;
            showPopupForNode(node);
        });

        cy.on('tap', function (evt) {
            if (evt.target === cy) {
                hidePopup();
            }
        });

        cy.on('pan zoom resize', function () {
            if (!popupState.visible || !popupState.nodeId) {
                return;
            }

            placePopupForNode(cy.getElementById(popupState.nodeId));
        });

        popupClose.addEventListener('click', function (event) {
            event.preventDefault();
            hidePopup();
        });

        var initialThreshold = parseIntOr(slider.value, 1);
        var enabledGroups = collectEnabledGroups(categoryToggles);
        runtimeOptions.enableCopresence = !!(copresenceToggle && copresenceToggle.checked);
        runtimeOptions.nodeLimitPerCategory = Math.max(1, parseIntOr(nodeLimitSlider.value, 25));
        if (minCopresenceInput) {
            runtimeOptions.minCopresence = Math.max(1, parseIntOr(minCopresenceInput.value, 2));
            minCopresenceInput.value = String(runtimeOptions.minCopresence);
        }
        sliderValue.textContent = String(initialThreshold);
        applyFilters(cy, centerId, initialThreshold, enabledGroups, runtimeOptions);

        slider.addEventListener('input', function () {
            var threshold = parseIntOr(slider.value, 1);
            sliderValue.textContent = String(threshold);
            applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
            if (popupState.visible && popupState.nodeId) {
                placePopupForNode(cy.getElementById(popupState.nodeId));
            }
        });

        nodeLimitSlider.addEventListener('input', function () {
            var threshold = parseIntOr(slider.value, 1);
            runtimeOptions.nodeLimitPerCategory = Math.max(1, parseIntOr(nodeLimitSlider.value, 25));
            nodeLimitValue.textContent = String(runtimeOptions.nodeLimitPerCategory);
            applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
            if (popupState.visible && popupState.nodeId) {
                placePopupForNode(cy.getElementById(popupState.nodeId));
            }
        });

        categoryToggles.forEach(function (checkbox) {
            checkbox.addEventListener('change', function () {
                var threshold = parseIntOr(slider.value, 1);
                enabledGroups = collectEnabledGroups(categoryToggles);
                applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
                if (popupState.visible && popupState.nodeId) {
                    placePopupForNode(cy.getElementById(popupState.nodeId));
                }
            });
        });

        if (copresenceToggle) {
            copresenceToggle.addEventListener('change', function () {
                var threshold = parseIntOr(slider.value, 1);
                runtimeOptions.enableCopresence = !!copresenceToggle.checked;
                applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
                if (popupState.visible && popupState.nodeId) {
                    placePopupForNode(cy.getElementById(popupState.nodeId));
                }
            });
        }

        if (minCopresenceInput) {
            minCopresenceInput.addEventListener('change', function () {
                var threshold = parseIntOr(slider.value, 1);
                runtimeOptions.minCopresence = Math.max(1, parseIntOr(minCopresenceInput.value, 2));
                minCopresenceInput.value = String(runtimeOptions.minCopresence);
                applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
                if (popupState.visible && popupState.nodeId) {
                    placePopupForNode(cy.getElementById(popupState.nodeId));
                }
            });
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize);
    } else {
        initialize();
    }
})();
