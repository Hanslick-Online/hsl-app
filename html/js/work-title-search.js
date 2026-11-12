(() => {
  const workTitleTokens = new WeakMap();

  function normalizeTokens(value) {
    return String(value)
      .normalize("NFD")
      .replace(/\p{Diacritic}/gu, "")
      .toLocaleLowerCase()
      .match(/[\p{L}\p{N}]+/gu) || [];
  }

  function matchesTokens(titleTokens, queryTokens) {
    return queryTokens.every((queryToken) =>
      titleTokens.some((titleToken) => titleToken.startsWith(queryToken))
    );
  }

  function getTitleVariants(option) {
    if (!workTitleTokens.has(option)) {
      const alternativeTitles = JSON.parse(option.dataset.alternativeTitles || "[]");
      const titles = [option.dataset.displayLabel, ...alternativeTitles]
        .flatMap((title) => title.split(/\s*;\s*/))
        .filter(Boolean);
      workTitleTokens.set(option, titles.map(normalizeTokens));
    }

    return workTitleTokens.get(option);
  }

  function getSuggestionsContainer(workGroup) {
    if (workGroup.suggestions) {
      return workGroup.suggestions;
    }

    const list = document.createElement("div");
    list.id = "graphics-work-suggestions";
    list.className = "list-group graphics-work-suggestions d-none";
    list.setAttribute("role", "listbox");
    workGroup.input.removeAttribute("list");
    workGroup.input.setAttribute("aria-autocomplete", "list");
    workGroup.input.setAttribute("aria-controls", list.id);
    workGroup.input.setAttribute("aria-expanded", "false");
    workGroup.input.parentElement.insertAdjacentElement("afterend", list);
    workGroup.suggestions = list;
    return list;
  }

  function filterSuggestions(workGroup, workOptions, authorWorkMap, selectedWork) {
    const query = workGroup.input?.value.trim() || "";
    const queryTokens = normalizeTokens(query);
    const matchingWorks = workOptions.filter((option) => {
      if (selectedWork) {
        return option.dataset.entityId === selectedWork.id;
      }
      if (!query) {
        return true;
      }
      if (!queryTokens.length) {
        return false;
      }
      return getTitleVariants(option).some((titleTokens) =>
        matchesTokens(titleTokens, queryTokens)
      );
    });
    const matchingIds = new Set(matchingWorks.map((option) => option.dataset.entityId));
    const authors = Array.from(authorWorkMap.values())
      .filter((author) => !query || Array.from(author.workIds).some((id) => matchingIds.has(id)))
      .sort((left, right) => left.label.localeCompare(right.label));

    if (workGroup.authorDatalist) {
      workGroup.authorDatalist.replaceChildren(...authors.map((author) => {
        const option = document.createElement("option");
        option.value = author.label;
        return option;
      }));
    }

    const authorQuery = workGroup.authorInput?.value.trim().toLocaleLowerCase() || "";
    const author = authorWorkMap.get(authorQuery);
    const matchesByAuthor = matchingWorks.filter(
      (option) => !authorQuery || (author && author.workIds.has(option.dataset.entityId))
    );
    const suggestions = getSuggestionsContainer(workGroup);
    const shouldShowSuggestions = Boolean(query && matchesByAuthor.length && !selectedWork);
    suggestions.replaceChildren(...matchesByAuthor.map((option) => {
      const suggestion = document.createElement("button");
      suggestion.type = "button";
      suggestion.className = "list-group-item list-group-item-action graphics-work-suggestion";
      suggestion.setAttribute("role", "option");
      suggestion.textContent = option.dataset.displayLabel;
      suggestion.addEventListener("mousedown", (event) => event.preventDefault());
      suggestion.addEventListener("click", () => {
        workGroup.input.value = option.value;
        workGroup.input.focus();
        workGroup.input.dispatchEvent(new Event("input", { bubbles: true }));
      });
      return suggestion;
    }));
    suggestions.classList.toggle("d-none", !shouldShowSuggestions);
    workGroup.input.setAttribute("aria-expanded", String(shouldShowSuggestions));

    if (workGroup.datalist) {
      workGroup.datalist.replaceChildren(...workOptions);
    }

    if (shouldShowSuggestions) {
      suggestions.scrollTop = 0;
    }
    return { author, authors, matches: matchesByAuthor };
  }

  window.HanslickWorkTitleSearch = Object.freeze({ filterSuggestions });
})();
