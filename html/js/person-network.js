(function () {
    'use strict';

    var MAX_COPRESENCE_EDGES = 4500;
    var MAX_NODES_PER_TARGET = 90;
    var INITIAL_RENDER_NODE_CAP = 42;
    var INITIAL_RENDER_CHUNK_SIZE = 70;
    var INITIAL_RENDER_CHUNK_DELAY = 32;
    var GROUP_ORDER = ['pub-person', 'pub-character', 'doc-author', 'doc-person', 'doc-character'];
    var GROUP_COLORS = {
        hanslick: '#111111',
        'pub-person': '#1d4e89',
        'pub-character': '#5f93c2',
        'doc-author': '#ba4a00',
        'doc-person': '#e67e22',
        'doc-character': '#f5b041'
    };

    function parseIntOr(value, fallback) {
        var parsed = parseInt(value, 10);
        if (Number.isNaN(parsed)) {
            return fallback;
        }
        return parsed;
    }

    function escapeHtml(value) {
        return String(value || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function computeNodeSize(relTotal, isCenter) {
        var rel = Math.max(1, parseIntOr(relTotal, 1));
        if (isCenter) {
            return 18;
        }
        return Math.max(5, Math.min(13, 4.8 + (Math.sqrt(rel) * 0.85)));
    }

    function computeEdgeSize(weight, kind) {
        var base = Math.max(1, parseIntOr(weight, 1));
        if (kind === 'copresence') {
            return Math.min(2.2, 0.45 + (Math.log(base + 1) * 0.34));
        }
        return Math.min(3.6, 0.85 + (Math.log(base + 1) * 0.48));
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

    function buildNodeMeta(nodeData) {
        var nodeMetaById = {};
        var center = '';

        nodeData.forEach(function (node) {
            if (node.group === 'hanslick' || node.id === 'hsl_person_id_1') {
                center = node.id;
            }
            nodeMetaById[node.id] = node;
        });

        if (!center && nodeData.length) {
            center = nodeData[0].id;
        }

        return {
            center: center,
            nodeMetaById: nodeMetaById
        };
    }

    function buildTargetToNodes(nodeData) {
        var targetToNodes = {};

        nodeData.forEach(function (node) {
            if (!node.targets || !node.targets.length) {
                return;
            }

            node.targets.forEach(function (targetId) {
                if (!targetToNodes[targetId]) {
                    targetToNodes[targetId] = [];
                }
                targetToNodes[targetId].push(node.id);
            });
        });

        return targetToNodes;
    }

    function buildRankingData(nodeData, centerId) {
        var grouped = {};

        GROUP_ORDER.forEach(function (group) {
            grouped[group] = [];
        });

        nodeData.forEach(function (node) {
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
            groups: GROUP_ORDER.slice(),
            grouped: grouped,
            maxGroupSize: Math.max.apply(null, GROUP_ORDER.map(function (group) {
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

    function capVisibleNodeIds(visibleNodeIds, centerId, orderedNodeIds, renderCap) {
        var limitedIds = {};
        var kept = 0;

        if (!renderCap || renderCap < 1) {
            return visibleNodeIds;
        }

        limitedIds[centerId] = true;
        kept = 1;

        orderedNodeIds.forEach(function (nodeId) {
            if (kept >= renderCap) {
                return;
            }
            if (visibleNodeIds[nodeId] !== true || nodeId === centerId) {
                return;
            }
            limitedIds[nodeId] = true;
            kept += 1;
        });

        return limitedIds;
    }

    function computeVisibleNodeIds(centerId, threshold, enabledGroups, options) {
        var desiredVisibleNodeIds = {};
        var desiredVisibleCount = 1;

        desiredVisibleNodeIds[centerId] = true;

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
                    desiredVisibleNodeIds[node.id] = true;
                    desiredVisibleCount += 1;
                    shown += 1;
                }
            });
        });

        return {
            desiredVisibleNodeIds: desiredVisibleNodeIds,
            desiredVisibleCount: desiredVisibleCount,
            visibleNodeIds: capVisibleNodeIds(
                desiredVisibleNodeIds,
                centerId,
                options.orderedNodeIds,
                parseIntOr(options.renderCap, 0)
            )
        };
    }

    function buildLayoutPositions(orderedNodeIds, centerId, host, visibleNodeIds) {
        var positions = {};
        var width = Math.max(960, host.clientWidth || 1200);
        var height = Math.max(420, host.clientHeight || 560);
        var ringStepX = Math.max(110, Math.round(width * 0.11));
        var ringStepY = Math.max(64, Math.round(height * 0.11));
        var baseRadiusX = Math.max(180, Math.round(width * 0.18));
        var baseRadiusY = Math.max(120, Math.round(height * 0.21));
        var maxRadiusX = Math.max(360, Math.round((width * 0.62) - 90));
        var maxRadiusY = Math.max(220, Math.round((height * 0.62) - 60));
        var startAngle = -Math.PI / 2;
        var ringIndex = 0;
        var index = 0;
        var idsToPlace = orderedNodeIds.filter(function (nodeId) {
            return visibleNodeIds[nodeId] === true && nodeId !== centerId;
        });

        function ringCapacity(radiusX, radiusY) {
            var perimeterEstimate = Math.PI * Math.sqrt(2 * ((radiusX * radiusX) + (radiusY * radiusY)));
            return Math.max(14, Math.floor(perimeterEstimate / 78));
        }

        positions[centerId] = { x: 0, y: 0 };

        while (index < idsToPlace.length) {
            var radiusX = Math.min(maxRadiusX, baseRadiusX + (ringIndex * ringStepX));
            var radiusY = Math.min(maxRadiusY, baseRadiusY + (ringIndex * ringStepY));
            var cap = ringCapacity(radiusX, radiusY);
            var slice = idsToPlace.slice(index, index + cap);

            slice.forEach(function (nodeId, localIndex) {
                var angle = startAngle + ((2 * Math.PI * localIndex) / Math.max(1, slice.length));
                positions[nodeId] = {
                    x: Math.round(radiusX * Math.cos(angle)),
                    y: Math.round(radiusY * Math.sin(angle))
                };
            });

            index += slice.length;
            ringIndex += 1;
        }

        return positions;
    }

    function buildCopresenceEdges(centerId, targetToNodes, visibleNodeIds, minCopresence) {
        var edgeWeights = {};
        var edges = [];

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

            if (edges.length >= MAX_COPRESENCE_EDGES) {
                return;
            }
            if (edgeWeights[pairKey] < minCopresence) {
                return;
            }

            ids = pairKey.split('|');
            edges.push({
                id: 'edge-cop-' + ids[0] + '-' + ids[1],
                source: ids[0],
                target: ids[1],
                weight: edgeWeights[pairKey],
                kind: 'copresence'
            });
        });

        return edges;
    }

    function createGraphModel(centerId, visibleNodeIds, options) {
        var graph = new graphology.Graph();
        var positions = buildLayoutPositions(options.orderedNodeIds, centerId, options.host, visibleNodeIds);
        var copresenceEdges = [];

        Object.keys(visibleNodeIds).forEach(function (nodeId) {
            var node = options.nodeMetaById[nodeId];
            var isCenter = nodeId === centerId;
            var position = positions[nodeId] || { x: 0, y: 0 };
            var nodeColor = GROUP_COLORS[node.group] || GROUP_COLORS['pub-person'];

            if (!node) {
                return;
            }

            graph.addNode(nodeId, {
                x: position.x,
                y: position.y,
                size: computeNodeSize(node.relTotal, isCenter),
                color: isCenter ? GROUP_COLORS.hanslick : nodeColor,
                label: String(node.label || ''),
                forceLabel: isCenter,
                zIndex: isCenter ? 10 : 1,
                url: String(node.url || ''),
                group: String(node.group || 'pub-person'),
                relTotal: parseIntOr(node.relTotal, 0),
                relPub: parseIntOr(node.relPub, 0),
                relDocMentions: parseIntOr(node.relDocMentions, 0),
                relDocAuthored: parseIntOr(node.relDocAuthored, 0)
            });
        });

        Object.keys(visibleNodeIds).forEach(function (nodeId) {
            var node = options.nodeMetaById[nodeId];

            if (!node || nodeId === centerId) {
                return;
            }

            graph.addEdgeWithKey('edge-' + centerId + '-' + nodeId, centerId, nodeId, {
                size: computeEdgeSize(node.relTotal, 'center'),
                color: '#8ca0b7',
                kind: 'center',
                weight: Math.max(1, parseIntOr(node.relTotal, 1)),
                zIndex: 1
            });
        });

        if (options.enableCopresence && Object.keys(visibleNodeIds).length <= options.maxVisibleNodesForCopresence) {
            copresenceEdges = buildCopresenceEdges(centerId, options.targetToNodes, visibleNodeIds, options.minCopresence);
            copresenceEdges.forEach(function (edge) {
                if (!graph.hasNode(edge.source) || !graph.hasNode(edge.target) || graph.hasEdge(edge.id)) {
                    return;
                }
                graph.addEdgeWithKey(edge.id, edge.source, edge.target, {
                    size: computeEdgeSize(edge.weight, edge.kind),
                    color: '#c8ced6',
                    kind: edge.kind,
                    weight: edge.weight,
                    zIndex: 0
                });
            });
        }

        return {
            graph: graph,
            copresenceEdgeIds: copresenceEdges.map(function (edge) {
                return edge.id;
            })
        };
    }

    function initializePopup(host) {
        var popup = document.createElement('div');
        popup.className = 'person-network-popup';
        popup.innerHTML = [
            '<div class="person-network-popup-content-wrapper">',
            '  <button class="person-network-popup-close-button" type="button" aria-label="Close">',
            '    <span aria-hidden="true">x</span>',
            '  </button>',
            '  <div class="person-network-popup-content"></div>',
            '</div>',
            '<div class="person-network-popup-tip-container"><div class="person-network-popup-tip"></div></div>'
        ].join('');
        host.appendChild(popup);

        return {
            popup: popup,
            content: popup.querySelector('.person-network-popup-content'),
            closeButton: popup.querySelector('.person-network-popup-close-button')
        };
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

        if (!host || !dataContainer || !minRelInput || !nodeLimitSlider || typeof graphology === 'undefined' || typeof Sigma === 'undefined') {
            return;
        }

        loadNodeData(dataContainer).then(function (loaded) {
            var nodeData = loaded.nodes;
            var meta;
            var centerId;
            var ranking;
            var popupElements;
            var renderer;
            var graphState;
            var enabledGroups;
            var pendingFrame = null;
            var progressiveTimer = null;
            var activeNodeId = null;
            var hoveredNodeId = null;
            var popupState = {
                visible: false,
                nodeId: null
            };

            if (!nodeData.length) {
                return;
            }

            meta = buildNodeMeta(nodeData);
            centerId = loaded.hanslickId || meta.center;
            ranking = buildRankingData(nodeData, centerId);

            host.innerHTML = '';
            popupElements = initializePopup(host);

            graphState = {
                targetToNodes: buildTargetToNodes(nodeData),
                nodeData: nodeData,
                nodeMetaById: meta.nodeMetaById,
                ranking: ranking,
                orderedNodeIds: buildOrderedNodeIds(ranking),
                host: host,
                enableCopresence: false,
                maxVisibleNodesForCopresence: 280,
                minCopresence: 2,
                nodeLimitPerCategory: 25,
                renderCap: 0,
                visibleNodeIds: {},
                copresenceEdgeIds: []
            };

            renderer = new Sigma(new graphology.Graph(), host, {
                allowInvalidContainer: true,
                renderEdgeLabels: false,
                labelDensity: 0.08,
                labelRenderedSizeThreshold: 13,
                labelSize: 13,
                labelFont: 'Georgia, serif',
                edgeLabelSize: 12,
                stagePadding: 30,
                minCameraRatio: 0.06,
                maxCameraRatio: 5,
                defaultEdgeType: 'line',
                zIndex: true,
                nodeReducer: function (node, data) {
                    var reduced = Object.assign({}, data);
                    var selected = activeNodeId === node;
                    var highlighted = hoveredNodeId === node || selected;

                    if (highlighted) {
                        reduced.highlighted = true;
                        reduced.forceLabel = true;
                        reduced.zIndex = 20;
                        reduced.color = '#b45309';
                    }

                    return reduced;
                },
                edgeReducer: function (edge, data) {
                    var reduced = Object.assign({}, data);
                    var active = activeNodeId || hoveredNodeId;

                    if (!active) {
                        return reduced;
                    }

                    if (renderer.getGraph().hasExtremity(edge, active)) {
                        reduced.color = data.kind === 'copresence' ? '#9ca3af' : '#5f7085';
                        reduced.size = Math.max(data.size || 1, (data.size || 1) + 0.3);
                    } else {
                        reduced.color = '#e5e7eb';
                    }

                    return reduced;
                }
            });

            function hidePopup() {
                popupElements.popup.style.display = 'none';
                popupState.visible = false;
                popupState.nodeId = null;
            }

            function countCopresenceEdges(nodeId) {
                var count = 0;

                graphState.copresenceEdgeIds.forEach(function (edgeId) {
                    if (!renderer.getGraph().hasEdge(edgeId)) {
                        return;
                    }
                    if (renderer.getGraph().hasExtremity(edgeId, nodeId)) {
                        count += 1;
                    }
                });

                return count;
            }

            function placePopupForNode(nodeId) {
                var displayData;
                var viewportPosition;
                var popupRect;
                var x;
                var y;

                if (!popupState.visible || !nodeId || !renderer.getGraph().hasNode(nodeId)) {
                    hidePopup();
                    return;
                }

                displayData = renderer.getNodeDisplayData(nodeId);
                if (!displayData) {
                    hidePopup();
                    return;
                }

                viewportPosition = renderer.graphToViewport({
                    x: displayData.x,
                    y: displayData.y
                });
                popupElements.popup.style.display = 'block';
                popupRect = popupElements.popup.getBoundingClientRect();

                x = viewportPosition.x - (popupRect.width / 2);
                y = viewportPosition.y - popupRect.height - 10;

                popupElements.popup.style.left = String(Math.round(x)) + 'px';
                popupElements.popup.style.top = String(Math.round(y)) + 'px';
            }

            function showPopupForNode(nodeId) {
                var graph = renderer.getGraph();
                var node;
                var details = [];
                var copresenceCount;

                if (!graph.hasNode(nodeId)) {
                    hidePopup();
                    return;
                }

                node = graph.getNodeAttributes(nodeId);
                copresenceCount = countCopresenceEdges(nodeId);

                if (node.relPub > 0) {
                    details.push('vom H. erwähnt: ' + String(node.relPub));
                }
                if (node.relDocAuthored > 0) {
                    details.push('erwähnt Hanslick: ' + String(node.relDocAuthored));
                }
                if (node.relDocMentions > 0) {
                    details.push('Kopräsenz mit Hanslick: ' + String(node.relDocMentions));
                }
                if (copresenceCount > 0) {
                    details.push('Kopräsenz-Kanten: ' + String(copresenceCount));
                }

                popupElements.content.innerHTML = [
                    '<strong>' + escapeHtml(node.label) + '</strong>',
                    details.length ? '<br>' + details.map(escapeHtml).join('<br>') : '',
                    node.url ? '<br><a href="' + escapeHtml(node.url) + '">Zur Personenseite</a>' : ''
                ].join('');
                popupState.visible = true;
                popupState.nodeId = nodeId;
                placePopupForNode(nodeId);
            }

            function clearProgressiveTimer() {
                if (progressiveTimer !== null) {
                    clearTimeout(progressiveTimer);
                    progressiveTimer = null;
                }
            }

            function renderGraph(threshold) {
                var visibility = computeVisibleNodeIds(centerId, threshold, enabledGroups, graphState);
                var model;

                graphState.visibleNodeIds = visibility.visibleNodeIds;
                model = createGraphModel(centerId, visibility.visibleNodeIds, graphState);
                graphState.copresenceEdgeIds = model.copresenceEdgeIds;
                renderer.setGraph(model.graph);
                renderer.refresh();

                if (popupState.visible && popupState.nodeId) {
                    if (model.graph.hasNode(popupState.nodeId)) {
                        placePopupForNode(popupState.nodeId);
                    } else {
                        hidePopup();
                    }
                }

                return {
                    desiredVisibleCount: visibility.desiredVisibleCount,
                    renderedVisibleCount: Object.keys(visibility.visibleNodeIds).length
                };
            }

            function scheduleGraphUpdate() {
                if (pendingFrame !== null) {
                    cancelAnimationFrame(pendingFrame);
                }
                pendingFrame = requestAnimationFrame(function () {
                    var threshold;

                    pendingFrame = null;
                    threshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));
                    clearProgressiveTimer();
                    graphState.renderCap = 0;
                    renderGraph(threshold);
                });
            }

            function runProgressiveInitialRender(initialThreshold) {
                var initialCap = Math.max(1, Math.min(INITIAL_RENDER_NODE_CAP, (graphState.nodeLimitPerCategory * 2) + 1));

                function step() {
                    var result;

                    graphState.renderCap = initialCap;
                    result = renderGraph(initialThreshold);

                    if (initialCap >= Math.max(1, result.desiredVisibleCount || 1)) {
                        graphState.renderCap = 0;
                        return;
                    }

                    initialCap = Math.min(result.desiredVisibleCount, initialCap + INITIAL_RENDER_CHUNK_SIZE);
                    progressiveTimer = setTimeout(step, INITIAL_RENDER_CHUNK_DELAY);
                }

                step();
            }

            function syncPopupToHighlight() {
                renderer.refresh();
                if (popupState.visible && popupState.nodeId) {
                    placePopupForNode(popupState.nodeId);
                }
            }

            var maxNodeLimit = Math.max(1, ranking.maxGroupSize);
            var defaultNodeLimit = Math.min(25, maxNodeLimit);
            var initialThreshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));

            enabledGroups = collectEnabledGroups(categoryToggles);
            graphState.enableCopresence = !!(copresenceToggle && copresenceToggle.checked);
            graphState.nodeLimitPerCategory = Math.min(maxNodeLimit, Math.max(1, parseIntOr(nodeLimitSlider.value, defaultNodeLimit)));
            graphState.minCopresence = minCopresenceInput ? Math.max(1, parseIntOr(minCopresenceInput.value, 2)) : 2;

            nodeLimitSlider.max = String(maxNodeLimit);
            nodeLimitSlider.value = String(graphState.nodeLimitPerCategory);
            minRelInput.value = String(initialThreshold);
            if (minCopresenceInput) {
                minCopresenceInput.value = String(graphState.minCopresence);
            }
            if (nodeLimitMax) {
                nodeLimitMax.textContent = '/ max ' + String(maxNodeLimit);
            }

            renderer.on('enterNode', function (event) {
                hoveredNodeId = event.node;
                if (!activeNodeId) {
                    showPopupForNode(event.node);
                }
                syncPopupToHighlight();
            });

            renderer.on('leaveNode', function (event) {
                if (hoveredNodeId === event.node) {
                    hoveredNodeId = null;
                }
                if (!activeNodeId) {
                    hidePopup();
                }
                syncPopupToHighlight();
            });

            renderer.on('clickNode', function (event) {
                if (activeNodeId === event.node) {
                    activeNodeId = null;
                    if (hoveredNodeId) {
                        showPopupForNode(hoveredNodeId);
                    } else {
                        hidePopup();
                    }
                } else {
                    activeNodeId = event.node;
                    showPopupForNode(event.node);
                }
                syncPopupToHighlight();
            });

            renderer.on('clickStage', function () {
                activeNodeId = null;
                if (hoveredNodeId) {
                    showPopupForNode(hoveredNodeId);
                } else {
                    hidePopup();
                }
                syncPopupToHighlight();
            });

            renderer.on('afterRender', function () {
                if (popupState.visible && popupState.nodeId) {
                    placePopupForNode(popupState.nodeId);
                }
            });

            popupElements.closeButton.addEventListener('click', function (event) {
                event.preventDefault();
                activeNodeId = null;
                if (hoveredNodeId) {
                    showPopupForNode(hoveredNodeId);
                } else {
                    hidePopup();
                }
                syncPopupToHighlight();
            });

            window.addEventListener('resize', function () {
                scheduleGraphUpdate();
            });

            requestAnimationFrame(function () {
                runProgressiveInitialRender(initialThreshold);
                try {
                    window.dispatchEvent(new CustomEvent('person-network-ready'));
                } catch (error) {
                    // Ignore event dispatch failures in older browsers.
                }
            });

            minRelInput.addEventListener('input', function () {
                var threshold = Math.min(parseIntOr(minRelInput.max, ranking.maxGroupSize), Math.max(1, parseIntOr(minRelInput.value, 1)));
                minRelInput.value = String(threshold);
                scheduleGraphUpdate();
            });

            nodeLimitSlider.addEventListener('input', function () {
                graphState.nodeLimitPerCategory = Math.min(maxNodeLimit, Math.max(1, parseIntOr(nodeLimitSlider.value, defaultNodeLimit)));
                nodeLimitSlider.value = String(graphState.nodeLimitPerCategory);
                scheduleGraphUpdate();
            });

            categoryToggles.forEach(function (checkbox) {
                checkbox.addEventListener('change', function () {
                    enabledGroups = collectEnabledGroups(categoryToggles);
                    scheduleGraphUpdate();
                });
            });

            if (copresenceToggle) {
                copresenceToggle.addEventListener('change', function () {
                    graphState.enableCopresence = !!copresenceToggle.checked;
                    scheduleGraphUpdate();
                });
            }

            if (minCopresenceInput) {
                minCopresenceInput.addEventListener('change', function () {
                    graphState.minCopresence = Math.max(1, parseIntOr(minCopresenceInput.value, 2));
                    minCopresenceInput.value = String(graphState.minCopresence);
                    scheduleGraphUpdate();
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
