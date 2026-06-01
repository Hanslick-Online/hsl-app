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

function createDataTable(containerElement, title, panesShow, panesHide, hide) {
    const paneTargets = containerElement === 'listbibl'
        ? panesShow.filter((target) => target !== 2)
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
            targets: 2,
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
}