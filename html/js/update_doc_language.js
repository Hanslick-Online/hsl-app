/*
    mapping to update document language
    based on url search parameters
*/
(async function getMappingJson() {
    /* json contains mappings from en to de urls and vice versa */
    let file = "https://raw.githubusercontent.com/Hanslick-Online/hsl-app/main/html/json";
    // let file = "http://0.0.0.0:8000/json";
    const response = await fetch(`${file}/lang-mapping.json`);
    const jsonData = await response.json();

    /* on page load get lang urlsearchparam 
        and change page content language */
    window.onload = loadLanguage();
    
    function loadLanguage() {

        /* get urlsearchparams for language */
        var url = new URL(document.location.href);
        var urlParam = new URLSearchParams(url.search);
        var lang = urlParam.get("lang");

        /* must be replaced in production
        get pathname and specific filename
        set new path based on mappings from mappings json
        key in mappings = filename */
        let path = location.pathname.split("/");
        let newPath = path.length == 3 && path[2].length > 0 ? jsonData[lang][path[2]]
                    : path.length == 2 && path[1].length > 0 ? jsonData[lang][path[1]]
                    : lang == "en" ? jsonData[lang]["index.html"]
                    : jsonData[lang]["index-en.html"];

        /* test if path mapping is available in mappings
        if not use current location pathname
        reload to switch to new location pathname */
        if (newPath) {
            window.history.replaceState({}, "", `${newPath}?${urlParam}`);
            location.reload();
            return false;
        } else {
            window.history.replaceState({}, "", `${location.pathname}?${urlParam}`);
        }

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
        
    }

    /*
        function to update document language
        based on url search parameters
    */
    (function updateDocLanguage() {

        /* get url search params */
        var url = new URL(document.location.href);
        var urlParam = new URLSearchParams(url.search);

        /* translate-de or en are html el holding content
        in english or german language
        based on urlsearchparams lang it switches between them */
        var translate_de = document.getElementsByClassName("translate-de");
        var translate_en = document.getElementsByClassName("translate-en");
        if (urlParam.get("lang") == "de") {
            [].forEach.call(translate_de, function(opt) {
                opt.classList.remove("fade-lang");
            });
            [].forEach.call(translate_en, function(opt) {
                opt.classList.add("fade-lang");
            });
        } else {
            [].forEach.call(translate_en, function(opt) {
                opt.classList.remove("fade-lang");
            });
            [].forEach.call(translate_de, function(opt) {
                opt.classList.add("fade-lang");
            });
        }

        /* lang_change_de or en changes language based on json mappings
        instead of onload a click event is triggered in the navigation
        language menu */
        var lang_btn_de = document.getElementsByClassName("lang_change_de");
        var lang_btn_en = document.getElementsByClassName("lang_change_en");
        [].forEach.call(lang_btn_de, function(opt) {            
            opt.addEventListener("click", function(event) {
                event.preventDefault();

                /* must be replaced in production
                get pathname and specific filename
                set new path based on mappings from mappings json
                key in mappings = filename */
                let path = location.pathname.split("/");
                let newPath = path.length == 3 && path[2].length > 0 ? jsonData.de[path[2]]
                    : path.length == 2 && path[1].length > 0 ? jsonData.de[path[1]]
                    : jsonData.de["index-en.html"];
                urlParam.set("lang", "de");

                /* test if path mapping is available in mappings
                if not use current location pathname
                reload to switch to new location pathname */
                if (newPath) {
                    /* replace state to change url with new urlparam */
                    window.history.replaceState({}, "", `${newPath}?${urlParam}`);
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

                /* must be replaced in production
                get pathname and specific filename
                set new path based on mappings from mappings json
                key in mappings = filename */
                let path = location.pathname.split("/");
                let newPath = path.length > 2 && path[2].length > 0 ? jsonData.en[path[2]]
                    : path.length > 1 && path[1].length > 0 ? jsonData.en[path[1]]
                    : jsonData.en["index.html"];
                urlParam.set("lang", "en");

                /* test if path mapping is available in mappings
                if not use current location pathname
                reload to switch to new location pathname */
                if (newPath) {
                    /* replace state to change url with new urlparam */
                    window.history.replaceState({}, "", `${newPath}?${urlParam}`);
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