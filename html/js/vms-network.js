(function () {
    'use strict';

    var NODE_COLORS = {
        person: '#1d4e89',
        work: '#ba4a00',
        center: '#111111'
    };
    var MAX_NODES_PER_UNIT = 260;

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

    function normalizeNode(node) {
        return {
            id: String(node.id || ''),
            label: String(node.label || ''),
            kind: String(node.kind || ''),
            url: String(node.url || ''),
            chapterKeys: Array.isArray(node.chapterKeys) ? node.chapterKeys : [],
            paragraphKeys: Array.isArray(node.paragraphKeys) ? node.paragraphKeys : []
        };
    }

    function loadData(container) {
        var source = container.getAttribute('data-source') || '';
        if (!source || typeof fetch === 'undefined') {
            return Promise.resolve({ nodes: [] });
        }
        return fetch(source, { credentials: 'same-origin' })
            .then(function (response) {
                if (!response.ok) {
                    throw new Error('Failed to load network data');
                }
                return response.json();
            })
            .then(function (payload) {
                if (!payload || !Array.isArray(payload.nodes)) {
                    throw new Error('Invalid payload');
                }
                return {
                    nodes: payload.nodes.map(normalizeNode).filter(function (node) {
                        return node.id.length > 0;
                    })
                };
            });
    }

    function buildIndexes(nodes) {
        var byId = {};
        nodes.forEach(function (node) {
            byId[node.id] = node;
        });
        return byId;
    }

    function kindLabel(kind) {
        if (kind === 'work') {
            return 'Work';
        }
        if (kind === 'place') {
            return 'Place';
        }
        return 'Person';
    }

    function buildNodeSearchEntries(nodes) {
        var labelCounts = {};
        var entries = [];

        nodes.forEach(function (node) {
            var label = String(node.label || '').trim();

            if (!label) {
                return;
            }
            labelCounts[label] = (labelCounts[label] || 0) + 1;
        });

        nodes.forEach(function (node) {
            var label = String(node.label || '').trim();
            var display = label;

            if (!label) {
                return;
            }
            if (labelCounts[label] > 1) {
                display = label + ' (' + kindLabel(node.kind) + ')';
            }

            entries.push({
                id: node.id,
                display: display,
                label: label
            });
        });

        entries.sort(function (a, b) {
            var byLabel = a.label.localeCompare(b.label, 'de');

            if (byLabel !== 0) {
                return byLabel;
            }

            return a.display.localeCompare(b.display, 'de');
        });

        return entries;
    }

    function ensureSearchControls() {
        var searchInput = document.getElementById('vms-network-node-search');
        var searchButton = document.getElementById('vms-network-node-search-button');
        var searchDatalist = document.getElementById('vms-network-node-options');
        var controls;
        var row;
        var label;
        var isEnglish;

        if (searchInput && searchButton && searchDatalist) {
            return {
                searchInput: searchInput,
                searchButton: searchButton,
                searchDatalist: searchDatalist
            };
        }

        controls = document.querySelector('.person-network-controls');
        if (!controls) {
            return {
                searchInput: null,
                searchButton: null,
                searchDatalist: null
            };
        }

        isEnglish = String((document.documentElement && document.documentElement.lang) || '').toLowerCase().indexOf('en') === 0;

        row = document.createElement('div');
        row.className = 'person-network-search-row';

        label = document.createElement('label');
        label.setAttribute('for', 'vms-network-node-search');
        label.textContent = isEnglish ? 'Search node:' : 'Knoten suchen:';
        row.appendChild(label);

        searchInput = document.createElement('input');
        searchInput.id = 'vms-network-node-search';
        searchInput.className = 'person-network-search-input';
        searchInput.type = 'text';
        searchInput.setAttribute('list', 'vms-network-node-options');
        searchInput.setAttribute('placeholder', isEnglish ? 'Enter name' : 'Name eingeben');
        row.appendChild(searchInput);

        searchButton = document.createElement('button');
        searchButton.id = 'vms-network-node-search-button';
        searchButton.className = 'person-network-search-button';
        searchButton.type = 'button';
        searchButton.textContent = isEnglish ? 'Center' : 'Zentrieren';
        row.appendChild(searchButton);

        searchDatalist = document.createElement('datalist');
        searchDatalist.id = 'vms-network-node-options';
        row.appendChild(searchDatalist);

        controls.appendChild(row);

        return {
            searchInput: searchInput,
            searchButton: searchButton,
            searchDatalist: searchDatalist
        };
    }


    function edgeVisuals(weight) {
        if (weight <= 1) {
            return {
                size: 0.9,
                color: '#c6d1dd'
            };
        }
        if (weight <= 3) {
            return {
                size: 1.8,
                color: '#8da0b3'
            };
        }
        return {
            size: Math.min(4.2, 2.6 + (Math.log(weight + 1) * 0.8)),
            color: '#334155'
        };
    }

    function nodeVisualSize(score, minScore, maxScore, isCenter) {
        if (isCenter) {
            return 24;
        }

        if (maxScore <= minScore) {
            return 12;
        }

        var normalized = (score - minScore) / (maxScore - minScore);
        var emphasized = Math.pow(Math.max(0, Math.min(1, normalized)), 0.6);
        return 6 + (emphasized * 18);
    }

    function pairKey(a, b) {
        return a < b ? a + '|' + b : b + '|' + a;
    }

    function getModeCache(modeCache, mode, nodes) {
        var cache = modeCache[mode];
        var unitField = mode === 'chapter' ? 'chapterKeys' : 'paragraphKeys';

        if (cache) {
            return cache;
        }

        var unitToNodeIds = {};
        var edgeWeights = {};
        var nodeScores = {};

        nodes.forEach(function (node) {
            var keys = Array.from(new Set(node[unitField] || []));
            keys.forEach(function (key) {
                if (!unitToNodeIds[key]) {
                    unitToNodeIds[key] = [];
                }
                unitToNodeIds[key].push(node.id);
            });
        });

        Object.keys(unitToNodeIds).forEach(function (unitKey) {
            var ids = Array.from(new Set(unitToNodeIds[unitKey]));
            var i;
            var j;
            if (ids.length < 2 || ids.length > MAX_NODES_PER_UNIT) {
                return;
            }
            for (i = 0; i < ids.length; i += 1) {
                if (!nodeScores[ids[i]]) {
                    nodeScores[ids[i]] = 0;
                }
            }
            for (i = 0; i < ids.length; i += 1) {
                for (j = i + 1; j < ids.length; j += 1) {
                    var key = pairKey(ids[i], ids[j]);
                    if (!edgeWeights[key]) {
                        edgeWeights[key] = 0;
                    }
                    edgeWeights[key] += 1;
                    nodeScores[ids[i]] += 1;
                    nodeScores[ids[j]] += 1;
                }
            }
        });

        cache = {
            edgeWeights: edgeWeights,
            nodeScores: nodeScores
        };
        modeCache[mode] = cache;
        return cache;
    }

    function buildLayout(orderedIds, centerId, host) {
        var positions = {};
        var width = Math.max(960, host.clientWidth || 1200);
        var height = Math.max(460, host.clientHeight || 580);
        var radiusX = Math.max(260, Math.round(width * 0.36));
        var radiusY = Math.max(170, Math.round(height * 0.34));

        if (centerId) {
            var others = orderedIds.filter(function (id) {
                return id !== centerId;
            });
            positions[centerId] = { x: 0, y: 0 };
            others.forEach(function (id, index) {
                var angle = -Math.PI / 2 + ((2 * Math.PI * index) / Math.max(1, others.length));
                positions[id] = {
                    x: Math.round(radiusX * Math.cos(angle)),
                    y: Math.round(radiusY * Math.sin(angle))
                };
            });
            return positions;
        }

        orderedIds.forEach(function (id, index) {
            var angle = -Math.PI / 2 + ((2 * Math.PI * index) / Math.max(1, orderedIds.length));
            positions[id] = {
                x: Math.round(radiusX * Math.cos(angle)),
                y: Math.round(radiusY * Math.sin(angle))
            };
        });

        return positions;
    }

    function initialize() {
        var host = document.getElementById('vms-network');
        var dataContainer = document.getElementById('vms-network-data');
        var relationModeInput = document.getElementById('vms-network-relation-mode');
        var nodeLimitInput = document.getElementById('vms-network-node-limit');
        var detailBox = document.getElementById('vms-network-details');
        var kindToggles = Array.prototype.slice.call(document.querySelectorAll('.vms-network-kind-toggle'));
        var searchControls = ensureSearchControls();
        var searchInput = searchControls.searchInput;
        var searchButton = searchControls.searchButton;
        var searchDatalist = searchControls.searchDatalist;

        if (!host || !dataContainer || !relationModeInput ||
            typeof graphology === 'undefined' || typeof Sigma === 'undefined') {
            return;
        }

        loadData(dataContainer).then(function (payload) {
            var nodes = payload.nodes;
            var nodeById = buildIndexes(nodes);
            var modeCache = {
                chapter: null,
                paragraph: null
            };
            var centerId = '';
            var searchIdByDisplay = {};
            var searchDisplayById = {};
            var renderer = new Sigma(new graphology.Graph(), host, {
                allowInvalidContainer: true,
                renderEdgeLabels: false,
                labelDensity: 0.08,
                labelRenderedSizeThreshold: 11,
                labelSize: 12,
                labelFont: 'Georgia, serif',
                stagePadding: 30,
                minCameraRatio: 0.06,
                maxCameraRatio: 5,
                defaultEdgeType: 'line',
                zIndex: true
            });

            function getEnabledKinds() {
                var enabled = {};
                kindToggles.forEach(function (toggle) {
                    enabled[toggle.getAttribute('data-kind')] = !!toggle.checked;
                });
                return enabled;
            }

            function updateDetails(nodeId, score, mode, chapterCount, paragraphCount) {
                if (!detailBox) {
                    return;
                }
                if (!nodeId || !nodeById[nodeId]) {
                    detailBox.textContent = '';
                    return;
                }

                var node = nodeById[nodeId];
                detailBox.innerHTML = [
                    '<strong>' + escapeHtml(node.label) + '</strong>',
                    ' | Typ: ' + escapeHtml(kindLabel(node.kind)),
                    ' | Relationen (' + escapeHtml(mode) + '): ' + String(score || 0),
                    ' | Kapitel-Einheiten: ' + String(chapterCount || 0),
                    ' | Absatz-Einheiten: ' + String(paragraphCount || 0),
                    node.url ? ' | <a href="' + escapeHtml(node.url) + '">Detailseite</a>' : ''
                ].join('');
            }

            function refreshSearchDatalist(enabledKinds, cache) {
                var entries;

                if (!searchDatalist || !cache) {
                    return;
                }

                entries = buildNodeSearchEntries(nodes.filter(function (node) {
                    var score = cache.nodeScores[node.id] || 0;
                    return !!enabledKinds[node.kind] && score >= 1;
                }));

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
                if (!searchInput) {
                    return;
                }
                if (!centerId || !searchDisplayById[centerId]) {
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
                if (!nodeId || !nodeById[nodeId]) {
                    return;
                }

                centerId = nodeId;
                renderGraph();
            }

            function renderGraph() {
                var mode = relationModeInput.value === 'chapter' ? 'chapter' : 'paragraph';
                var nodeLimit = Math.max(5, parseIntOr(nodeLimitInput ? nodeLimitInput.value : 120, 120));
                var enabledKinds = getEnabledKinds();
                var cache = getModeCache(modeCache, mode, nodes);
                var gradeCache = getModeCache(modeCache, 1, nodes);
                var graph = new graphology.Graph();
                var selectedNodes = [];
                var grouped = {
                    person: [],
                    work: []
                };
                var selectedById = {};

                nodes.forEach(function (node) {
                    var score = cache.nodeScores[node.id] || 0;
                    if (!enabledKinds[node.kind]) {
                        return;
                    }
                    if (score < 1) {
                        return;
                    }
                    if (!grouped[node.kind]) {
                        return;
                    }
                    grouped[node.kind].push({ node: node, score: score });
                });

                if (centerId && nodeById[centerId] && enabledKinds[nodeById[centerId].kind]) {
                    selectedById[centerId] = {
                        node: nodeById[centerId],
                        score: cache.nodeScores[centerId] || 0,
                        centerWeight: Number.POSITIVE_INFINITY
                    };

                    Object.keys(cache.edgeWeights).forEach(function (key) {
                        var idsPair = key.split('|');
                        var source = idsPair[0];
                        var target = idsPair[1];
                        var neighborId = '';
                        var neighborNode;
                        var neighborScore;
                        var weight;

                        if (source === centerId) {
                            neighborId = target;
                        } else if (target === centerId) {
                            neighborId = source;
                        } else {
                            return;
                        }

                        neighborNode = nodeById[neighborId];
                        if (!neighborNode || !enabledKinds[neighborNode.kind]) {
                            return;
                        }

                        neighborScore = cache.nodeScores[neighborId] || 0;
                        if (neighborScore < 1) {
                            return;
                        }

                        weight = cache.edgeWeights[key] || 0;
                        selectedById[neighborId] = {
                            node: neighborNode,
                            score: neighborScore,
                            centerWeight: weight
                        };
                    });

                    selectedNodes = Object.keys(selectedById).map(function (id) {
                        return selectedById[id];
                    });

                    selectedNodes.sort(function (a, b) {
                        if (a.node.id === centerId) {
                            return -1;
                        }
                        if (b.node.id === centerId) {
                            return 1;
                        }
                        if ((b.centerWeight || 0) !== (a.centerWeight || 0)) {
                            return (b.centerWeight || 0) - (a.centerWeight || 0);
                        }
                        if (b.score !== a.score) {
                            return b.score - a.score;
                        }
                        return a.node.label.localeCompare(b.node.label, 'de');
                    });

                    selectedNodes = selectedNodes.slice(0, nodeLimit + 1);
                } else {
                    ['person', 'work'].forEach(function (kind) {
                        grouped[kind].sort(function (a, b) {
                            if (b.score !== a.score) {
                                return b.score - a.score;
                            }
                            return a.node.label.localeCompare(b.node.label, 'de');
                        });
                        grouped[kind].slice(0, nodeLimit).forEach(function (entry) {
                            selectedNodes.push(entry);
                        });
                    });
                }

                refreshSearchDatalist(enabledKinds, cache);

                if (centerId && !selectedNodes.some(function (entry) { return entry.node.id === centerId; })) {
                    centerId = '';
                }

                selectedNodes.sort(function (a, b) {
                    if (centerId) {
                        var aKey = pairKey(a.node.id, centerId);
                        var bKey = pairKey(b.node.id, centerId);
                        var aw = cache.edgeWeights[aKey] || 0;
                        var bw = cache.edgeWeights[bKey] || 0;
                        if (bw !== aw) {
                            return bw - aw;
                        }
                    }
                    if (b.score !== a.score) {
                        return b.score - a.score;
                    }
                    return a.node.label.localeCompare(b.node.label, 'de');
                });

                var ids = selectedNodes.map(function (entry) {
                    return entry.node.id;
                });
                var scoreValues = selectedNodes.map(function (entry) {
                    return entry.score;
                });
                var minScore = scoreValues.length ? Math.min.apply(null, scoreValues) : 0;
                var maxScore = scoreValues.length ? Math.max.apply(null, scoreValues) : 0;
                var visible = {};
                ids.forEach(function (id) {
                    visible[id] = true;
                });

                var positions = buildLayout(ids, centerId, host);

                selectedNodes.forEach(function (entry) {
                    var node = entry.node;
                    var pos = positions[node.id] || { x: 0, y: 0 };
                    var isCenter = node.id === centerId;
                    graph.addNode(node.id, {
                        x: pos.x,
                        y: pos.y,
                        size: nodeVisualSize(entry.score || 0, minScore, maxScore, isCenter),
                        color: isCenter ? NODE_COLORS.center : NODE_COLORS[node.kind],
                        label: node.label,
                        forceLabel: isCenter,
                        zIndex: isCenter ? 10 : 1,
                        kind: node.kind,
                        score: entry.score
                    });
                });

                Object.keys(cache.edgeWeights).forEach(function (key) {
                    var idsPair = key.split('|');
                    var source = idsPair[0];
                    var target = idsPair[1];
                    var weight = cache.edgeWeights[key];
                    var gradeWeight = gradeCache.edgeWeights[key] || 0;

                    if (weight < 1 || !visible[source] || !visible[target]) {
                        return;
                    }

                    var visuals = edgeVisuals(gradeWeight > 0 ? gradeWeight : weight);

                    graph.addEdgeWithKey('edge-' + source + '-' + target, source, target, {
                        size: visuals.size,
                        color: visuals.color,
                        weight: weight,
                        gradeWeight: gradeWeight
                    });
                });

                renderer.setGraph(graph);
                renderer.refresh();

                if (centerId && nodeById[centerId]) {
                    var centerNode = nodeById[centerId];
                    updateDetails(
                        centerId,
                        cache.nodeScores[centerId] || 0,
                        mode,
                        centerNode.chapterKeys.length,
                        centerNode.paragraphKeys.length
                    );
                    syncSearchInputWithCenter();
                } else {
                    updateDetails('', 0, mode, 0, 0);
                }
            }

            renderer.on('clickNode', function (event) {
                centerId = event.node;
                renderGraph();
            });

            renderer.on('clickStage', function () {
                centerId = '';
                renderGraph();
            });

            relationModeInput.addEventListener('change', renderGraph);
            kindToggles.forEach(function (toggle) {
                toggle.addEventListener('change', renderGraph);
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

            window.addEventListener('resize', renderGraph);

            renderGraph();
        }).catch(function () {
            if (detailBox) {
                detailBox.textContent = 'Failed to load VMS network data.';
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize);
    } else {
        initialize();
    }
})();
