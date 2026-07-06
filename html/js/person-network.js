(function () {
    'use strict';

    var MAX_COPRESENCE_EDGES = 4500;
    var MAX_NODES_PER_TARGET = 90;
    var INITIAL_RENDER_NODE_CAP = 42;
    var INITIAL_RENDER_CHUNK_SIZE = 70;
    var INITIAL_RENDER_CHUNK_DELAY = 32;
    var GROUP_ORDER = ['hanslick', 'pub-person', 'pub-place', 'pub-work'];
    var GROUP_COLORS = {
        hanslick: '#111111',
        'pub-person': '#1d4e89',
        'pub-place': '#b91c1c',
        'pub-work': '#0f766e'
    };
    var COLLECTION_LABELS = {
        nfp: '<i>NFP</i>',
        vms: '<i>VMS</i>'
    };
    var COLLECTION_ORDER = ['nfp', 'vms'];

    function parseIntOr(value, fallback) {
        var parsed = parseInt(value, 10);
        if (Number.isNaN(parsed)) {
            return fallback;
        }
        return parsed;
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
                kind: el.getAttribute('data-kind') || 'person',
                group: el.getAttribute('data-group') || 'pub-person',
                targets: (el.getAttribute('data-targets') || '').split('|').filter(function (value) {
                    return value.length > 0;
                })
            };
        }).filter(function (entry) {
            return entry.id.length > 0;
        });
    }

    function normalizeStringArray(values) {
        if (!Array.isArray(values)) {
            return [];
        }

        return values.map(function (value) {
            return String(value || '');
        }).filter(function (value) {
            return value.length > 0;
        });
    }

    function normalizeNodeEntry(entry) {
        if (!entry || typeof entry !== 'object') {
            return null;
        }

        var targetsByCollection = {
            nfp: [],
            vms: []
        };

        if (entry.targetsByCollection && typeof entry.targetsByCollection === 'object') {
            targetsByCollection.nfp = normalizeStringArray(entry.targetsByCollection.nfp);
            targetsByCollection.vms = normalizeStringArray(entry.targetsByCollection.vms);
        }

        return {
            id: String(entry.id || ''),
            label: String(entry.label || ''),
            url: String(entry.url || ''),
            kind: String(entry.kind || 'person'),
            group: String(entry.group || 'pub-person'),
            relTotal: parseIntOr(entry.relTotal, 0),
            targets: normalizeStringArray(entry.targets),
            targetsByCollection: targetsByCollection
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
            var targets = getNodeTargets(node);

            if (!targets || !targets.length) {
                return;
            }

            targets.forEach(function (targetId) {
                if (!targetToNodes[targetId]) {
                    targetToNodes[targetId] = [];
                }
                targetToNodes[targetId].push(node.id);
            });
        });

        return targetToNodes;
    }

    function getNodeTargets(node) {
        if (!node) {
            return [];
        }
        return node.activeTargets || node.targets || [];
    }

    function getTargetCollection(targetId) {
        var value = String(targetId || '').trim();

        if (value.charAt(0) === '#') {
            value = value.slice(1);
        }

        if (value.indexOf('hsl_work_id_') === 0) {
            return 'vms';
        }
        if (value.indexOf('hsl_person_id_') === 0 || value.indexOf('hsl_place_id_') === 0) {
            return 'nfp';
        }

        if (value.indexOf('d__') === 0) {
            return 'nfp';
        }
        if (value.indexOf('t__') === 0 || value.indexOf('v__') === 0 || value.indexOf('w__') === 0) {
            return 'vms';
        }

        return '';
    }

    function getActiveRelTotal(node) {
        if (node && Number.isFinite(node.relTotalActive)) {
            return Math.max(0, parseIntOr(node.relTotalActive, 0));
        }
        return Math.max(0, parseIntOr(node && node.relTotal, 0));
    }

    function buildCollectionOptions() {
        return COLLECTION_ORDER.map(function (collection) {
            return {
                id: collection,
                label: COLLECTION_LABELS[collection] || collection.toUpperCase()
            };
        });
    }

    function collectEnabledCollections(collectionToggles) {
        var enabled = {};

        collectionToggles.forEach(function (checkbox) {
            var collection = checkbox.getAttribute('data-collection') || '';
            if (collection.length > 0) {
                enabled[collection] = checkbox.checked;
            }
        });

        return enabled;
    }

    function resolveNodeGroup(node) {
        var nodeKind = String(node.kind || 'person');

        if (node.id === 'hsl_person_id_1') {
            return 'hanslick';
        }
        if (nodeKind === 'work') {
            return 'pub-work';
        }
        if (nodeKind === 'place') {
            return 'pub-place';
        }
        return 'pub-person';
    }

    function collectActiveTargets(node, enabledCollections) {
        var activeTargets = [];
        var seenActiveTargets = {};
        var hasExplicitCollectionTargets = node.targetsByCollection && typeof node.targetsByCollection === 'object' && (Array.isArray(node.targetsByCollection.nfp) || Array.isArray(node.targetsByCollection.vms));

        function pushUniqueTarget(targetId) {
            var key = String(targetId || '');
            if (!key || seenActiveTargets[key]) {
                return;
            }
            seenActiveTargets[key] = true;
            activeTargets.push(key);
        }

        if (hasExplicitCollectionTargets) {
            COLLECTION_ORDER.forEach(function (collection) {
                var scopedTargets;

                if (enabledCollections[collection] === false) {
                    return;
                }
                scopedTargets = node.targetsByCollection[collection];
                if (!Array.isArray(scopedTargets)) {
                    return;
                }
                scopedTargets.forEach(pushUniqueTarget);
            });
            return activeTargets;
        }

        return (node.targets || []).filter(function (targetId) {
            var collection = getTargetCollection(targetId);

            if (!collection) {
                return false;
            }
            return enabledCollections[collection] !== false;
        });
    }

    function applyCollectionFilter(nodeData, enabledCollections) {
        var filteredNodes = [];

        nodeData.forEach(function (node) {
            var activeTargets = collectActiveTargets(node, enabledCollections);

            filteredNodes.push(Object.assign({}, node, {
                activeTargets: activeTargets,
                relTotalActive: activeTargets.length,
                group: resolveNodeGroup(node)
            }));
        });

        return filteredNodes;
    }

    function buildRankingData(nodeData, centerId) {
        var grouped = {};
        var centerNode = null;
        var centerTargets = {};

        nodeData.forEach(function (node) {
            if (node.id === centerId) {
                centerNode = node;
            }
        });

        if (centerNode) {
            getNodeTargets(centerNode).forEach(function (target) {
                centerTargets[target] = true;
            });
        }

        function sharedTargetCount(node) {
            var count = 0;
            var targets = getNodeTargets(node);

            if (!targets.length) {
                return 0;
            }

            targets.forEach(function (target) {
                if (centerTargets[target] === true) {
                    count += 1;
                }
            });

            return count;
        }

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
                var aShared = sharedTargetCount(a);
                var bShared = sharedTargetCount(b);

                if (bShared !== aShared) {
                    return bShared - aShared;
                }
                if (getActiveRelTotal(b) !== getActiveRelTotal(a)) {
                    return getActiveRelTotal(b) - getActiveRelTotal(a);
                }
                return String(a.label).localeCompare(String(b.label), 'de');
            });
        });

        return {
            grouped: grouped,
            maxGroupSize: Math.max.apply(null, GROUP_ORDER.map(function (group) {
                return (grouped[group] || []).length;
            }).concat([1]))
        };
    }

    function buildOrderedNodeIds(ranking) {
        var ordered = [];

        GROUP_ORDER.forEach(function (group) {
            (ranking.grouped[group] || []).forEach(function (node) {
                ordered.push(node.id);
            });
        });

        return ordered;
    }

    function collectEnabledGroups(categoryToggles) {
        var enabled = {};

        GROUP_ORDER.forEach(function (group) {
            enabled[group] = false;
        });

        categoryToggles.forEach(function (checkbox) {
            var group = checkbox.getAttribute('data-group') || '';
            if (group.length > 0) {
                enabled[group] = checkbox.checked;
            }
        });
        return enabled;
    }

    function getNodeKindTag(node) {
        var kind = String(node && node.kind || 'person');

        if (kind === 'place') {
            return 'O';
        }
        if (kind === 'work') {
            return 'W';
        }
        return 'P';
    }

    function buildNodeSearchEntries(nodeData) {
        var displayCount = {};

        nodeData.forEach(function (node) {
            var label = String(node.label || node.id || '').trim();
            var baseDisplay = label + ' (' + getNodeKindTag(node) + ')';

            if (!label) {
                return;
            }

            displayCount[baseDisplay] = (displayCount[baseDisplay] || 0) + 1;
        });

        return nodeData.map(function (node) {
            var label = String(node.label || node.id || '').trim();
            var baseDisplay = label + ' (' + getNodeKindTag(node) + ')';
            var needsIdSuffix = (displayCount[baseDisplay] || 0) > 1;

            if (!label) {
                return null;
            }

            return {
                id: String(node.id || ''),
                display: needsIdSuffix ? (baseDisplay + ' [' + String(node.id || '') + ']') : baseDisplay
            };
        }).filter(function (entry) {
            return !!entry && entry.id.length > 0;
        }).sort(function (a, b) {
            return String(a.display).localeCompare(String(b.display), 'de');
        });
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
        var centerNode = options.nodeMetaById[centerId];
        var centerTargets = {};

        function hasCenterLink(node) {
            var targets;

            if (!node || node.id === centerId) {
                return true;
            }

            targets = getNodeTargets(node);
            return targets.some(function (target) {
                return centerTargets[target] === true;
            });
        }

        getNodeTargets(centerNode).forEach(function (target) {
            centerTargets[target] = true;
        });

        desiredVisibleNodeIds[centerId] = true;

        GROUP_ORDER.forEach(function (group) {
            var shown = 0;
            var sorted = options.ranking.grouped[group] || [];

            if (enabledGroups[group] === false) {
                return;
            }

            sorted.forEach(function (node) {
                if (shown >= options.nodeLimitPerCategory) {
                    return;
                }
                if (!hasCenterLink(node)) {
                    return;
                }
                if (getActiveRelTotal(node) >= threshold) {
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

        function hashString(value) {
            var hash = 0;
            var i;
            var text = String(value || '');

            for (i = 0; i < text.length; i += 1) {
                hash = ((hash << 5) - hash) + text.charCodeAt(i);
                hash |= 0;
            }

            return Math.abs(hash);
        }

        function nudgeIfColliding(nodeId, point, occupied) {
            var minDist = 14;
            var minDistSquared = minDist * minDist;
            var attempts = 0;
            var seed = hashString(nodeId);
            var baseAngle = ((seed % 360) / 180) * Math.PI;
            var radiusStep = 4;
            var angleStep = Math.PI / 5;
            var x = point.x;
            var y = point.y;
            var collides;

            function hasCollision(px, py) {
                return occupied.some(function (existing) {
                    var dx = existing.x - px;
                    var dy = existing.y - py;
                    return ((dx * dx) + (dy * dy)) < minDistSquared;
                });
            }

            collides = hasCollision(x, y);
            while (collides && attempts < 16) {
                var ring = Math.floor(attempts / 4) + 1;
                var angle = baseAngle + (attempts * angleStep);
                var radius = ring * radiusStep;

                x = point.x + (Math.cos(angle) * radius);
                y = point.y + (Math.sin(angle) * radius);
                attempts += 1;
                collides = hasCollision(x, y);
            }

            occupied.push({ x: x, y: y });
            return { x: x, y: y };
        }

        function ringCapacity(radiusX, radiusY) {
            var perimeterEstimate = Math.PI * Math.sqrt(2 * ((radiusX * radiusX) + (radiusY * radiusY)));
            return Math.max(14, Math.floor(perimeterEstimate / 78));
        }

        positions[centerId] = { x: 0, y: 0 };
        var occupiedPositions = [{ x: 0, y: 0 }];

        while (index < idsToPlace.length) {
            var radiusX = Math.min(maxRadiusX, baseRadiusX + (ringIndex * ringStepX));
            var radiusY = Math.min(maxRadiusY, baseRadiusY + (ringIndex * ringStepY));
            var cap = ringCapacity(radiusX, radiusY);
            var slice = idsToPlace.slice(index, index + cap);

            slice.forEach(function (nodeId, localIndex) {
                var angle = startAngle + ((2 * Math.PI * localIndex) / Math.max(1, slice.length));
                var point = {
                    x: radiusX * Math.cos(angle),
                    y: radiusY * Math.sin(angle)
                };

                positions[nodeId] = nudgeIfColliding(nodeId, point, occupiedPositions);
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
                size: computeNodeSize(getActiveRelTotal(node), isCenter),
                color: isCenter ? GROUP_COLORS.hanslick : nodeColor,
                label: '',
                popupLabel: String(node.label || ''),
                forceLabel: false,
                zIndex: isCenter ? 10 : 1,
                url: String(node.url || ''),
                group: String(node.group || 'pub-person'),
                relTotal: getActiveRelTotal(node)
            });
        });

        Object.keys(visibleNodeIds).forEach(function (nodeId) {
            var node = options.nodeMetaById[nodeId];

            if (!node || nodeId === centerId) {
                return;
            }

            graph.addEdgeWithKey('edge-' + centerId + '-' + nodeId, centerId, nodeId, {
                size: computeEdgeSize(getActiveRelTotal(node), 'center'),
                color: '#8ca0b7',
                kind: 'center',
                weight: Math.max(1, getActiveRelTotal(node)),
                zIndex: 1
            });
        });

        if (options.enableCopresence) {
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

        return graph;
    }

    function initialize() {
        var host = document.getElementById('person-network');
        var dataContainer = document.getElementById('person-network-data');
        var categoryToggles = Array.prototype.slice.call(document.querySelectorAll('.person-network-category-toggle'));

        if (!host || !dataContainer || typeof graphology === 'undefined' || typeof Sigma === 'undefined') {
            return;
        }

        loadNodeData(dataContainer).then(function (loaded) {
            var nodeData = loaded.nodes;
            var meta;
            var centerId;
            var ranking;
            var collectionToggles = [];
            var enabledCollections = {};
            var itemLink;
            var renderer;
            var graphState;
            var enabledGroups;
            var pendingFrame = null;
            var progressiveTimer = null;
            var hoveredNodeId = null;
            var searchInput = document.getElementById('person-network-node-search');
            var searchButton = document.getElementById('person-network-node-search-button');
            var searchDatalist = document.getElementById('person-network-node-options');
            var searchIdByDisplay = {};
            var searchDisplayById = {};

            if (!nodeData.length) {
                return;
            }

            meta = buildNodeMeta(nodeData);
            centerId = loaded.hanslickId || meta.center;
            ranking = buildRankingData(nodeData, centerId);

            (function createCollectionControls() {
                var categoryContainer = document.querySelector('.person-network-category-toggles');
                var collectionOptions = buildCollectionOptions();
                var collectionContainer;

                if (!categoryContainer || !collectionOptions.length) {
                    return;
                }

                collectionContainer = document.createElement('div');
                collectionContainer.className = 'person-network-collection-toggles';
                collectionContainer.innerHTML = '<span class="person-network-collection-label">Kollektionen:</span>';

                collectionOptions.forEach(function (option) {
                    var label = document.createElement('label');
                    var input = document.createElement('input');
                    var text = document.createElement('span');

                    input.type = 'checkbox';
                    input.className = 'person-network-collection-toggle';
                    input.setAttribute('data-collection', option.id);
                    input.checked = option.id !== 'vms';
                    label.appendChild(input);
                    text.innerHTML = ' ' + option.label;
                    label.appendChild(text);
                    collectionContainer.appendChild(label);
                });

                categoryContainer.parentNode.insertBefore(collectionContainer, categoryContainer.nextSibling);
                collectionToggles = Array.prototype.slice.call(collectionContainer.querySelectorAll('.person-network-collection-toggle'));
                enabledCollections = collectEnabledCollections(collectionToggles);
            }());

            host.innerHTML = '';
            itemLink = document.createElement('a');
            itemLink.className = 'person-network-item-link';
            itemLink.textContent = 'Zur Knotenseite';
            itemLink.setAttribute('target', '_self');
            host.insertAdjacentElement('afterend', itemLink);

            graphState = {
                nodeData: nodeData,
                nodeMetaById: meta.nodeMetaById,
                ranking: ranking,
                orderedNodeIds: buildOrderedNodeIds(ranking),
                targetToNodes: buildTargetToNodes(nodeData),
                host: host,
                enableCopresence: true,
                minCopresence: 1,
                nodeLimitPerCategory: 25,
                renderCap: 0,
                visibleNodeIds: {}
            };

            function refreshDerivedGraphData() {
                var filteredNodeData = applyCollectionFilter(nodeData, enabledCollections);
                var filteredMeta = buildNodeMeta(filteredNodeData);

                if (!filteredMeta.nodeMetaById[centerId]) {
                    centerId = filteredMeta.center;
                }

                graphState.nodeData = filteredNodeData;
                graphState.nodeMetaById = filteredMeta.nodeMetaById;
                graphState.targetToNodes = buildTargetToNodes(filteredNodeData);
                ranking = buildRankingData(filteredNodeData, centerId);
                graphState.ranking = ranking;
                graphState.orderedNodeIds = buildOrderedNodeIds(ranking);
                refreshSearchDatalist();
                syncSearchInputWithCenter();
            }

            function refreshSearchDatalist() {
                var entries;

                if (!searchDatalist) {
                    return;
                }

                entries = buildNodeSearchEntries(graphState.nodeData);
                searchIdByDisplay = {};
                searchDisplayById = {};
                searchDatalist.innerHTML = '';

                entries.forEach(function (entry) {
                    var option = document.createElement('option');
                    option.value = entry.display;
                    searchDatalist.appendChild(option);
                    searchIdByDisplay[entry.display] = entry.id;
                    searchDisplayById[entry.id] = entry.display;
                });
            }

            function syncSearchInputWithCenter() {
                if (!searchInput || !searchDisplayById[centerId]) {
                    return;
                }
                searchInput.value = searchDisplayById[centerId];
            }

            function tryCenterFromSearch() {
                var query;
                var nodeId;

                if (!searchInput) {
                    return;
                }

                query = String(searchInput.value || '').trim();
                if (!query) {
                    return;
                }

                nodeId = searchIdByDisplay[query] || '';
                if (!nodeId || !graphState.nodeMetaById[nodeId]) {
                    return;
                }

                hoveredNodeId = null;
                setCenterNode(nodeId);
                renderer.refresh();
                syncSearchInputWithCenter();
            }

            refreshDerivedGraphData();

            renderer = new Sigma(new graphology.Graph(), host, {
                allowInvalidContainer: true,
                renderLabels: true,
                renderEdgeLabels: false,
                labelDensity: 0,
                labelRenderedSizeThreshold: 9999,
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
                    var highlighted = hoveredNodeId === node;

                    if (highlighted) {
                        reduced.highlighted = true;
                        reduced.zIndex = 20;
                        reduced.color = '#b45309';
                        reduced.label = String(data.popupLabel || data.label || '');
                        reduced.forceLabel = true;
                    } else {
                        reduced.label = '';
                        reduced.forceLabel = false;
                    }

                    return reduced;
                },
                edgeReducer: function (edge, data) {
                    var reduced = Object.assign({}, data);
                    var active = hoveredNodeId;

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

            function updateCenterItemLink() {
                var node = graphState.nodeMetaById[centerId];

                if (!node || !node.url) {
                    itemLink.classList.remove('is-visible');
                    itemLink.removeAttribute('href');
                    return;
                }

                itemLink.href = String(node.url);
                itemLink.classList.add('is-visible');
            }

            function clearProgressiveTimer() {
                if (progressiveTimer !== null) {
                    clearTimeout(progressiveTimer);
                    progressiveTimer = null;
                }
            }

            function renderGraph(threshold) {
                var visibility = computeVisibleNodeIds(centerId, threshold, enabledGroups, graphState);
                var graph;

                graphState.visibleNodeIds = visibility.visibleNodeIds;
                graph = createGraphModel(centerId, visibility.visibleNodeIds, graphState);
                renderer.setGraph(graph);
                renderer.refresh();

                return {
                    desiredVisibleCount: visibility.desiredVisibleCount
                };
            }

            function setCenterNode(nodeId) {
                if (!nodeId || !graphState.nodeMetaById[nodeId]) {
                    return;
                }

                centerId = nodeId;
                ranking = buildRankingData(graphState.nodeData, centerId);
                graphState.ranking = ranking;
                graphState.orderedNodeIds = buildOrderedNodeIds(ranking);
                updateCenterItemLink();
                renderGraph(1);
                syncSearchInputWithCenter();

                try {
                    var camera = renderer.getCamera();
                    if (camera && typeof camera.animatedReset === 'function') {
                        camera.animatedReset({ duration: 320 });
                    } else if (camera && typeof camera.animate === 'function') {
                        camera.animate({ x: 0, y: 0, ratio: 1 }, { duration: 320 });
                    }
                } catch (error) {
                    // Ignore camera reset failures in older or custom Sigma builds.
                }
            }

            function scheduleGraphUpdate() {
                if (pendingFrame !== null) {
                    cancelAnimationFrame(pendingFrame);
                }
                pendingFrame = requestAnimationFrame(function () {
                    pendingFrame = null;
                    clearProgressiveTimer();
                    graphState.renderCap = 0;
                    renderGraph(1);
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

            var maxNodeLimit = Math.max(1, ranking.maxGroupSize);
            var initialThreshold = 1;

            enabledGroups = collectEnabledGroups(categoryToggles);
            graphState.enableCopresence = true;
            graphState.nodeLimitPerCategory = maxNodeLimit;
            graphState.minCopresence = 1;
            updateCenterItemLink();

            renderer.on('enterNode', function (event) {
                hoveredNodeId = event.node;
                renderer.refresh();
            });

            renderer.on('leaveNode', function (event) {
                if (hoveredNodeId === event.node) {
                    hoveredNodeId = null;
                }
                renderer.refresh();
            });

            renderer.on('clickNode', function (event) {
                setCenterNode(event.node);
                renderer.refresh();
            });

            renderer.on('clickStage', function () {
                hoveredNodeId = null;
                renderer.refresh();
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

            categoryToggles.forEach(function (checkbox) {
                checkbox.addEventListener('change', function () {
                    enabledGroups = collectEnabledGroups(categoryToggles);
                    scheduleGraphUpdate();
                });
            });

            collectionToggles.forEach(function (checkbox) {
                checkbox.addEventListener('change', function () {
                    enabledCollections = collectEnabledCollections(collectionToggles);
                    refreshDerivedGraphData();
                    scheduleGraphUpdate();
                });
            });

            if (searchButton) {
                searchButton.addEventListener('click', function () {
                    tryCenterFromSearch();
                });
            }

            if (searchInput) {
                searchInput.addEventListener('change', function () {
                    tryCenterFromSearch();
                });

                searchInput.addEventListener('keydown', function (event) {
                    if (event.key !== 'Enter') {
                        return;
                    }
                    event.preventDefault();
                    tryCenterFromSearch();
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
