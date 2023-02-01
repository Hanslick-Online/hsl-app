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
        buttons: [
            'copy', 'excel', 'pdf'
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