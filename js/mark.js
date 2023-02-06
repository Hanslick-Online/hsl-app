// the DOM object of the context (where to search for matches)
var markInstance = new Mark(document.querySelectorAll("p.yes-index"));
// Cache DOM elements
var keywordInput = document.querySelector("input[name='keyword']");
var optionInputs = document.querySelectorAll("input[name='opt[]']");

function performMark() {
  // Read the keyword
  var keyword = keywordInput.value;

  // Determine selected options
  var options = {};
  [].forEach.call(optionInputs, function (opt) {
    options[opt.value] = opt.checked;
  });

  // Remove previous marked elements and mark
  // the new keyword inside the context
  markInstance.unmark({
    done: function () {
      markInstance.mark(keyword, options);
    },
  });
}

function performMarkUrl() {
  // Determine selected options
  var options = {};
  [].forEach.call(optionInputs, function (opt) {
    options[opt.value] = opt.checked;
  });

  // get current url parameters
  let url = new URL(window.location.href);
  let urlParam = new URLSearchParams(url.search);
  if (urlParam.get("mark") === null) {
    urlParam.set("mark", "default");
  } else if (urlParam.get("mark") == "default") {
    // no action needed
  } else {
    var params = urlParam.get("mark");
    markInstance.unmark({
      done: function () {
        markInstance.mark(params, options);
      },
    });
  }
}

// Listen to input and option changes
keywordInput.addEventListener("input", performMark);
for (var i = 0; i < optionInputs.length; i++) {
  optionInputs[i].addEventListener("change", performMark);
}
window.onload = performMarkUrl();
