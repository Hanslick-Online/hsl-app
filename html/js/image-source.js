/*
##################################################################
Image Source Widget
Updates the image-source modal to show the facsimile source
corresponding to the currently visible page (anchor-pb index).
##################################################################
*/
(function () {
    "use strict";

    var sourceItems = document.querySelectorAll("#image-source-data .image-source-item");
    if (sourceItems.length === 0) return;          // nothing to do

    /* Map subtype codes to human-readable names */
    var subtypeLabels = {
        "ONB-ANNO":       "ANNO (AustriaN Newspaper Online) – Österreichische Nationalbibliothek",
        "ULBDüsseldorf":  "Universitäts- und Landesbibliothek Düsseldorf",
        "BSB-DIGIPRESS":  "Bayerische Staatsbibliothek – Digipress",
        "SLUB":           "Sächsische Landesbibliothek – Staats- und Universitätsbibliothek Dresden",
        "archive.org":    "Internet Archive",
        "SUUBBremen":     "Staats- und Universitätsbibliothek Bremen",
        "GoogleBooks":    "Google Books",
        "MDZ":            "Bayerische Staatsbibliothek – Münchener Digitalisierungszentrum"
    };

    /* Resolve a subtype code to its display label */
    function resolveSubtype(code) {
        return subtypeLabels[code] || code;
    }

    /* When the dropdown opens, rebuild its list to show ALL sources */
    var toggle = document.querySelector("#image-source-widget .dropstart > a[data-bs-toggle='dropdown']");
    if (toggle) {
        toggle.addEventListener("click", function () {
            var ul = document.querySelector("#image-source-widget .dropdown-menu");
            if (!ul) return;
            ul.innerHTML = "";
            sourceItems.forEach(function (item) {
                var url   = item.getAttribute("data-target")  || "#";
                var label = resolveSubtype(item.getAttribute("data-subtype") || "");
                var li = document.createElement("li");
                li.className = "dropdown-item";
                li.innerHTML =
                    '<span class="translate-de">Bildquelle: </span>' +
                    '<span class="translate-en">Image source: </span>' +
                    '<a href="' + url + '" target="_blank" rel="noopener noreferrer">' + label + '</a>';
                ul.appendChild(li);
            });
        });
    }
})();
