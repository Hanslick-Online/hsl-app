/* http://live.datatables.net/nugeyewe/7/edit */
/* script provided by https://github.com/babslgam */
const DATA_TABLE_TEXT = {
    de: {
        search: "Suche:",
        info: "Zeige _START_ bis _END_ von _TOTAL_ Einträgen",
        infoEmpty: "Keine Einträge verfügbar",
        infoFiltered: "(gefiltert von _MAX_ Einträgen)",
        lengthMenu: "_MENU_ Einträge pro Seite",
        zeroRecords: "Keine passenden Einträge gefunden",
        paginate: {
            first: "Erste",
            previous: "Zurück",
            next: "Weiter",
            last: "Letzte"
        },
        buttons: {
            copy: "Kopieren",
            excel: "Excel",
            pdf: "PDF"
        }
    },
    en: {
        search: "Search:",
        info: "Showing _START_ to _END_ of _TOTAL_ entries",
        infoEmpty: "No entries available",
        infoFiltered: "(filtered from _MAX_ total entries)",
        lengthMenu: "_MENU_ entries per page",
        zeroRecords: "No matching entries found",
        paginate: {
            first: "First",
            previous: "Previous",
            next: "Next",
            last: "Last"
        },
        buttons: {
            copy: "Copy",
            excel: "Excel",
            pdf: "PDF"
        }
    }
};

function hideSearchInputs(containerElement, columns) {
    for (let index = 0; index < columns.length; index += 1) {
        if (columns[index]) {
            $(`#${containerElement} .filters th`).eq(index).show();
        } else {
            $(`#${containerElement} .filters th`).eq(index).hide();
        }
    }
}

function createDataTable(containerElement, order, pageLength, lang) {
    const uiLang = lang || window.hslSiteLang || document.documentElement.lang || "de";
    const messages = DATA_TABLE_TEXT[uiLang] || DATA_TABLE_TEXT.de;
    
    $(`#${containerElement} thead tr`)
        .clone(true)
        .addClass('filters')
        .appendTo(`#${containerElement} thead`);

    var table = $(`#${containerElement}`).DataTable({
        dom: "'<'row controlwrapper'<'col-sm-4'f><'col-sm-4'i><'col-sm-4 exportbuttons'Br>>'" +
            "'<'row'<'col-sm-6 offset-sm-6'p>>'" +
            "'<'row'<'col-sm-12't>>'" +
            "'<'row'<'col-sm-6 offset-sm-6'p>>'",
        responsive: true,
        pageLength: pageLength,
        buttons: [{
            extend: 'copyHtml5',
            text: '<i class="far fa-copy"/>',
            titleAttr: messages.buttons.copy,
            className: 'btn-link',
            init: function (api, node, config) {
                $(node).removeClass('btn-secondary')
            }
        },
        {
            extend: 'excelHtml5',
            text: '<i class="far fa-file-excel"/>',
            titleAttr: messages.buttons.excel,
            className: 'btn-link',
            init: function (api, node, config) {
                $(node).removeClass('btn-secondary')
            }
        },
        {
            extend: 'pdfHtml5',
            text: '<i class="far fa-file-pdf"/>',
            titleAttr: messages.buttons.pdf,
            className: 'btn-link',
            init: function (api, node, config) {
                $(node).removeClass('btn-secondary')
            }
        }],
        language: {
            search: messages.search,
            info: messages.info,
            infoEmpty: messages.infoEmpty,
            infoFiltered: messages.infoFiltered,
            lengthMenu: messages.lengthMenu,
            zeroRecords: messages.zeroRecords,
            paginate: messages.paginate,
        },
        order: order,
        orderCellsTop: true,
        fixedHeader: true,
        initComplete: function () {
            var api = this.api();

            // For each column
            api
                .columns()
                .eq(0)
                .each(function (colIdx) {
                    // Set the header cell to contain the input element
                    var cell = $(`#${containerElement} .filters th`).eq(
                        $(api.column(colIdx).header()).index()
                    );
                    $(cell).html('<input type="text"/>');

                    // On every keypress in this input
                    $(
                        'input',
                        $(` #${containerElement} .filters th`).eq($(api.column(colIdx).header()).index())
                    )
                        .off('keyup change')
                        .on('keyup change', function (e) {
                            e.stopPropagation();

                            // Get the search value
                            $(this).attr('title', $(this).val());
                            var regexr = '({search})'; //$(this).parents('th').find('select').val();

                            var cursorPosition = this.selectionStart;
                            // Search the column for that value
                            api
                                .column(colIdx)
                                .search(
                                    this.value != ''
                                        ? regexr.replace('{search}', '(((' + this.value + ')))')
                                        : '',
                                    this.value != '',
                                    this.value == ''
                                )
                                .draw();

                            $(this)
                                .focus()[0]
                                .setSelectionRange(cursorPosition, cursorPosition);
                        });
                });
                hideSearchInputs(containerElement, api.columns().responsiveHidden().toArray());
        }
    });
    table.responsive.recalc();

    table.on('responsive-resize', function (e, datatable, columns) {
        hideSearchInputs(containerElement, columns);

    });
}