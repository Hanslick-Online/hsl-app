const searchLang = new URL(window.location.href).searchParams.get("lang") === "en" ? "en" : "de";
const searchText = {
  de: {
    empty: "Keine Treffer für <q>{{ query }}</q>",
    showMore: "mehr anzeigen",
    showLess: "weniger anzeigen",
    stats: `
            {{#areHitsSorted}}
              {{#hasNoSortedResults}}keine Treffer{{/hasNoSortedResults}}
              {{#hasOneSortedResults}}1 Treffer{{/hasOneSortedResults}}
              {{#hasManySortedResults}}{{#helpers.formatNumber}}{{nbSortedHits}}{{/helpers.formatNumber}} Treffer{{/hasManySortedResults}}
              aus {{#helpers.formatNumber}}{{nbHits}}{{/helpers.formatNumber}}
            {{/areHitsSorted}}
            {{^areHitsSorted}}
              {{#hasNoResults}}keine Treffer{{/hasNoResults}}
              {{#hasOneResult}}1 Treffer{{/hasOneResult}}
              {{#hasManyResults}}{{#helpers.formatNumber}}{{nbHits}}{{/helpers.formatNumber}} Treffer{{/hasManyResults}}
            {{/areHitsSorted}}
            gefunden in {{processingTimeMS}}ms
          `,
    placesPlaceholder: "Nach Orten suchen",
    personsPlaceholder: "Nach Personen suchen",
    worksPlaceholder: "Nach Werken suchen",
    rangeSeparator: "bis",
    rangeSubmit: "Suchen",
    resetFilters: "Filter zurücksetzen",
    sortDefault: "Standard",
    sortAsc: "Jahr (asc)",
    sortDesc: "Jahr (desc)",
  },
  en: {
    empty: "No hits for <q>{{ query }}</q>",
    showMore: "show more",
    showLess: "show less",
    stats: `
            {{#areHitsSorted}}
              {{#hasNoSortedResults}}no hits{{/hasNoSortedResults}}
              {{#hasOneSortedResults}}1 hit{{/hasOneSortedResults}}
              {{#hasManySortedResults}}{{#helpers.formatNumber}}{{nbSortedHits}}{{/helpers.formatNumber}} hits{{/hasManySortedResults}}
              out of {{#helpers.formatNumber}}{{nbHits}}{{/helpers.formatNumber}}
            {{/areHitsSorted}}
            {{^areHitsSorted}}
              {{#hasNoResults}}no hits{{/hasNoResults}}
              {{#hasOneResult}}1 hit{{/hasOneResult}}
              {{#hasManyResults}}{{#helpers.formatNumber}}{{nbHits}}{{/helpers.formatNumber}} hits{{/hasManyResults}}
            {{/areHitsSorted}}
            found in {{processingTimeMS}}ms
          `,
    placesPlaceholder: "Search for places",
    personsPlaceholder: "Search for persons",
    worksPlaceholder: "Search for works",
    rangeSeparator: "to",
    rangeSubmit: "Search",
    resetFilters: "Reset Filters",
    sortDefault: "Default",
    sortAsc: "Year (asc)",
    sortDesc: "Year (desc)",
  },
}[searchLang];

const typesenseInstantsearchAdapter = new TypesenseInstantSearchAdapter({
  server: {
    apiKey: "dFQLGBzgcWlXNzL1XENqHFUaOHJvcSRr", // Be sure to use an API key that only allows searches, in production
    nodes: [
      {
        host: "typesense.acdh-dev.oeaw.ac.at",
        port: "443",
        protocol: "https",
      },
    ],
    // apiKey: "xyz", // Be sure to use an API key that only allows searches, in production
    // nodes: [
    //   {
    //     host: "0.0.0.0",
    //     port: "8108",
    //     protocol: "http",
    //   },
    // ],
  },
  // The following parameters are directly passed to Typesense's search API endpoint.
  //  So you can pass any parameters supported by the search endpoint below.
  //  query_by is required.
  //  filterBy is managed and overridden by InstantSearch.js. To set it, you want to use one of the filter widgets like refinementList or use the `configure` widget.
  additionalSearchParameters: {
    query_by: "full_text,title"
  },
});

const searchClient = typesenseInstantsearchAdapter.searchClient;
const search = instantsearch({
  searchClient,
  indexName: "hsl",
  routing: true,
});

