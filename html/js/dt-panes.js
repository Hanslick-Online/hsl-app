function splitPaneListValues(data) {
    if (!data) {
        return [];
    }

    const html = document.createElement('div');
    html.innerHTML = data;

    return Array.from(html.querySelectorAll('li'))
        .map((item) => item.textContent.replace(/;\s*$/, '').trim())
        .filter(Boolean);
}

function localizePanePlaceholders(containerElement) {
    const lang = window.hslSiteLang || document.documentElement.lang || 'de';
    const labelMap = new Map();

    document.querySelectorAll(`#${containerElement} thead th[data-label-de][data-label-en]`).forEach((header) => {
        const deLabel = header.getAttribute('data-label-de') || '';
        const enLabel = header.getAttribute('data-label-en') || '';
        const localizedLabel = lang === 'en' ? enLabel : deLabel;

        if (deLabel) {
            labelMap.set(deLabel, localizedLabel);
        }

        if (enLabel) {
            labelMap.set(enLabel, localizedLabel);
        }
    });

    document.querySelectorAll('.dtsp-paneInputButton').forEach((input) => {
        const placeholder = input.getAttribute('placeholder') || '';
        const localizedPlaceholder = labelMap.get(placeholder);

        if (localizedPlaceholder) {
            input.setAttribute('placeholder', localizedPlaceholder);
        }
    });
}

function createDataTable(containerElement, title, panesShow, panesHide, hide) {
    const splitPaneTargets = containerElement === 'listbibl'
        ? [2, 3]
        : [];

    const paneTargets = containerElement === 'listbibl'
        ? panesShow.filter((target) => !splitPaneTargets.includes(target))
        : panesShow;

    const columnDefs = [
        {
            searchPanes: {
                show: true
            },
            targets: paneTargets
        },
        {
            searchPanes: {
                show: false
            },
            targets: panesHide
        },
        {
            targets: hide,
            searchable: true,
            visible: false
        }
    ];

    if (containerElement === 'listbibl') {
        columnDefs.push({
            targets: splitPaneTargets,
            render: function (data, type) {
                if (type === 'sp') {
                    return splitPaneListValues(data);
                }

                return data;
            },
            searchPanes: {
                orthogonal: {
                    display: 'sp',
                    filter: 'sp',
                    search: 'sp',
                    sort: 'sp',
                    type: 'sp'
                },
                show: true
            }
        });
    }

    var table = $(`#${containerElement}`).DataTable({
        responsive: true,
        pageLength: 50,
        oLanguage: {
            "sSearch": title
        },
        dom: 'PfpBrtip',
        searchPanes: {
            initCollapsed: false
        },
        buttons: [{
            extend: 'copyHtml5',
            text: '<i class="far fa-copy"/>',
            titleAttr: 'Copy',
            className: 'btn-link',
            init: function (api, node, config) {
                $(node).removeClass('btn-secondary')
            }
        }
        // {
        //     extend: 'excelHtml5',
        //     text: '<i class="far fa-file-excel"/>',
        //     titleAttr: 'Excel',
        //     className: 'btn-link',
        //     init: function (api, node, config) {
        //         $(node).removeClass('btn-secondary')
        //     }
        // }
        ],
        columnDefs: columnDefs,
    });

    if (window.hslApplyLanguage) {
        window.hslApplyLanguage(window.hslSiteLang || document.documentElement.lang || 'de');
    }

    localizePanePlaceholders(containerElement);
    table.on('draw.dt', function () {
        if (window.hslApplyLanguage) {
            window.hslApplyLanguage(window.hslSiteLang || document.documentElement.lang || 'de');
        }
        localizePanePlaceholders(containerElement);
    });

}