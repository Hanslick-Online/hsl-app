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
    statusEmpty: "Select at least one entity to draw the chart.",
    statusFilteredPlural: "Showing {count} entities for {corpora}.",
    statusFilteredSingular: "Showing {count} entity for {corpora}.",
    statusNoCorpora: "Enable at least one corpus or switch Total back on.",
    statusTotalPlural: "Showing {count} entities across all corpora together.",
    statusTotalSingular: "Showing {count} entity across all corpora together.",
    tooltipYear: "Year {year}",
  };

  const state = {
    chart: null,
    entityCache: new Map(),
    entityNodes: new Map(),
    i18n: DEFAULT_I18N,
    optionMap: new Map(),
    selectedIds: [],
    years: [],
  };

  function formatMessage(template, values = {}) {
    return template.replace(/\{(\w+)\}/g, (_, key) => `${values[key] ?? ""}`);
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
      statusEmpty: dataRoot.dataset.statusEmpty || DEFAULT_I18N.statusEmpty,
      statusFilteredPlural: dataRoot.dataset.statusFilteredPlural || DEFAULT_I18N.statusFilteredPlural,
      statusFilteredSingular: dataRoot.dataset.statusFilteredSingular || DEFAULT_I18N.statusFilteredSingular,
      statusNoCorpora: dataRoot.dataset.statusNoCorpora || DEFAULT_I18N.statusNoCorpora,
      statusTotalPlural: dataRoot.dataset.statusTotalPlural || DEFAULT_I18N.statusTotalPlural,
      statusTotalSingular: dataRoot.dataset.statusTotalSingular || DEFAULT_I18N.statusTotalSingular,
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
    const input = document.getElementById("graphics-entity-input");
    const addButton = document.getElementById("graphics-add-entity");
    const selected = document.getElementById("graphics-selected-entities");
    const datalist = document.getElementById("graphics-entity-options");
    const totalCheckbox = document.getElementById("graphics-corpus-total");
    const corpusCheckboxes = Array.from(document.querySelectorAll(".graphics-corpus-checkbox"));
    const status = document.getElementById("graphics-status");

    if (!dataRoot || !canvas || !input || !addButton || !selected || !datalist || !totalCheckbox || !status) {
      return null;
    }

    return {
      addButton,
      canvas,
      corpusCheckboxes,
      datalist,
      dataRoot,
      input,
      selected,
      status,
      totalCheckbox,
    };
  }

  function buildYears(dataRoot) {
    const minYear = Number(dataRoot.dataset.minYear || 0);
    const maxYear = Number(dataRoot.dataset.maxYear || 0);
    const years = [];

    for (let year = minYear; year <= maxYear; year += 1) {
      years.push(year);
    }

    return years;
  }

  function collectEntityNodes(dataRoot) {
    Array.from(dataRoot.querySelectorAll(".graphics-entity")).forEach((node) => {
      state.entityNodes.set(node.dataset.entityId, node);
    });
  }

  function collectOptions(datalist) {
    Array.from(datalist.querySelectorAll("option")).forEach((option) => {
      state.optionMap.set(option.value, {
        id: option.dataset.entityId,
        label: option.dataset.displayLabel,
        type: option.dataset.entityType,
      });
    });
  }

  function parseEntity(id) {
    const node = state.entityNodes.get(id);

    if (!node) {
      return null;
    }

    const years = new Map();
    Array.from(node.querySelectorAll(".graphics-year")).forEach((yearNode) => {
      const year = Number(yearNode.dataset.year);
      years.set(year, {
        traktat: Number(yearNode.dataset.traktat || 0),
        critics: Number(yearNode.dataset.critics || 0),
        vms: Number(yearNode.dataset.vms || 0),
        documents: Number(yearNode.dataset.documents || 0),
      });
    });

    const entity = {
      id,
      label: node.dataset.entityLabel,
      type: node.dataset.entityType,
      years,
    };

    state.entityCache.set(id, entity);
    return entity;
  }

  function getEntity(id) {
    return state.entityCache.get(id) || parseEntity(id);
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

  function createChart(elements) {
    const context = elements.canvas.getContext("2d");
    state.chart = new Chart(context, {
      type: "line",
      data: {
        datasets: [],
      },
      options: {
        animation: false,
        interaction: {
          intersect: false,
          mode: "index",
        },
        maintainAspectRatio: false,
        parsing: false,
        plugins: {
          legend: {
            position: "bottom",
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
                return `${context.dataset.label}: ${context.formattedValue}`;
              },
              afterLabel(context) {
                const activeCorpora = context.chart.$activeCorpora || CORPUS_KEYS;
                const breakdown = context.raw.corpora || {};
                return activeCorpora.map((corpus) => `${state.i18n.corpusLabels[corpus]}: ${breakdown[corpus] || 0}`);
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
      label: `${entity.label} [${entity.type}]`,
      pointRadius: 0,
      pointHoverRadius: 4,
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
      setStatus(elements, state.i18n.statusEmpty);
      return;
    }

    if (!activeCorpora.length) {
      state.chart.data.datasets = [];
      state.chart.$activeCorpora = [];
      state.chart.update();
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

  function init() {
    const elements = collectElements();
    if (!elements) {
      return;
    }

    state.years = buildYears(elements.dataRoot);
    state.i18n = collectI18n(elements.dataRoot);
    collectEntityNodes(elements.dataRoot);
    collectOptions(elements.datalist);
    syncCorpusControls(elements);
    updateChart(elements);

    elements.addButton.addEventListener("click", () => addEntity(elements));
    elements.input.addEventListener("keydown", (event) => {
      if (event.key === "Enter") {
        event.preventDefault();
        addEntity(elements);
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
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();