search.addWidgets([
  instantsearch.widgets.searchBox({
    container: "#searchbox",
    autofocus: true,
    cssClasses: {
      form: "form-inline",
      input: "form-control col-md-11",
      submit: "btn",
      reset: "btn",
    },
  }),

  instantsearch.widgets.hits({
    container: "#hits",
    templates: {
      empty: searchText.empty,
      item: `
              <h5><a href="{{ id }}">{{#helpers.snippet}}{ "attribute": "title", "highlightedTagName": "mark" }{{/helpers.snippet}}</a></h5>
              <p style="overflow:hidden;max-height:210px;">{{#helpers.snippet}}{ "attribute": "full_text", "highlightedTagName": "mark" }{{/helpers.snippet}}</p>
              <h5><span class="badge badge-primary">{{ project }}</span></h5>
              <div>
                  <a class="show-entities pointer" onclick="show_hide_click(this)">${searchText.showMore}</a>
                  <div style="display: none;">
                      {{#persons}}
                      <span class="badge bg-secondary">{{ . }}</span>
                      {{/persons}}
                  </div>
                  <div style="display: none;">
                      {{#works}}
                      <span class="badge bg-success">{{ . }}</span>
                      {{/works}}
                  </div>
                  <div style="display: none;">
                      {{#places}}
                      <span class="badge bg-info">{{ . }}</span>
                      {{/places}}
                  </div>
              </div>
          `,
    },
    transformItems(items) {
      return items.map(item => ({
        ...item,
        id: item.id.replace(/t__(\d\d)_VMS_(\d\d\d\d)_TEI_AW_(\d\d-\d\d-\d\d)-TEI-P5\.html/, 't__VMS_Auflage_$1_$2.html')
      }));
    },
  }),

  instantsearch.widgets.stats({
    container: "#stats-container",
    templates: {
      text: searchText.stats,
    },
  }),

  instantsearch.widgets.menu({
    container: "#menu-edition",
    attribute: "edition",
  }),

  instantsearch.widgets.refinementList({
    container: "#refinement-list-places",
    attribute: "places",
    searchable: true,
    searchablePlaceholder: searchText.placesPlaceholder,
    sortBy: ["isRefined", "count:desc", "name:asc"], // testing
    showMore: true,
    limit: 10,
    showMoreLimit: 50,
    operator: "and",
    cssClasses: {
      searchableInput: "form-control form-control-sm mb-2 border-light-2",
      searchableSubmit: "d-none",
      searchableReset: "d-none",
      showMore: "btn btn-secondary btn-sm align-content-center",
      list: "list-unstyled",
      count: "badge ml-2 badge-info",
      label: "d-flex align-items-center text-capitalize",
      checkbox: "mr-2",
    },
  }),

  instantsearch.widgets.refinementList({
    container: "#refinement-list-persons",
    attribute: "persons",
    searchable: true,
    searchablePlaceholder: searchText.personsPlaceholder,
    sortBy: ["isRefined", "count:desc", "name:asc"], // testing
    showMore: true,
    limit: 10,
    showMoreLimit: 50,
    operator: "and",
    cssClasses: {
      searchableInput: "form-control form-control-sm mb-2 border-light-2",
      searchableSubmit: "d-none",
      searchableReset: "d-none",
      showMore: "btn btn-secondary btn-sm align-content-center",
      list: "list-unstyled",
      count: "badge ml-2 badge-secondary",
      label: "d-flex align-items-center text-capitalize",
      checkbox: "mr-2",
    },
  }),

  instantsearch.widgets.refinementList({
    container: "#refinement-list-works",
    attribute: "works",
    searchable: true,
    searchablePlaceholder: searchText.worksPlaceholder,
    sortBy: ["isRefined", "count:desc", "name:asc"], // testing
    showMore: true,
    limit: 10,
    showMoreLimit: 50,
    operator: "and",
    cssClasses: {
      searchableInput: "form-control form-control-sm mb-2 border-light-2",
      searchableSubmit: "d-none",
      searchableReset: "d-none",
      showMore: "btn btn-secondary btn-sm align-content-center",
      list: "list-unstyled",
      count: "badge ml-2 badge-success",
      label: "d-flex align-items-center text-capitalize",
      checkbox: "mr-2",
    },
  }),

  instantsearch.widgets.rangeInput({
    container: "#range-input",
    attribute: "year",
    templates: {
      separatorText: searchText.rangeSeparator,
      submitText: searchText.rangeSubmit,
    },
    cssClasses: {
      form: "form-inline",
      input: "form-control",
      submit: "btn",
    },
  }),

  instantsearch.widgets.pagination({
    container: "#pagination-top",
    padding: 2,
    cssClasses: {
      list: "pagination",
      item: "page-item",
      link: "page-link",
    },
  }),

  instantsearch.widgets.pagination({
    container: "#pagination-bottom",
    padding: 2,
    cssClasses: {
      list: "pagination",
      item: "page-item",
      link: "page-link",
    },
  }),

  instantsearch.widgets.clearRefinements({
    container: "#clear-refinements",
    templates: {
      resetLabel: searchText.resetFilters,
    },
    cssClasses: {
      button: "btn",
    },
  }),

  instantsearch.widgets.currentRefinements({
    container: "#current-refinements",
    cssClasses: {
      delete: "btn",
      label: "badge",
    },
  }),

  instantsearch.widgets.sortBy({
    container: "#sort-by",
    items: [
      { label: searchText.sortDefault, value: "hsl" },
      { label: searchText.sortAsc, value: "hsl/sort/date:asc" },
      { label: searchText.sortDesc, value: "hsl/sort/date:desc" },
    ],
  }),

  instantsearch.widgets.configure({
    hitsPerPage: 8,
    attributesToSnippet: ["full_text"],
  }),
]);

// search.addWidgets([
//   instantsearch.widgets.configure({
//     attributesToSnippet: ["full_text:30", "title"],
//   }),
// ]);
// search.setUiState({
//   refinementList: {
//     edition: ["english"],
//   },
// });


search.start();

function show_hide_click(el) {
  var show_text = searchText.showMore;
  var hide_text = searchText.showLess;
  el.innerHTML = show_text;
  var siblings = el.parentElement.querySelectorAll("div");
  [...siblings].forEach((sibling) => {
    if (sibling.style.display === "none") {
      sibling.style.display = "block";
      el.innerHTML = hide_text;
    } else {
      sibling.style.display = "none";
      el.innerHTML = show_text;
    }
  });
}
