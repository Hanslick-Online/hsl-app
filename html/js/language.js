/*
    script to get browser language and 
    add language url parameters
*/

/* get current browser language */
var lang = navigator.language;
console.log(lang);

/* get current ur */
var url = new URL(window.location.href);

/* get current url parameters */
var urlParam = new URLSearchParams(url.search);

if (/^de\b/.test(lang)) {
    urlParam.set("lang", "de");
} else {
    urlParam.set("lang", "en");
}