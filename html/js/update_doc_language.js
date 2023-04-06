/*
    mapping to update document language
    based on url search parameters
*/
(async function getMappingJson() {
    let file = "https://raw.githubusercontent.com/Hanslick-Online/hsl-app/main/html/json";
    // let file = "http://0.0.0.0:8000/json";
    const response = await fetch(`${file}/lang-mapping.json`);
    const jsonData = await response.json();

    window.onload = loadLanguage();
    
    function loadLanguage() {
        var url = new URL(document.location.href);
        var urlParam = new URLSearchParams(url.search);
        var lang = urlParam.get("lang");

        let path = location.pathname.replace("/", "");
        let newPath = jsonData[lang][path];

        if (newPath) {
            window.history.replaceState({}, "", `${newPath}?${urlParam}`);
            location.reload();
            return false;
        } else {
            window.history.replaceState({}, "", `${location.pathname}?${urlParam}`);
        }
        
    }

    /*
        function to update document language
        based on url search parameters
    */
    (function updateDocLanguage() {
        var url = new URL(document.location.href);
        var urlParam = new URLSearchParams(url.search);

        var translate_de = document.getElementsByClassName("translate-de");
        var translate_en = document.getElementsByClassName("translate-en");

        if (urlParam.get("lang") == "de") {
            [].forEach.call(translate_de, function(opt) {
                opt.classList.remove("fade");
            });
            [].forEach.call(translate_en, function(opt) {
                opt.classList.add("fade");
            });
        } else {
            [].forEach.call(translate_en, function(opt) {
                opt.classList.remove("fade");
            });
            [].forEach.call(translate_de, function(opt) {
                opt.classList.add("fade");
            });
        }

        var lang_btn_de = document.getElementsByClassName("lang_change_de");
        var lang_btn_en = document.getElementsByClassName("lang_change_en");
        [].forEach.call(lang_btn_de, function(opt) {            
            opt.addEventListener("click", function(event) {
                event.preventDefault();

                var loc = location.pathname.replace("/", "");
                var path = jsonData.de[loc];
                urlParam.set("lang", "de");

                if (path) {
                    /* replace state to change url with new urlparam */
                    window.history.replaceState({}, "", `${path}?${urlParam}`);
                    location.reload();
                    return false;
                } else {
                    /* replace state to change url with new urlparam */
                    window.history.replaceState({}, "", `${location.pathname}?${urlParam}`);
                    location.reload();
                    return false;
                }
            });
        });
        [].forEach.call(lang_btn_en, function(opt) {
            opt.addEventListener("click", function(event) {
                event.preventDefault();

                var loc = location.pathname.replace("/", "");
                var path = jsonData.en[loc];
                urlParam.set("lang", "en");

                if (path) {
                    /* replace state to change url with new urlparam */
                    window.history.replaceState({}, "", `${path}?${urlParam}`);
                    location.reload();
                    return false;
                } else {
                    /* replace state to change url with new urlparam */
                    window.history.replaceState({}, "", `${location.pathname}?${urlParam}`);
                    location.reload();
                    return false;
                }
            });
        });
    })();
})();