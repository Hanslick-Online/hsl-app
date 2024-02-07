function createDataTable(containerElement, title, panesShow, panesHide, hide) {
    

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
        columnDefs: [
            {
                searchPanes: {
                    show: true
                },
                targets: panesShow
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
        ],
    });
}