/*
    function to update document language
    based on url search parameters
*/
(function updateDocLanguage() {
    var url = new URL(document.location.href);
    var urlParam = new URLSearchParams(url.search);

    if (urlParam.get("lang") == "de") {
        document.getElementsByClassName("navbar-nav-de")[0]
        .classList.remove("fade");
        document.getElementsByClassName("navbar-nav-en")[0]
        .classList.add("fade");
    } else {
        document.getElementsByClassName("navbar-nav-en")[0]
        .classList.remove("fade");
        document.getElementsByClassName("navbar-nav-de")[0]
        .classList.add("fade");
    }

    var lang_btn_de = document.getElementsByClassName("lang_change_de");
    var lang_btn_en = document.getElementsByClassName("lang_change_en");
    [].forEach.call(lang_btn_de, function(opt) {
        opt.addEventListener("click", function(event) {
            event.preventDefault();
            urlParam.set("lang", "de");
            /* replace state to change url with new urlparam */
            window.history.replaceState({}, "", `${location.pathname}?${urlParam}`);
            location.reload();
            return false;
        });
    });
    [].forEach.call(lang_btn_en, function(opt) {
        opt.addEventListener("click", function(event) {
            event.preventDefault();
            urlParam.set("lang", "en");
            /* replace state to change url with new urlparam */
            window.history.replaceState({}, "", `${location.pathname}?${urlParam}`);
            location.reload();
            return false;
        });
    });
})();