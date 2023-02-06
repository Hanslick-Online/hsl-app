var tsInput = document.querySelector("input[type='search']");
tsInput.addEventListener("input", updateHeaderUrl);

function listenToPagination() {
  setTimeout(() => {
    var tsPagination = document.querySelectorAll(".ais-Pagination-link");
    [].forEach.call(tsPagination, function (opt) {
      opt.removeEventListener("click", updateHeaderUrl);
      opt.addEventListener("click", updateHeaderUrl);
    });
  }, 100);
}
setTimeout(() => {
  listenToPagination();
}, 100);

// function listenToCheckbox() {
//   var tsRefInput = document.querySelectorAll("input[type='checkbox']");
//   [].forEach.call(tsRefInput, function (opt) {
//     opt.removeEventListener("change", updateHeaderUrl);
//     opt.addEventListener("change", updateHeaderUrl);
//   });
// }
// setTimeout(() => {
//   listenToCheckbox();
// }, 100);

function updateHeaderUrl() {
  setTimeout(() => {
    // var tsRefinements = document.querySelectorAll(
    //   ".ais-CurrentRefinements-categoryLabel"
    // );

    // if (tsRefinements) {
    //   refinements = "";
    //   tsRefinements.forEach((el) => {
    //     console.log(el.innerHTML);
    //     refinements += `+${el.innerHTML}`;
    //   });
    // }

    var urlToUpdate = document.querySelectorAll(".ais-Hits-item h5 a");
    var tsInputVal = tsInput.value;

    urlToUpdate.forEach((el) => {
      var urlToUpdateHref = el.getAttribute("href");
      if (urlToUpdateHref.includes("?mark=")) {
        var newUrl = urlToUpdateHref.replace(
          /\?mark=\.+$/,
          `?mark=${tsInputVal}`
        );
        el.setAttribute("href", newUrl);
      } else {
        var searchParams = new URLSearchParams("?mark=default");
        searchParams.set("mark", tsInputVal);
        var url = `${urlToUpdateHref.split("#")[0]}?${searchParams.toString()}#${urlToUpdateHref.split("#")[1]}`
        el.setAttribute("href", url);
      }
    });

    // listenToCheckbox();
    listenToPagination();
  }, 500);
}
