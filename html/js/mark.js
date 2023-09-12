// the DOM object of the context (where to search for matches)
var input = document.querySelectorAll(".card-body.yes-index"),
  markInstance = new Mark(input),
  // Cache DOM elements
  keywordInput = document.querySelector("input[name='keyword']"),
  optionInputs = document.querySelectorAll("input[name='opt[]']"),
  clearBtn = document.querySelector("button[data-search='clear']"),
  prevBtn = document.querySelector("button[data-search='prev']"),
  nextBtn = document.querySelector("button[data-search='next']"),
  results = [],
  currentClass = "current",
  // offsetTop = 50,
  currentIndex = 0;

function jumpTo() {
  if (results.length) {
    var position,
      current = results[currentIndex];
    [].forEach.call(results, function (el) {
      el.classList.remove(currentClass);
    });
    if (current) {
      current.classList.add(currentClass);
      current.scrollIntoView({
        block: "start",
        inline: "nearest",
        smooth: "true"
      });
    }
  }
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

function performMark() {
  // Read the keyword
  var keyword = keywordInput.value;

  // Determine selected options
  var options = {
    done: function() {
      results = input[0].querySelectorAll("mark");
      currentIndex = 0;
      jumpTo();
    }
  };
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

clearBtn.addEventListener("click", function() {
  markInstance.unmark();
  keywordInput.value = "";
  keywordInput.scrollIntoView({
    block: "start",
    inline: "nearest",
    smooth: "true"
  });
});

nextBtn.addEventListener("click", function() {
  if (results.length) {
    currentIndex += this === nextBtn ? 1 : -1;
    if (currentIndex < 0) {
      currentIndex = results.length - 1;
    }
    if (currentIndex > results.length - 1) {
      currentIndex = 0;
    }
    jumpTo();
  }
});

prevBtn.addEventListener("click", function() {
  if (results.length) {
    currentIndex += this === prevBtn ? -1 : 1;
    if (currentIndex < 0) {
      currentIndex = results.length - 1;
    }
    if (currentIndex > results.length - 1) {
      currentIndex = 0;
    }
    jumpTo();
  }
});

// Listen to input and option changes
keywordInput.addEventListener("input", performMark);
for (var i = 0; i < optionInputs.length; i++) {
  optionInputs[i].addEventListener("change", performMark);
}
window.onload = performMarkUrl();
