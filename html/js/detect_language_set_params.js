/*
    function to get browser language and 
    add language as url parameter
*/
(function updateLangUrlParam() {
    /* get current browser language */
    var lang = navigator.language;

    /* get current ur */
    var url = new URL(document.location.href);

    /* get current url parameters */
    var urlParam = new URLSearchParams(url.search);

    /* only de and en supported */
    var langUpdate = /^de\b/.test(lang) ? "de" : "en";

    if (urlParam.get("lang") == null) {
        urlParam.set("lang", langUpdate);
    }

    if (!["de", "en"].includes(urlParam.get("lang"))) {
        urlParam.set("lang", langUpdate);
    }

    /* replace state to change url with new urlparam */
    window.history.replaceState({}, "", `${location.pathname}?${urlParam}`);

    var logo = document.getElementsByClassName("custom-logo-link")[0];
    if (logo) {
        logo.setAttribute('href', `index.html?${urlParam}`);
    }

    if (urlParam.get("lang") == "de") {
        [].forEach.call(
            document.getElementsByClassName("lang_change_de"), 
            function(opt) {
                opt.classList.add("active");
        });
    }

    if (urlParam.get("lang") == "en") {
        [].forEach.call(
            document.getElementsByClassName("lang_change_en"), 
            function(opt) {
                opt.classList.add("active");
        });
    }
    
})();