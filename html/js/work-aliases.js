(() => {
  let aliasesPromise;
  const workTitleTokens = new WeakMap();

  function escapeRegExp(value) {
    return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  function createAliasMap(source) {
    if (!source || typeof source !== "object" || Array.isArray(source)) {
      throw new Error("Work aliases must be a JSON object.");
    }

    const aliases = [];
    Object.entries(source).forEach(([canonical, values]) => {
      if (!Array.isArray(values) || values.some((value) => typeof value !== "string")) {
        throw new Error(`Aliases for "${canonical}" must be an array of strings.`);
      }
      values.concat(canonical).forEach((value) => {
        aliases.push([value.toLocaleLowerCase(), canonical.toLocaleLowerCase()]);
      });
    });

    return aliases
      .sort((left, right) => right[0].length - left[0].length)
      .map(([alias, canonical]) => [
        new RegExp(`(^|[^\\p{L}\\p{N}])${escapeRegExp(alias)}(?=$|[^\\p{L}\\p{N}])`, "giu"),
        canonical,
      ]);
  }

  function normalizeTokens(value, aliases) {
    let normalized = String(value).toLocaleLowerCase();
    aliases.forEach(([pattern, canonical]) => {
      normalized = normalized.replace(pattern, (_, boundary) => `${boundary}${canonical}`);
    });
    return normalized.match(/[\p{L}\p{N}]+/gu) || [];
  }

  async function load() {
    if (!aliasesPromise) {
      aliasesPromise = fetch("js/aliases.json")
        .then((response) => {
          if (!response.ok) {
            throw new Error(`Failed to load work aliases: ${response.status}`);
          }
          return response.json();
        })
        .then(createAliasMap);
    }
    return aliasesPromise;
  }

  function matches(label, query, aliases) {
    return matchesTokens(normalizeTokens(label, aliases), normalizeTokens(query, aliases));
  }

  function matchesTokens(labelTokens, queryTokens) {
    if (!queryTokens.length) {
      return true;
    }

    return queryTokens.every((queryToken) =>
      labelTokens.some((labelToken) =>
        labelToken === queryToken ||
        (!/^\d+$/u.test(queryToken) && labelToken.startsWith(queryToken))
      )
    );
  }

  function filterSuggestions(workGroup, workOptions, authorWorkMap, aliases, selectedWork) {
    const query = workGroup.input?.value.trim() || "";
    const queryTokens = normalizeTokens(query, aliases);
    const matchingWorks = workOptions.filter((option) => {
      if (selectedWork) {
        return option.dataset.entityId === selectedWork.id;
      }
      if (!queryTokens.length) {
        return true;
      }
      if (!workTitleTokens.has(option)) {
        const titles = [option.dataset.displayLabel, ...JSON.parse(option.dataset.alternativeTitles)];
        workTitleTokens.set(option, titles.map((title) => normalizeTokens(title, aliases)));
      }
      return workTitleTokens.get(option).some((tokens) => matchesTokens(tokens, queryTokens));
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
    matchesByAuthor.forEach((option) => {
      option.label = query && !option.value.toLocaleLowerCase().includes(query.toLocaleLowerCase())
        ? `${option.dataset.displayLabel} — ${query}`
        : option.dataset.displayLabel;
    });
    workGroup.datalist?.replaceChildren(...matchesByAuthor);
    return { author, authors, matches: matchesByAuthor };
  }

  window.HanslickWorkAliases = Object.freeze({ load, matches, filterSuggestions });
})();
