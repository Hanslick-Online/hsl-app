(() => {
  const MAX_ENTITIES = 5;
  const COLORS = ["#0b6e4f", "#c84c09", "#22577a", "#a4243b", "#5f0f40"];

  const CORPUS_KEYS = ["traktat", "critics", "vms", "documents"];
  const DEFAULT_I18N = {
    axisFrequency: "Frequency",
    axisYear: "Year",
    corpusLabels: {
      traktat: "Traktat",
      critics: "Critics (NFP)",
      vms: "VMS Reviews",
      documents: "Documents",
    },
    errorDuplicate: "{label} is already selected.",
    errorInvalidEntity: "Choose an entity from the suggestion list before adding it.",
    errorMax: "You can compare up to {max} entities at once.",
    removeAriaLabel: "Remove {label}",
    statusLoadError: "Chart data could not be loaded.",
    statusLoading: "Loading chart data...",
    statusEmpty: "Select at least one entity to draw the chart.",
    statusFilteredPlural: "Showing {count} entities for {corpora}.",
    statusFilteredSingular: "Showing {count} entity for {corpora}.",
    statusNoCorpora: "Enable at least one corpus or switch Total back on.",
    statusTotalPlural: "Showing {count} entities across all corpora together.",
    statusTotalSingular: "Showing {count} entity across all corpora together.",
    typeLabels: {
      person: "Person",
      place: "Place",
      work: "Work",
    },
    tooltipYear: "Year {year}",
  };

  const state = {
    chart: null,
    entityCache: new Map(),
    i18n: DEFAULT_I18N,
    optionMap: new Map(),
    selectedIds: [],
    years: [],
    zoomPlugin: null,
  };

  function formatMessage(template, values = {}) {
    return template.replace(/\{(\w+)\}/g, (_, key) => `${values[key] ?? ""}`);
  }

  function getZoomPlugin() {
    const candidates = [
      window.ChartZoom,
      window.chartjsPluginZoom,
      window["chartjs-plugin-zoom"],
      window.ChartZoom && window.ChartZoom.default,
      window.chartjsPluginZoom && window.chartjsPluginZoom.default,
      window["chartjs-plugin-zoom"] && window["chartjs-plugin-zoom"].default,
    ];

    return candidates.find((candidate) => candidate && typeof candidate === "object") || null;
  }

  function resetChartZoom() {
    if (!state.chart) {
      return;
    }

    if (typeof state.chart.resetZoom === "function") {
      state.chart.resetZoom();
      return;
    }

    if (state.zoomPlugin && typeof state.zoomPlugin.resetZoom === "function") {
      state.zoomPlugin.resetZoom(state.chart);
      return;
    }

    // Fallback when plugin APIs are unavailable: restore the full x-axis range.
    const xScale = state.chart.options?.scales?.x;
    if (xScale) {
      delete xScale.min;
      delete xScale.max;
      state.chart.update();
    }
  }

  function installDragZoom(elements) {
    const canvas = elements.canvas;
    const shell = canvas.parentElement;

    if (!shell || canvas.dataset.dragZoomBound === "true") {
      return;
    }

    canvas.dataset.dragZoomBound = "true";

    let overlay = shell.querySelector(".graphics-zoom-selection");
    if (!overlay) {
      overlay = document.createElement("div");
      overlay.className = "graphics-zoom-selection";
      shell.appendChild(overlay);
    }

    let dragging = false;
    let startX = 0;
    let currentX = 0;

    const MIN_DRAG_PIXELS = 8;

    const getRelativeX = (event) => {
      const rect = canvas.getBoundingClientRect();
      const x = event.clientX - rect.left;
      return Math.max(0, Math.min(rect.width, x));
    };

    const updateOverlay = () => {
      const left = Math.min(startX, currentX);
      const width = Math.abs(currentX - startX);
      overlay.style.left = `${left}px`;
      overlay.style.width = `${width}px`;
      overlay.style.display = "block";
    };

    const clearOverlay = () => {
      overlay.style.display = "none";
      overlay.style.width = "0";
    };

    canvas.addEventListener("mousedown", (event) => {
      if (event.button !== 0 || !state.chart) {
        return;
      }

      dragging = true;
      startX = getRelativeX(event);
      currentX = startX;
      updateOverlay();
      event.preventDefault();
    });

    window.addEventListener("mousemove", (event) => {
      if (!dragging) {
        return;
      }

      currentX = getRelativeX(event);
      updateOverlay();
    });

    window.addEventListener("mouseup", (event) => {
      if (!dragging) {
        return;
      }

      dragging = false;
      currentX = getRelativeX(event);
      const draggedPixels = Math.abs(currentX - startX);
      clearOverlay();

      if (draggedPixels < MIN_DRAG_PIXELS || !state.chart) {
        return;
      }

      const xScale = state.chart.scales?.x;
      if (!xScale || typeof xScale.getValueForPixel !== "function") {
        return;
      }

      const valueA = Number(xScale.getValueForPixel(startX));
      const valueB = Number(xScale.getValueForPixel(currentX));

      if (!Number.isFinite(valueA) || !Number.isFinite(valueB) || valueA === valueB) {
        return;
      }

      const fullMin = state.years[0];
      const fullMax = state.years[state.years.length - 1];
      if (!Number.isFinite(fullMin) || !Number.isFinite(fullMax)) {
        return;
      }

      const targetMin = Math.max(fullMin, Math.floor(Math.min(valueA, valueB)));
      const targetMax = Math.min(fullMax, Math.ceil(Math.max(valueA, valueB)));

      if (targetMax <= targetMin) {
        return;
      }

      const xOptions = state.chart.options?.scales?.x;
      if (!xOptions) {
        return;
      }

      xOptions.min = targetMin;
      xOptions.max = targetMax;
      state.chart.update("none");
    });
  }

  function collectI18n(dataRoot) {
    return {
      axisFrequency: dataRoot.dataset.axisFrequency || DEFAULT_I18N.axisFrequency,
      axisYear: dataRoot.dataset.axisYear || DEFAULT_I18N.axisYear,
      corpusLabels: {
        traktat: dataRoot.dataset.labelTraktat || DEFAULT_I18N.corpusLabels.traktat,
        critics: dataRoot.dataset.labelCritics || DEFAULT_I18N.corpusLabels.critics,
        vms: dataRoot.dataset.labelVms || DEFAULT_I18N.corpusLabels.vms,
        documents: dataRoot.dataset.labelDocuments || DEFAULT_I18N.corpusLabels.documents,
      },
      errorDuplicate: dataRoot.dataset.errorDuplicate || DEFAULT_I18N.errorDuplicate,
      errorInvalidEntity: dataRoot.dataset.errorInvalidEntity || DEFAULT_I18N.errorInvalidEntity,
      errorMax: dataRoot.dataset.errorMax || DEFAULT_I18N.errorMax,
      removeAriaLabel: dataRoot.dataset.removeAriaLabel || DEFAULT_I18N.removeAriaLabel,
      statusLoadError: dataRoot.dataset.statusLoadError || DEFAULT_I18N.statusLoadError,
      statusLoading: dataRoot.dataset.statusLoading || DEFAULT_I18N.statusLoading,
      statusEmpty: dataRoot.dataset.statusEmpty || DEFAULT_I18N.statusEmpty,
      statusFilteredPlural: dataRoot.dataset.statusFilteredPlural || DEFAULT_I18N.statusFilteredPlural,
      statusFilteredSingular: dataRoot.dataset.statusFilteredSingular || DEFAULT_I18N.statusFilteredSingular,
      statusNoCorpora: dataRoot.dataset.statusNoCorpora || DEFAULT_I18N.statusNoCorpora,
      statusTotalPlural: dataRoot.dataset.statusTotalPlural || DEFAULT_I18N.statusTotalPlural,
      statusTotalSingular: dataRoot.dataset.statusTotalSingular || DEFAULT_I18N.statusTotalSingular,
      typeLabels: {
        person: dataRoot.dataset.typePerson || DEFAULT_I18N.typeLabels.person,
        place: dataRoot.dataset.typePlace || DEFAULT_I18N.typeLabels.place,
        work: dataRoot.dataset.typeWork || DEFAULT_I18N.typeLabels.work,
      },
      tooltipYear: dataRoot.dataset.tooltipYear || DEFAULT_I18N.tooltipYear,
    };
  }

  function setStatus(elements, message, tone = "muted") {
    elements.status.textContent = message;
    elements.status.className = `graphics-status mt-3 small text-${tone}`;
  }

  function collectElements() {
    const dataRoot = document.getElementById("graphics-data");
    const canvas = document.getElementById("graphics-chart");
    const selected = document.getElementById("graphics-selected-entities");
    const totalCheckbox = document.getElementById("graphics-corpus-total");
    const corpusCheckboxes = Array.from(document.querySelectorAll(".graphics-corpus-checkbox"));
    const status = document.getElementById("graphics-status");

    // Collect entity-specific inputs (persons, works, places)
    const personInput = document.getElementById("graphics-person-input");
    const personButton = document.getElementById("graphics-add-person");
    const personDatalist = document.getElementById("graphics-person-options");

    const workInput = document.getElementById("graphics-work-input");
    const workButton = document.getElementById("graphics-add-work");
    const workDatalist = document.getElementById("graphics-work-options");

    const placeInput = document.getElementById("graphics-place-input");
    const placeButton = document.getElementById("graphics-add-place");
    const placeDatalist = document.getElementById("graphics-place-options");

    if (!dataRoot || !canvas || !selected || !totalCheckbox || !status) {
      return null;
    }

    return {
      canvas,
      corpusCheckboxes,
      dataRoot,
      person: { input: personInput, button: personButton, datalist: personDatalist },
      work: { input: workInput, button: workButton, datalist: workDatalist },
      place: { input: placeInput, button: placeButton, datalist: placeDatalist },
      selected,
      status,
      totalCheckbox,
    };
  }

  function buildYears(minYear, maxYear) {
    const years = [];

    for (let year = minYear; year <= maxYear; year += 1) {
      years.push(year);
    }

    return years;
  }

  function fetchChartData(source) {
    return fetch(source).then((response) => {
      if (!response.ok) {
        throw new Error(`Failed to load chart JSON: ${response.status}`);
      }

      return response.json();
    });
  }

  function entityTypeLabel(kind) {
    return state.i18n.typeLabels[kind] || kind;
  }

  function appendOption(datalist, entity) {
    if (!datalist) {
      return;
    }

    const option = document.createElement("option");
    option.dataset.entityId = entity.id;
    option.dataset.displayLabel = entity.label;
    option.dataset.entityKind = entity.kind;
    option.dataset.entityType = entity.type;
    option.value = `${entity.label} (${entity.type}, ${entity.id})`;
    option.textContent = entity.label;
    datalist.appendChild(option);

    state.optionMap.set(option.value, {
      id: entity.id,
      label: entity.label,
      type: entity.type,
    });
  }

  function applyChartData(elements, payload) {
    const entities = Array.isArray(payload.entities) ? payload.entities : [];
    const datalists = {
      person: elements.person.datalist,
      place: elements.place.datalist,
      work: elements.work.datalist,
    };

    state.entityCache.clear();
    state.optionMap.clear();
    Object.values(datalists).forEach((datalist) => {
      if (datalist) {
        datalist.innerHTML = "";
      }
    });

    entities.forEach((rawEntity) => {
      const kind = rawEntity.kind;
      const id = rawEntity.id;
      const label = rawEntity.label;
      if (!id || !kind || !label) {
        return;
      }

      const years = new Map();
      const yearlyCounts = rawEntity.years || {};
      Object.keys(yearlyCounts).forEach((yearKey) => {
        const year = Number(yearKey);
        const counts = yearlyCounts[yearKey] || {};
        years.set(year, {
          traktat: Number(counts.traktat || 0),
          critics: Number(counts.critics || 0),
          vms: Number(counts.vms || 0),
          documents: Number(counts.documents || 0),
        });
      });

      const entity = {
        id,
        kind,
        label,
        type: entityTypeLabel(kind),
        years,
      };

      state.entityCache.set(id, entity);
      appendOption(datalists[kind], entity);
    });

    const minYear = Number(payload.min_year || 0);
    const maxYear = Number(payload.max_year || 0);
    state.years = minYear && maxYear && maxYear >= minYear ? buildYears(minYear, maxYear) : [];
  }

  function getEntity(id) {
    return state.entityCache.get(id) || null;
  }

  function syncCorpusControls(elements) {
    const totalEnabled = elements.totalCheckbox.checked;
    elements.corpusCheckboxes.forEach((checkbox) => {
      checkbox.disabled = totalEnabled;
    });
  }

  function getActiveCorpora(elements) {
    if (elements.totalCheckbox.checked) {
      return CORPUS_KEYS.slice();
    }

    return elements.corpusCheckboxes
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.dataset.corpus);
  }

  function renderSelectedEntities(elements) {
    elements.selected.innerHTML = "";

    state.selectedIds.forEach((id) => {
      const entity = getEntity(id);
      if (!entity) {
        return;
      }

      const pill = document.createElement("span");
      pill.className = "graphics-selected-item";
      pill.dataset.entityId = id;

      const label = document.createElement("span");
      label.textContent = `${entity.label} [${entity.type}]`;

      const remove = document.createElement("button");
      remove.type = "button";
      remove.dataset.entityId = id;
      remove.setAttribute("aria-label", formatMessage(state.i18n.removeAriaLabel, { label: entity.label }));
      remove.textContent = "×";

      pill.appendChild(label);
      pill.appendChild(remove);
      elements.selected.appendChild(pill);
    });
  }

  function ensureLegendContainer(elements) {
    let legendRoot = document.getElementById("graphics-legend");
    if (legendRoot) {
      return legendRoot;
    }

    // Create a runtime legend container so link-based legend works even on older generated pages.
    legendRoot = document.createElement("div");
    legendRoot.id = "graphics-legend";
    legendRoot.className = "graphics-legend-list mt-3";
    elements.canvas.parentElement?.insertAdjacentElement("afterend", legendRoot);
    return legendRoot;
  }

  function renderLegend(elements, datasets) {
    const legendRoot = ensureLegendContainer(elements);

    legendRoot.innerHTML = "";

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

    legendRoot.appendChild(list);
  }

  function createChart(elements) {
    const context = elements.canvas.getContext("2d");
    ensureLegendContainer(elements);
    state.chart = new Chart(context, {
      type: "line",
      data: {
        datasets: [],
      },
      options: {
        animation: false,
        interaction: {
          intersect: true,
          mode: "nearest",
        },
        maintainAspectRatio: false,
        parsing: false,
        plugins: {
          legend: {
            display: false,
            position: "bottom",
          },
          zoom: {
            pan: {
              enabled: false,
              mode: "x",
            },
            zoom: {
              drag: {
                enabled: true,
                backgroundColor: "rgba(34, 87, 122, 0.18)",
                borderColor: "rgba(34, 87, 122, 0.9)",
                borderWidth: 1,
              },
              wheel: { enabled: false },
              pinch: { enabled: false },
              mode: "x",
            },
          },
          tooltip: {
            callbacks: {
              title(items) {
                if (!items.length) {
                  return "";
                }
                return formatMessage(state.i18n.tooltipYear, { year: items[0].raw.x });
              },
              label(context) {
                return `${context.dataset.label}: ${context.raw.y}`;
              },
              afterLabel(context) {
                const activeCorpora = context.chart.$activeCorpora || CORPUS_KEYS;
                const breakdown = context.raw.corpora || {};
                return activeCorpora.map((corpus) => `  ${state.i18n.corpusLabels[corpus]}: ${breakdown[corpus] || 0}`);
              },
            },
          },
        },
        responsive: true,
        scales: {
          x: {
            ticks: {
              callback(value) {
                if (Number.isInteger(value)) {
                  return value;
                }

                return "";
              },
              precision: 0,
            },
            title: {
              display: true,
              text: state.i18n.axisYear,
            },
            type: "linear",
          },
          y: {
            beginAtZero: true,
            ticks: {
              precision: 0,
            },
            title: {
              display: true,
              text: state.i18n.axisFrequency,
            },
          },
        },
      },
    });
  }

  function buildDataset(entity, color, activeCorpora) {
    const data = state.years.map((year) => {
      const counts = entity.years.get(year) || {
        traktat: 0,
        critics: 0,
        vms: 0,
        documents: 0,
      };
      const total = activeCorpora.reduce((sum, corpus) => sum + (counts[corpus] || 0), 0);

      return {
        corpora: counts,
        x: year,
        y: total,
      };
    });

    return {
      borderColor: color,
      backgroundColor: color,
      borderWidth: 2,
      data,
      entityId: entity.id,
      label: `${entity.label} [${entity.type}]`,
      pointRadius: 4,
      pointHoverRadius: 6,
      pointBackgroundColor: color,
      tension: 0.2,
    };
  }

  function updateChart(elements) {
    syncCorpusControls(elements);

    if (!state.chart) {
      createChart(elements);
    }

    const activeCorpora = getActiveCorpora(elements);

    if (!state.selectedIds.length) {
      state.chart.data.datasets = [];
      state.chart.$activeCorpora = activeCorpora;
      state.chart.update();
      renderLegend(elements, []);
      setStatus(elements, state.i18n.statusEmpty);
      return;
    }

    if (!activeCorpora.length) {
      state.chart.data.datasets = [];
      state.chart.$activeCorpora = [];
      state.chart.update();
      renderLegend(elements, []);
      setStatus(elements, state.i18n.statusNoCorpora, "warning");
      return;
    }

    const datasets = state.selectedIds
      .map((id, index) => {
        const entity = getEntity(id);
        if (!entity) {
          return null;
        }

        return buildDataset(entity, COLORS[index % COLORS.length], activeCorpora);
      })
      .filter(Boolean);

    state.chart.data.datasets = datasets;
    state.chart.$activeCorpora = activeCorpora;
    state.chart.update();
    renderLegend(elements, datasets);

    if (elements.totalCheckbox.checked) {
      setStatus(
        elements,
        formatMessage(datasets.length === 1 ? state.i18n.statusTotalSingular : state.i18n.statusTotalPlural, {
          count: datasets.length,
        })
      );
      return;
    }

    const corpusLabels = activeCorpora.map((corpus) => state.i18n.corpusLabels[corpus]).join(", ");
    setStatus(
      elements,
      formatMessage(datasets.length === 1 ? state.i18n.statusFilteredSingular : state.i18n.statusFilteredPlural, {
        corpora: corpusLabels,
        count: datasets.length,
      })
    );
  }

  function addEntity(elements) {
    const value = elements.input.value.trim();
    const entry = state.optionMap.get(value);

    if (!entry) {
      setStatus(elements, state.i18n.errorInvalidEntity, "danger");
      return;
    }

    if (state.selectedIds.includes(entry.id)) {
      setStatus(elements, formatMessage(state.i18n.errorDuplicate, { label: entry.label }), "warning");
      elements.input.value = "";
      return;
    }

    if (state.selectedIds.length >= MAX_ENTITIES) {
      setStatus(elements, formatMessage(state.i18n.errorMax, { max: MAX_ENTITIES }), "warning");
      return;
    }

    state.selectedIds.push(entry.id);
    elements.input.value = "";
    renderSelectedEntities(elements);
    updateChart(elements);
  }

  function removeEntity(elements, id) {
    state.selectedIds = state.selectedIds.filter((entityId) => entityId !== id);
    renderSelectedEntities(elements);
    updateChart(elements);
  }

  async function init() {
    // Register the zoom plugin now that all scripts should be loaded
    if (window.Chart) {
      const zoomPlugin = getZoomPlugin();
      if (zoomPlugin && !window.Chart.__zoomRegistered) {
        try {
          window.Chart.register(zoomPlugin);
          window.Chart.__zoomRegistered = true;
        } catch (e) {
          console.warn("Failed to register zoom plugin:", e);
        }
      }

      if (zoomPlugin) {
        state.zoomPlugin = zoomPlugin;
      }
    }

    const elements = collectElements();
    if (!elements) {
      return;
    }

    state.i18n = collectI18n(elements.dataRoot);
    setStatus(elements, state.i18n.statusLoading);

    const source = elements.dataRoot.dataset.source || "data/graphics-chart-data.json";

    try {
      const payload = await fetchChartData(source);
      applyChartData(elements, payload);
    } catch (error) {
      console.error(error);
      setStatus(elements, state.i18n.statusLoadError, "danger");
      return;
    }

    syncCorpusControls(elements);
    updateChart(elements);
    installDragZoom(elements);

    // Helper function to add entity from a specific input
    const addEntityFromInput = (input) => {
      const value = input.value.trim();
      const entry = state.optionMap.get(value);

      if (!entry) {
        setStatus(elements, state.i18n.errorInvalidEntity, "danger");
        return;
      }

      if (state.selectedIds.includes(entry.id)) {
        setStatus(elements, formatMessage(state.i18n.errorDuplicate, { label: entry.label }), "warning");
        input.value = "";
        return;
      }

      if (state.selectedIds.length >= MAX_ENTITIES) {
        setStatus(elements, formatMessage(state.i18n.errorMax, { max: MAX_ENTITIES }), "warning");
        return;
      }

      state.selectedIds.push(entry.id);
      input.value = "";
      renderSelectedEntities(elements);
      updateChart(elements);
    };

    // Attach listeners to all three entity type inputs and buttons
    [elements.person, elements.work, elements.place].forEach((entityGroup) => {
      if (entityGroup.button && entityGroup.input) {
        entityGroup.button.addEventListener("click", () => addEntityFromInput(entityGroup.input));
        entityGroup.input.addEventListener("keydown", (event) => {
          if (event.key === "Enter") {
            event.preventDefault();
            addEntityFromInput(entityGroup.input);
          }
        });
      }
    });

    elements.selected.addEventListener("click", (event) => {
      const button = event.target.closest("button[data-entity-id]");
      if (!button) {
        return;
      }

      removeEntity(elements, button.dataset.entityId);
    });
    elements.totalCheckbox.addEventListener("change", () => updateChart(elements));
    elements.corpusCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => updateChart(elements));
    });

    const resetZoomButton = document.getElementById("graphics-reset-zoom");
    if (resetZoomButton) {
      resetZoomButton.addEventListener("click", () => {
        resetChartZoom();
      });
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();