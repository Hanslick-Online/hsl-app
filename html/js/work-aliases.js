(() => {
  let aliasesPromise;

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

    return aliases.sort((left, right) => right[0].length - left[0].length);
  }

  function normalizeTokens(value, aliases) {
    let normalized = String(value).toLocaleLowerCase();
    aliases.forEach(([alias, canonical]) => {
      const pattern = new RegExp(
        `(^|[^\\p{L}\\p{N}])${escapeRegExp(alias)}(?=$|[^\\p{L}\\p{N}])`,
        "giu"
      );
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
    const queryTokens = normalizeTokens(query, aliases);
    if (!queryTokens.length) {
      return true;
    }

    const labelTokens = normalizeTokens(label, aliases);
    return queryTokens.every((queryToken) =>
      labelTokens.some((labelToken) =>
        labelToken === queryToken ||
        (!/^\d+$/u.test(queryToken) && labelToken.startsWith(queryToken))
      )
    );
  }

  window.HanslickWorkAliases = Object.freeze({ load, matches });
})();
