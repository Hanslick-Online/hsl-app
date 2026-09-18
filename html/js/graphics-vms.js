(() => {
  const MAX_ENTITIES = 5;
  const COLORS = ["#0b6e4f", "#c84c09", "#22577a", "#a4243b", "#5f0f40"];
  const SEARCH_PAGE = "search.html";
  const SEARCH_EDITION = "Treatise/Traktat";
  const ENTITY_TYPES = { person: "Person", work: "Werk", place: "Ort" };
  const REFINEMENT_KEYS = { person: "persons", work: "works", place: "places" };

  const state = {
    chart: null,
    chapters: [],
    entities: new Map(),
    editionMap: new Map(),
    mode: "year",
    optionMap: new Map(),
    selectedSeries: [],
    years: [],
    tooltipHovered: false,
    tooltipHideTimer: null,
  };

  function collectElements() {
    const dataRoot = document.getElementById("graphics-data");
    const canvas = document.getElementById("graphics-chart");
    const personInput = document.getElementById("graphics-person-input");
    const personButton = document.getElementById("graphics-add-person");
    const personDatalist = document.getElementById("graphics-person-options");
    const workInput = document.getElementById("graphics-work-input");
    const workButton = document.getElementById("graphics-add-work");
    const workDatalist = document.getElementById("graphics-work-options");
    const placeInput = document.getElementById("graphics-place-input");
    const placeButton = document.getElementById("graphics-add-place");
    const placeDatalist = document.getElementById("graphics-place-options");
    const selected = document.getElementById("graphics-selected-entities");
    const status = document.getElementById("graphics-status");
    const viewToggle = document.getElementById("graphics-view-toggle");
    const editionSelect = document.getElementById("graphics-edition-select");
    const editionWrap = document.getElementById("graphics-edition-wrap");

    if (!dataRoot || !canvas || !selected || !status || !viewToggle || !editionSelect || !editionWrap) {
      return null;
    }

    return {
      dataRoot,
      canvas,
      selected,
      status,
      viewToggle,
      editionSelect,
      editionWrap,
      person: { input: personInput, button: personButton, datalist: personDatalist },
      work: { input: workInput, button: workButton, datalist: workDatalist },
      place: { input: placeInput, button: placeButton, datalist: placeDatalist },
    };
  }

  function setStatus(elements, message, tone = "muted") {
    elements.status.textContent = message;
    elements.status.className = `graphics-status mt-3 small text-${tone}`;
  }

  function getMode(elements) {
    const mode = elements.viewToggle.dataset.mode;
    return mode === "chapter" ? "chapter" : "year";
  }

  function isChapterMode(elements) {
    return getMode(elements) === "chapter";
  }

  function syncModeButton(elements) {
    if (state.mode === "chapter") {
      elements.viewToggle.dataset.mode = "chapter";
      elements.viewToggle.textContent = "Auflagenansicht";
      elements.viewToggle.setAttribute("title", "Zu Visualisierung 1 wechseln");
    } else {
      elements.viewToggle.dataset.mode = "year";
      elements.viewToggle.textContent = "Kapitelansicht";
      elements.viewToggle.setAttribute("title", "Zu Visualisierung 2 wechseln");
    }
  }

  function ensureLegendContainer(elements) {
    let root = document.getElementById("graphics-legend");
    if (!root) {
      root = document.createElement("div");
      root.id = "graphics-legend";
      root.className = "graphics-legend-list mt-3";
      elements.canvas.parentElement?.insertAdjacentElement("afterend", root);
    }
    return root;
  }

  function renderLegend(elements, datasets) {
    const root = ensureLegendContainer(elements);
    root.innerHTML = "";

    if (!datasets.length) {
      return;
    }

    const list = document.createElement("ul");
    list.className = "graphics-legend-items";

    datasets.forEach((dataset) => {
      const item = document.createElement("li");
      item.className = "graphics-legend-item";

      const swatch = document.createElement("span");
      swatch.className = "graphics-legend-swatch";
      swatch.style.backgroundColor = dataset.borderColor;

      const link = document.createElement("a");
      link.className = "graphics-legend-link";
      link.href = `${dataset.entityId}.html`;
      link.textContent = dataset.label;

      item.appendChild(swatch);
      item.appendChild(link);
      list.appendChild(item);
    });

    root.appendChild(list);
  }

  async function fetchData(source) {
    const response = await fetch(source);
    if (!response.ok) {
      throw new Error(`Failed to load: ${response.status}`);
    }
    return response.json();
  }

  function appendOption(datalist, entity) {
    if (!datalist) {
      return;
    }

    const option = document.createElement("option");
    option.value = `${entity.label} (${entity.type}, ${entity.id})`;
    datalist.appendChild(option);

    state.optionMap.set(option.value, {
      id: entity.id,
      label: entity.label,
    });
  }

  function parseEntity(raw) {
    const years = new Map();

    Object.entries(raw.years || {}).forEach(([year, values]) => {
      const edition = String(values.edition || "").trim();
      const total = Number(values.total || 0);
      const chapterCounts = {};
      state.chapters.forEach((chapter) => {
        chapterCounts[chapter] = Number(values[chapter] || 0);
      });

      years.set(year, { edition, total, chapterCounts });

      const editionKey = `${year}::${edition}`;
      if (!state.editionMap.has(editionKey)) {
        state.editionMap.set(editionKey, {
          key: editionKey,
          year,
          edition,
          label: edition ? `${edition} (${year})` : year,
        });
      }
    });

    return {
      id: raw.id,
      kind: raw.kind,
      type: ENTITY_TYPES[raw.kind] || "Ort",
      label: raw.label,
      years,
    };
  }

  function applyData(elements, payload) {
    state.chapters = Array.isArray(payload.chapters) ? payload.chapters : [];
    state.entities.clear();
    state.editionMap.clear();
    state.optionMap.clear();

    [elements.person.datalist, elements.work.datalist, elements.place.datalist].forEach((d) => {
      if (d) {
        d.innerHTML = "";
      }
    });

    const datalistByKind = {
      person: elements.person.datalist,
      work: elements.work.datalist,
      place: elements.place.datalist,
    };

    (payload.entities || []).forEach((raw) => {
      if (!raw.id || !raw.kind || !raw.label) {
        return;
      }
      const entity = parseEntity(raw);
      state.entities.set(entity.id, entity);
      appendOption(datalistByKind[entity.kind], entity);
    });

    state.years = Array.from(
      new Set(
        Array.from(state.entities.values()).flatMap((entity) => Array.from(entity.years.keys()))
      )
    )
      .map((year) => Number(year))
      .filter((year) => Number.isFinite(year))
      .sort((a, b) => a - b);

    const editions = Array.from(state.editionMap.values()).sort((a, b) => Number(a.year) - Number(b.year));
    elements.editionSelect.innerHTML = "";
    editions.forEach((edition) => {
      const option = document.createElement("option");
      option.value = edition.key;
      option.textContent = edition.label;
      elements.editionSelect.appendChild(option);
    });
  }

  function renderSelected(elements) {
    elements.selected.innerHTML = "";
    state.selectedSeries.forEach((series) => {
      const entity = state.entities.get(series.entityId);
      if (!entity) {
        return;
      }

      const pill = document.createElement("span");
      pill.className = "graphics-selected-item";

      const label = document.createElement("span");
      const edition = state.editionMap.get(series.editionKey);
      label.textContent = series.editionKey
        ? `${entity.label} [${entity.type}] - ${edition ? edition.label : series.editionKey}`
        : `${entity.label} [${entity.type}]`;

      const remove = document.createElement("button");
      remove.type = "button";
      remove.dataset.seriesKey = series.key;
      remove.textContent = "×";

      pill.appendChild(label);
      pill.appendChild(remove);
      elements.selected.appendChild(pill);
    });
  }

  function createChart(elements) {
    const context = elements.canvas.getContext("2d");
    state.chart = new Chart(context, {
      type: "line",
      data: { labels: [], datasets: [] },
      options: {
        animation: false,
        maintainAspectRatio: false,
        responsive: true,
        scales: {
          x: {
            type: "linear",
            title: { display: true, text: "Jahr" },
            ticks: { precision: 0 },
          },
          y: {
            beginAtZero: true,
            title: { display: true, text: "Häufigkeit" },
            ticks: { precision: 0 },
          },
        },
        plugins: {
          legend: { display: false },
          tooltip: {
            enabled: false,
            external: (tooltipContext) => renderExternalTooltip(elements, tooltipContext),
          },
        },
      },
    });
  }

  function getRefinementKey(kind) {
    return REFINEMENT_KEYS[kind] || REFINEMENT_KEYS.place;
  }

  function buildQueryTerm(entity) {
    const label = String(entity?.label || "").trim();
    if (!label) {
      return "";
    }

    if (entity.kind === "person") {
      const parts = label.split(/\s+/).filter(Boolean);
      if (parts.length) {
        return parts[parts.length - 1].toLowerCase();
      }
    }

    return label.toLowerCase();
  }

  function romanToInt(value) {
    const token = String(value || "").trim().toUpperCase();
    if (!token) {
      return null;
    }

    const map = { I: 1, V: 5, X: 10, L: 50, C: 100, D: 500, M: 1000 };
    let total = 0;
    let prev = 0;

    for (let i = token.length - 1; i >= 0; i -= 1) {
      const current = map[token[i]];
      if (!current) {
        return null;
      }
      if (current < prev) {
        total -= current;
      } else {
        total += current;
      }
      prev = current;
    }

    return total > 0 ? total : null;
  }

  function buildChapterTerm(chapterLabel) {
    const label = String(chapterLabel || "").trim();
    if (!label) {
      return "";
    }

    if (label.toLowerCase() === "vorwort") {
      return "vorwort";
    }

    const number = romanToInt(label);
    if (number) {
      return `kapitel ${number}`;
    }

    return `kapitel ${label.toLowerCase()}`;
  }

  // Search links always constrain the entity and edition; chapter mode adds its heading term.
  function buildSearchHref(entity, details) {
    const { year, chapterLabel, isChapterMode } = details;
    const params = new URLSearchParams();
    const entityQuery = buildQueryTerm(entity);
    const chapterQuery = isChapterMode ? buildChapterTerm(chapterLabel) : "";
    const query = [entityQuery, chapterQuery].filter(Boolean).join(" ");
    if (query) {
      params.set("hsl[query]", query);
    }
    params.set("hsl[menu][edition]", SEARCH_EDITION);
    params.set(`hsl[refinementList][${getRefinementKey(entity.kind)}][0]`, entity.label);

    const yearNumber = Number(year);
    if (Number.isFinite(yearNumber)) {
      params.set("hsl[range][year]", `${yearNumber}:${yearNumber}`);
    }

    return `${SEARCH_PAGE}?${params.toString()}`;
  }

  function clearTooltipHideTimer() {
    if (state.tooltipHideTimer) {
      window.clearTimeout(state.tooltipHideTimer);
      state.tooltipHideTimer = null;
    }
  }

  function getOrCreateTooltipElement(elements) {
    const parent = elements.canvas.parentElement;
    if (!parent) {
      return null;
    }

    let tooltip = parent.querySelector(".graphics-chart-tooltip");
    if (!tooltip) {
      tooltip = document.createElement("div");
      tooltip.className = "graphics-chart-tooltip";
      tooltip.addEventListener("mouseenter", () => {
        state.tooltipHovered = true;
        clearTooltipHideTimer();
      });
      tooltip.addEventListener("mouseleave", () => {
        state.tooltipHovered = false;
        tooltip.style.opacity = "0";
      });
      parent.appendChild(tooltip);
    }

    return tooltip;
  }

  function renderExternalTooltip(elements, context) {
    const tooltip = getOrCreateTooltipElement(elements);
    if (!tooltip) {
      return;
    }

    const model = context.tooltip;
    if (!model || model.opacity === 0 || !model.dataPoints || !model.dataPoints.length) {
      if (state.tooltipHovered) {
        return;
      }

      // Keep tooltip alive for a moment so users can move from point to link.
      clearTooltipHideTimer();
      state.tooltipHideTimer = window.setTimeout(() => {
        state.tooltipHideTimer = null;
        if (!state.tooltipHovered) {
          tooltip.style.opacity = "0";
        }
      }, 250);
      return;
    }

    clearTooltipHideTimer();

    const point = model.dataPoints[0];
    const entity = state.entities.get(point.dataset.entityId);
    if (!entity) {
      tooltip.style.opacity = "0";
      return;
    }

    const isChapter = state.mode === "chapter";
    const year = isChapter ? Number(point.dataset._year) : Number(point.parsed.x);
    const axisLabel = isChapter ? state.chapters[point.dataIndex] || "" : String(point.parsed.x);
    const value = Number.isFinite(point.parsed.y) ? point.parsed.y : 0;
    const searchHref = buildSearchHref(entity, {
      year,
      chapterLabel: isChapter ? axisLabel : "",
      isChapterMode: isChapter,
    });

    tooltip.innerHTML = "";

    const title = document.createElement("div");
    title.className = "graphics-chart-tooltip__title";
    title.textContent = `${entity.label} [${entity.type}]`;

    const meta = document.createElement("div");
    meta.className = "graphics-chart-tooltip__meta";
    meta.textContent = isChapter ? `${point.dataset._editionLabel} - Kapitel ${axisLabel}: ${value}` : `Jahr ${axisLabel}: ${value}`;

    const link = document.createElement("a");
    link.className = "graphics-chart-tooltip__link";
    link.href = searchHref;
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    link.textContent = "Treffer dieser Auflage suchen";

    tooltip.appendChild(title);
    tooltip.appendChild(meta);
    tooltip.appendChild(link);

    const { offsetLeft, offsetTop } = context.chart.canvas;
    tooltip.style.opacity = "1";
    tooltip.style.left = `${offsetLeft + model.caretX + 14}px`;
    tooltip.style.top = `${offsetTop + model.caretY + 14}px`;
  }

  function buildYearDataset(entity, color) {
    const data = state.years.map((year) => {
      const values = entity.years.get(String(year));
      return { x: year, y: values ? values.total : 0 };
    });

    return buildDataset(entity, color, data, {
      label: `${entity.label} [${entity.type}]`,
    });
  }

  function buildDataset(entity, color, data, extra) {
    return {
      entityId: entity.id,
      borderColor: color,
      backgroundColor: color,
      pointBackgroundColor: color,
      borderWidth: 2,
      pointRadius: 4,
      pointHoverRadius: 6,
      tension: 0.2,
      data,
      ...extra,
    };
  }

  function buildChapterDataset(entity, editionKey, color) {
    const [year, edition] = editionKey.split("::");
    const values = entity.years.get(year);
    const chapterData = state.chapters.map((chapter) => (values && values.chapterCounts ? values.chapterCounts[chapter] || 0 : 0));

    return buildDataset(entity, color, chapterData, {
      label: `${entity.label} [${entity.type}] - ${edition ? `${edition} (${year})` : year}`,
      _year: Number(year),
      _editionLabel: edition ? `${edition} (${year})` : year,
    });
  }

  function updateChart(elements) {
    if (!state.chart) {
      createChart(elements);
    }

    if (!state.selectedSeries.length) {
      state.chart.data.datasets = [];
      state.chart.update();
      renderLegend(elements, []);
      setStatus(elements, "Wählen Sie mindestens einen Eintrag aus, um das Diagramm anzuzeigen.");
      return;
    }

    const mode = state.mode;

    if (mode === "chapter") {
      const datasets = state.selectedSeries
        .map((series, index) => {
          const entity = state.entities.get(series.entityId);
          if (!entity || !series.editionKey) {
            return null;
          }
          return buildChapterDataset(entity, series.editionKey, COLORS[index % COLORS.length]);
        })
        .filter(Boolean);

      state.chart.data.labels = state.chapters;
      state.chart.data.datasets = datasets;
      state.chart.options.scales.x = {
        type: "category",
        title: { display: true, text: "Kapitel" },
      };
      state.chart.options.scales.y = {
        beginAtZero: true,
        title: { display: true, text: "Häufigkeit" },
        ticks: { precision: 0 },
      };
      state.chart.update();
      renderLegend(elements, datasets);
      setStatus(elements, `Zeige ${datasets.length} Einträge nach Kapitel.`);
      return;
    }

    const uniqueEntityIds = [];
    const seenEntityIds = new Set();
    state.selectedSeries.forEach((series) => {
      if (!seenEntityIds.has(series.entityId)) {
        seenEntityIds.add(series.entityId);
        uniqueEntityIds.push(series.entityId);
      }
    });

    const datasets = uniqueEntityIds
      .map((entityId, index) => {
        const entity = state.entities.get(entityId);
        if (!entity) {
          return null;
        }
        const dataset = buildYearDataset(entity, COLORS[index % COLORS.length]);
        dataset.label = `${entity.label} [${entity.type}]`;
        return dataset;
      })
      .filter(Boolean);

    state.chart.data.labels = [];
    state.chart.data.datasets = datasets;
    state.chart.options.scales.x = {
      type: "linear",
      title: { display: true, text: "Jahr" },
      ticks: { precision: 0 },
    };
    state.chart.options.scales.y = {
      beginAtZero: true,
      title: { display: true, text: "Häufigkeit" },
      ticks: { precision: 0 },
    };
    state.chart.update();
    renderLegend(elements, datasets);
    setStatus(elements, `Zeige ${datasets.length} Einträge nach Jahr.`);
  }

  function addEntity(elements, input) {
    const value = input.value.trim();
    const option = state.optionMap.get(value);
    const chapterMode = isChapterMode(elements);
    const editionKey = elements.editionSelect.value;

    if (!option) {
      setStatus(elements, "Wählen Sie vor dem Hinzufügen einen Eintrag aus der Vorschlagsliste aus.", "danger");
      return;
    }

    if (chapterMode && !editionKey) {
      setStatus(elements, "Wählen Sie eine Auflage aus, bevor Sie hinzufügen.", "warning");
      return;
    }

    const seriesKey = chapterMode ? `${option.id}::${editionKey}` : option.id;
    if (state.selectedSeries.some((series) => series.key === seriesKey)) {
      setStatus(elements, `${option.label} ist in dieser Kombination bereits ausgewählt.`, "warning");
      input.value = "";
      return;
    }

    if (!chapterMode && state.selectedSeries.some((series) => series.entityId === option.id)) {
      setStatus(elements, `${option.label} ist bereits ausgewählt.`, "warning");
      input.value = "";
      return;
    }

    if (state.selectedSeries.length >= MAX_ENTITIES) {
      setStatus(elements, `Sie können bis zu ${MAX_ENTITIES} Einträge gleichzeitig vergleichen.`, "warning");
      return;
    }

    state.selectedSeries.push({
      key: seriesKey,
      entityId: option.id,
      editionKey: chapterMode ? editionKey : null,
    });

    input.value = "";
    renderSelected(elements);
    updateChart(elements);
  }

  async function init() {
    const elements = collectElements();
    if (!elements || !window.Chart) {
      return;
    }

    setStatus(elements, "Lade Diagrammdaten…");

    const source = elements.dataRoot.dataset.source || "data/graphics-chart-traktat-entities.json";
    const payload = await fetchData(source);

    applyData(elements, payload);
    renderSelected(elements);

    [elements.person, elements.work, elements.place].forEach((group) => {
      if (!group.input || !group.button) {
        return;
      }

      group.button.addEventListener("click", () => addEntity(elements, group.input));
      group.input.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
          event.preventDefault();
          addEntity(elements, group.input);
        }
      });
    });

    elements.selected.addEventListener("click", (event) => {
      const button = event.target.closest("button[data-series-key]");
      if (!button) {
        return;
      }

      state.selectedSeries = state.selectedSeries.filter((series) => series.key !== button.dataset.seriesKey);
      renderSelected(elements);
      updateChart(elements);
    });

    elements.viewToggle.addEventListener("click", () => {
      state.mode = state.mode === "year" ? "chapter" : "year";
      syncModeButton(elements);
      const isChapter = isChapterMode(elements);
      elements.editionWrap.classList.toggle("d-none", !isChapter);
      updateChart(elements);
    });

    elements.editionSelect.addEventListener("change", () => {
      if (isChapterMode(elements)) {
        updateChart(elements);
      }
    });

    syncModeButton(elements);
    elements.editionWrap.classList.add("d-none");
    updateChart(elements);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();
