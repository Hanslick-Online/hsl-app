(function () {
	var sortColumn = document.currentScript.getAttribute('data-sort-column');
	if (sortColumn === null || !/^\d+$/.test(sortColumn)) {
		throw new Error('toc_table.js requires a valid data-sort-column attribute');
	}

	$(document).ready(function () {
		var activeTable = window.hslSiteLang === 'en' ? 'tocTable-en' : 'tocTable-de';
		createDataTable(activeTable, [[Number(sortColumn), 'asc']], 50, window.hslSiteLang);
	});
})();
