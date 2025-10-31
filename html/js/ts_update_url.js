var tsInput;

function attachSearchListener() {
  if (tsInput) {
    return;
  }

  tsInput = document.querySelector("input[type='search']");

  if (!tsInput) {
    setTimeout(attachSearchListener, 100);
    return;
  }

  var initialQuery = new URLSearchParams(window.location.search).get(
    "hsl[query]"
  );
  if (initialQuery && !tsInput.value) {
    tsInput.value = initialQuery;
  }

  tsInput.addEventListener("input", updateHeaderUrl);

  setTimeout(updateHeaderUrl, 300);
}

attachSearchListener();

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
  var tsInputVal = tsInput ? tsInput.value : "";

    urlToUpdate.forEach((el) => {
      var urlToUpdateHref = el.getAttribute("href");
      if (!urlToUpdateHref) {
        return;
      }

      try {
        var newUrl = new URL(urlToUpdateHref, window.location.href);

        if (tsInputVal) {
          newUrl.searchParams.set("mark", tsInputVal);
        } else {
          newUrl.searchParams.delete("mark");
        }

        var relativeHref = `${newUrl.pathname}${newUrl.search}${newUrl.hash}`;
        el.setAttribute("href", relativeHref);
      } catch (err) {
        // Keep existing href if URL parsing fails.
      }
    });

    // listenToCheckbox();
    listenToPagination();
  }, 500);
}
