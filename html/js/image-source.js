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

    var linkSpan = document.getElementById("image-source-link");
    if (!linkSpan) return;

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

    /* Build the link HTML for a given index (0-based) */
    function sourceHTML(idx) {
        if (idx < 0 || idx >= sourceItems.length) {
            return '<em class="translate-de">Keine Quellenangabe vorhanden.</em>' +
                   '<em class="translate-en">No source information available.</em>';
        }
        var item = sourceItems[idx];
        var url = item.getAttribute("data-target")  || "#";
        var label = resolveSubtype(item.getAttribute("data-subtype") || "");
        return '<a href="' + url + '" target="_blank" rel="noopener noreferrer">' + label + '</a>';
    }

    /* Determine the source index for the currently visible content.
       Each relatedItem corresponds to one tei-div (identified by data-n).
       We find which tei-div is currently in view and use its data-n
       attribute (1-based) converted to a 0-based source index. */
    function currentSourceIndex() {
        var divs = document.querySelectorAll(".card-body .tei-div[data-n]");
        if (divs.length > 0) {
            // Find the last div whose top has scrolled past the viewport top
            for (var i = divs.length - 1; i >= 0; i--) {
                var rect = divs[i].getBoundingClientRect();
                if (rect.top <= 200) {
                    var n = parseInt(divs[i].getAttribute("data-n"), 10);
                    return isNaN(n) ? i : n - 1;
                }
            }
            // Default to first div's data-n
            var n = parseInt(divs[0].getAttribute("data-n"), 10);
            return isNaN(n) ? 0 : n - 1;
        }
        return 0;
    }

    /* Update the dropdown each time it is about to be shown */
    var dropdown = document.querySelector("#image-source-widget .dropstart > a[data-bs-toggle='dropdown']");
    if (dropdown) {
        dropdown.addEventListener("click", function () {
            var idx = currentSourceIndex();
            // Clamp index to available sources
            if (idx >= sourceItems.length) {
                idx = sourceItems.length - 1;
            }
            linkSpan.innerHTML = sourceHTML(idx);
        });
    }
})();
