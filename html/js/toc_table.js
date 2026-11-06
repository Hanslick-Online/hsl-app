$(document).ready(function () {
	var activeTable = window.hslSiteLang === 'en' ? 'tocTable-en' : 'tocTable-de';
	createDataTable(activeTable, [[5, 'asc']], 50, window.hslSiteLang);
});
