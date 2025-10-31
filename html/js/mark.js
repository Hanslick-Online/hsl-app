// the DOM object of the context (where to search for matches)
var input = document.querySelectorAll(".card-body.yes-index"),
  markInstance = new Mark(input),
  // Cache DOM elements
  keywordInput = document.querySelector("input[name='keyword']"),
  optionInputs = document.querySelectorAll("input[name='opt[]']"),
  btns = document.getElementById("mark-scroll"),
  clearBtn = document.querySelector("button[data-search='clear']"),
  prevBtn = document.querySelector("button[data-search='prev']"),
  nextBtn = document.querySelector("button[data-search='next']"),
  results = [],
  currentClass = "current",
  // offsetTop = 50,
  resultDiv = document.getElementById("results-div"),
  currentIndex = 0;

function jumpTo(trigger) {
  if (results.length) {
    var position,
      current = results[currentIndex];
    [].forEach.call(results, function (el) {
      el.classList.remove(currentClass);
    });
    clearBtn.removeAttribute("disabled");
    nextBtn.removeAttribute("disabled");
    prevBtn.removeAttribute("disabled");
    if (current && trigger) {
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
  var options = {
    done: function() {
      results = input[0].querySelectorAll("mark");
      currentIndex = 0;
      jumpTo(true);
    }
  };
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
        if (params.length >= 3) {
          var markOptions = Object.assign({}, options);
          if (/\s/.test(params)) {
            markOptions.separateWordSearch = false;
            markOptions.accuracy = {
              value: "exactly",
              limiters: ["'", "‚", "“", "”", "\"", "\u2019", "\u2018"]
            };
            markOptions.acrossElements = true;
            markOptions.ignoreJoiners = true;
          }
          markInstance.mark(params, markOptions);
        }
      },
    });
  }
}

function performMark() {
  btns.classList.remove("fade-lang");
  // Read the keyword
  var keyword = keywordInput.value;
  var pattern = keyword;
  var flags = "gmi";
  if (pattern[pattern.length - 1] !== "\\") {
    var regex = new RegExp(pattern, flags);

    // Determine selected options
    var options = {
      accrossElements: true,
      done: function() {
        results = input[0].querySelectorAll("mark");
        currentIndex = 0;
        jumpTo(false);
        setTimeout(() => {
          resultDiv.innerHTML = "Hits: " + results.length;
        }, 500);
      }
    };

    [].forEach.call(optionInputs, function (opt) {
      options[opt.value] = opt.checked;
    });

    // Remove previous marked elements and mark
    // the new keyword inside the context
    markInstance.unmark({
      done: function () {
        if (pattern.length >= 3) {
          markInstance.markRegExp(regex, options);
        }
      },
    })
  };
}

clearBtn.addEventListener("click", function() {
  markInstance.unmark();
  keywordInput.value = "";
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: "smooth"
  });
  clearBtn.setAttribute("disabled", "disabled");
  nextBtn.setAttribute("disabled", "disabled");
  prevBtn.setAttribute("disabled", "disabled");
  btns.classList.add("fade-lang");
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
    jumpTo(true);
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
    jumpTo(true);
  }
});

// Listen to input and option changes
keywordInput.addEventListener("input", performMark);
for (var i = 0; i < optionInputs.length; i++) {
  optionInputs[i].addEventListener("change", performMark);
}
window.onload = performMarkUrl();