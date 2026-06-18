(function () {
    'use strict';

    var MAX_COPRESENCE_EDGES = 4500;
    var MAX_NODES_PER_TARGET = 90;
    var INITIAL_ZOOM_WIDE = 1;
    var INITIAL_ZOOM_DEFAULT = 0.86;

    function computeNodeSize(relTotal) {
        var rel = Math.max(1, parseIntOr(relTotal, 1));
        return Math.round(Math.min(72, 20 + (Math.sqrt(rel) * 5.2)));
    }

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
                    relDocAuthored: node.relDocAuthored,
                    nodeSize: computeNodeSize(node.relTotal)
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

    function normalizeNodeEntry(entry) {
        if (!entry || typeof entry !== 'object') {
            return null;
        }

        return {
            id: String(entry.id || ''),
            label: String(entry.label || ''),
            url: String(entry.url || ''),
            group: String(entry.group || 'pub-person'),
            relTotal: parseIntOr(entry.relTotal, 0),
            relPub: parseIntOr(entry.relPub, 0),
            relDocMentions: parseIntOr(entry.relDocMentions, 0),
            relDocAuthored: parseIntOr(entry.relDocAuthored, 0),
            targets: Array.isArray(entry.targets) ? entry.targets.map(function (target) {
                return String(target || '');
            }).filter(function (target) {
                return target.length > 0;
            }) : []
        };
    }

    function loadNodeData(container) {
        var source = container.getAttribute('data-source') || '';
        var fallbackNodeData = parseNodeData(container);
        var fallbackHanslickId = container.getAttribute('data-hanslick-id') || '';

        if (!source || typeof fetch === 'undefined') {
            return Promise.resolve({
                nodes: fallbackNodeData,
                hanslickId: fallbackHanslickId
            });
        }

        return fetch(source, {
            credentials: 'same-origin'
        }).then(function (response) {
            if (!response.ok) {
                throw new Error('Failed to load graph data: ' + String(response.status));
            }
            return response.json();
        }).then(function (payload) {
            if (!payload || !Array.isArray(payload.nodes)) {
                throw new Error('Invalid graph data payload');
            }

            return {
                nodes: payload.nodes.map(normalizeNodeEntry).filter(function (entry) {
                    return !!entry && entry.id.length > 0;
                }),
                hanslickId: String(payload.hanslickId || fallbackHanslickId || '')
            };
        }).catch(function () {
            return {
                nodes: fallbackNodeData,
                hanslickId: fallbackHanslickId
            };
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

    function buildOrderedNodeIds(ranking) {
        var ordered = [];

        ranking.groups.forEach(function (group) {
            (ranking.grouped[group] || []).forEach(function (node) {
                ordered.push(node.id);
            });
        });

        return ordered;
    }

    function initialZoomForWidth(width) {
        if (width >= 1800) {
            return INITIAL_ZOOM_WIDE;
        }
        return INITIAL_ZOOM_DEFAULT;
    }

    function applyCompactLayout(cy, orderedNodeIds, centerId, host, visibleNodeIds) {
        var width = Math.max(960, host.clientWidth || 1200);
        var height = Math.max(420, host.clientHeight || 560);
        var ringStepX = Math.max(60, Math.round(width * 0.07));
        var ringStepY = Math.max(34, Math.round(height * 0.07));
        var baseRadiusX = Math.max(160, Math.round(width * 0.15));
        var baseRadiusY = Math.max(86, Math.round(height * 0.17));
        var maxRadiusX = Math.max(260, Math.round((width * 0.5) - 70));
        var maxRadiusY = Math.max(140, Math.round((height * 0.5) - 40));
        var startAngle = -Math.PI / 2;
        var ringIndex = 0;
        var index = 0;
        var centerNode = cy.getElementById(centerId);

        function ringCapacity(radiusX, radiusY) {
            var perimeterEstimate = Math.PI * Math.sqrt(2 * ((radiusX * radiusX) + (radiusY * radiusY)));
            return Math.max(14, Math.floor(perimeterEstimate / 54));
        }

        var idsToPlace = orderedNodeIds.filter(function (nodeId) {
            return !visibleNodeIds || visibleNodeIds[nodeId] === true;
        });

        if (centerNode && !centerNode.empty()) {
            centerNode.position({ x: 0, y: 0 });
        }

        while (index < idsToPlace.length) {
            var radiusX = Math.min(maxRadiusX, baseRadiusX + (ringIndex * ringStepX));
            var radiusY = Math.min(maxRadiusY, baseRadiusY + (ringIndex * ringStepY));
            var cap = ringCapacity(radiusX, radiusY);
            var slice = idsToPlace.slice(index, index + cap);

            slice.forEach(function (nodeId, localIndex) {
                var node = cy.getElementById(nodeId);
                var angle;
                var x;
                var y;

                if (!node || node.empty()) {
                    return;
                }

                angle = startAngle + ((2 * Math.PI * localIndex) / Math.max(1, slice.length));
                x = Math.round(radiusX * Math.cos(angle));
                y = Math.round(radiusY * Math.sin(angle));
                node.position({ x: x, y: y });
            });

            index += slice.length;
            ringIndex += 1;
        }
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
            cy.edges('[kind = "copresence"], [kind = "center"]').remove();

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

            Object.keys(visibleNodeIds).forEach(function (nodeId) {
                var nodeMeta;

                if (nodeId === centerId) {
                    return;
                }

                nodeMeta = options.ranking.nodeMetaById[nodeId];
                if (!nodeMeta) {
                    return;
                }

                cy.add({
                    group: 'edges',
                    data: {
                        id: 'edge-' + centerId + '-' + nodeId,
                        source: centerId,
                        target: nodeId,
                        weight: Math.max(1, parseIntOr(nodeMeta.relTotal, 1)),
                        kind: 'center'
                    }
                });
            });

            if (options.enableCopresence && visibleCount <= options.maxVisibleNodesForCopresence) {
                buildCopresenceEdges(cy, centerId, options.targetToNodes, visibleNodeIds, options.minCopresence);
            }
        });

        applyCompactLayout(cy, options.orderedNodeIds, centerId, options.host, visibleNodeIds);

        var centerNode = cy.getElementById(centerId);

        if (centerNode && !centerNode.empty() && centerNode.style('display') !== 'none') {
            cy.center(centerNode);
        }
    }

    function initialize() {
        var host = document.getElementById('person-network');
        var dataContainer = document.getElementById('person-network-data');
        var minRelInput = document.getElementById('person-network-min-rel');
        var nodeLimitSlider = document.getElementById('person-network-node-limit');
        var nodeLimitMax = document.getElementById('person-network-node-limit-max');
        var categoryToggles = Array.prototype.slice.call(document.querySelectorAll('.person-network-category-toggle'));
        var copresenceToggle = document.getElementById('person-network-toggle-copresence');
        var minCopresenceInput = document.getElementById('person-network-min-copresence');

        if (!host || !dataContainer || !minRelInput || !nodeLimitSlider || typeof cytoscape === 'undefined') {
            return;
        }

        loadNodeData(dataContainer).then(function (loaded) {
            var nodeData = loaded.nodes;
            if (!nodeData.length) {
                return;
            }

            var assembled = buildElements(nodeData);
            var centerId = loaded.hanslickId || assembled.center;
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
                nodeLimitPerCategory: 25,
                orderedNodeIds: buildOrderedNodeIds(ranking),
                host: host
            };

            var maxNodeLimit = Math.max(1, ranking.maxGroupSize);
            var defaultNodeLimit = Math.min(25, maxNodeLimit);
            nodeLimitSlider.max = String(maxNodeLimit);
            nodeLimitSlider.value = String(defaultNodeLimit);
            if (nodeLimitMax) {
                nodeLimitMax.textContent = '/ max ' + String(maxNodeLimit);
            }

            var cy = cytoscape({
                container: host,
                elements: assembled.elements,
                minZoom: 0.2,
                maxZoom: 4,
                wheelSensitivity: 0.16,
                layout: {
                    name: 'preset',
                    fit: false,
                    animate: false
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
                        'width': 'data(nodeSize)',
                        'height': 'data(nodeSize)',
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

            var centerNode = cy.getElementById(centerId);
            if (centerNode && !centerNode.empty()) {
                cy.zoom(initialZoomForWidth(host.clientWidth || 1200));
                cy.center(centerNode);

                window.addEventListener('resize', function () {
                    cy.zoom(initialZoomForWidth(host.clientWidth || 1200));
                    applyFilters(cy, centerId, parseIntOr(slider.value, 1), enabledGroups, runtimeOptions);
                    if (popupState.visible && popupState.nodeId) {
                        placePopupForNode(cy.getElementById(popupState.nodeId));
                    }
                });
            }

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
                var relPub = parseIntOr(node.data('relPub'), 0);
                var relDocAuthored = parseIntOr(node.data('relDocAuthored'), 0);
                var relDocMentions = parseIntOr(node.data('relDocMentions'), 0);
                var copresenceCount = node.connectedEdges('[kind = "copresence"]').filter(':visible').length;
                var details = [];
                var safeLabel = String(label)
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;');

                if (relPub > 0) {
                    details.push('vom H. erwähnt: ' + String(relPub));
                }
                if (relDocAuthored > 0) {
                    details.push('erwähnt Hanslick: ' + String(relDocAuthored));
                }
                if (relDocMentions > 0) {
                    details.push('Kopräsenz mit Hanslick: ' + String(relDocMentions));
                }
                if (copresenceCount > 0) {
                    details.push('Copresence: ' + String(copresenceCount));
                }

                popupContent.innerHTML = safeLabel + (details.length ? '<br/>' + details.join('<br/>') : '') + '<br/><a href="' + url + '">Read more</a>';
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

            var initialThreshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));
            var enabledGroups = collectEnabledGroups(categoryToggles);
            runtimeOptions.enableCopresence = !!(copresenceToggle && copresenceToggle.checked);
            runtimeOptions.nodeLimitPerCategory = Math.min(maxNodeLimit, Math.max(1, parseIntOr(nodeLimitSlider.value, defaultNodeLimit)));
            nodeLimitSlider.value = String(runtimeOptions.nodeLimitPerCategory);
            if (minCopresenceInput) {
                runtimeOptions.minCopresence = Math.max(1, parseIntOr(minCopresenceInput.value, 2));
                minCopresenceInput.value = String(runtimeOptions.minCopresence);
            }
            minRelInput.value = String(initialThreshold);
            applyFilters(cy, centerId, initialThreshold, enabledGroups, runtimeOptions);

            minRelInput.addEventListener('input', function () {
                var threshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));
                minRelInput.value = String(threshold);
                applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
                if (popupState.visible && popupState.nodeId) {
                    placePopupForNode(cy.getElementById(popupState.nodeId));
                }
            });

            nodeLimitSlider.addEventListener('input', function () {
                var threshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));
                runtimeOptions.nodeLimitPerCategory = Math.min(maxNodeLimit, Math.max(1, parseIntOr(nodeLimitSlider.value, defaultNodeLimit)));
                nodeLimitSlider.value = String(runtimeOptions.nodeLimitPerCategory);
                applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
                if (popupState.visible && popupState.nodeId) {
                    placePopupForNode(cy.getElementById(popupState.nodeId));
                }
            });

            categoryToggles.forEach(function (checkbox) {
                checkbox.addEventListener('change', function () {
                    var threshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));
                    enabledGroups = collectEnabledGroups(categoryToggles);
                    applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
                    if (popupState.visible && popupState.nodeId) {
                        placePopupForNode(cy.getElementById(popupState.nodeId));
                    }
                });
            });

            if (copresenceToggle) {
                copresenceToggle.addEventListener('change', function () {
                    var threshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));
                    runtimeOptions.enableCopresence = !!copresenceToggle.checked;
                    applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
                    if (popupState.visible && popupState.nodeId) {
                        placePopupForNode(cy.getElementById(popupState.nodeId));
                    }
                });
            }

            if (minCopresenceInput) {
                minCopresenceInput.addEventListener('change', function () {
                    var threshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));
                    runtimeOptions.minCopresence = Math.max(1, parseIntOr(minCopresenceInput.value, 2));
                    minCopresenceInput.value = String(runtimeOptions.minCopresence);
                    applyFilters(cy, centerId, threshold, enabledGroups, runtimeOptions);
                    if (popupState.visible && popupState.nodeId) {
                        placePopupForNode(cy.getElementById(popupState.nodeId));
                    }
                });
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize);
    } else {
        initialize();
    }
})();
