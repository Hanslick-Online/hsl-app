document.addEventListener("DOMContentLoaded", function () {
	var lang = window.hslSiteLang || new URLSearchParams(window.location.search).get("lang") || "de";
	document.querySelectorAll("#diffLevel option[data-label-de]").forEach(function (node) {
		node.textContent = node.getAttribute(lang === "en" ? "data-label-en" : "data-label-de");
	});
});
