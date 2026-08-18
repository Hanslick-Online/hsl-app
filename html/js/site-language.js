(function () {
  function setVisibility(node, visible) {
    node.hidden = !visible;
    node.style.display = visible ? "" : "none";
    node.setAttribute("aria-hidden", visible ? "false" : "true");
  }

  function hasEnglishVersion() {
    return document.documentElement.dataset.hasEnglish !== "false";
  }

  function resolveLanguage() {
    const lang = new URL(window.location.href).searchParams.get("lang");
    if (lang === "en" && hasEnglishVersion()) {
      return "en";
    }
    return "de";
  }

  function updateBlocks(lang) {
    document.querySelectorAll("[data-lang]").forEach((node) => {
      setVisibility(node, node.getAttribute("data-lang") === lang);
    });
  }

  function updateLocalizedLabels(lang) {
    document.querySelectorAll('[data-label-de][data-label-en]').forEach((node) => {
      node.textContent = node.getAttribute(lang === 'en' ? 'data-label-en' : 'data-label-de') || '';
    });
  }

  function updateLocalizedAttributes(lang) {
    const localizedAttributes = ["title", "placeholder", "aria-label", "alt", "href", "action"];

    document.querySelectorAll("*").forEach((node) => {
      localizedAttributes.forEach((attribute) => {
        const localizedValue = node.getAttribute(`data-${attribute}-${lang}`);
        if (localizedValue !== null) {
          node.setAttribute(attribute, localizedValue);
        }
      });
    });
  }

  function localizeInternalLinks(lang) {
    const urlLang = new URL(window.location.href).searchParams.get("lang");
    if (!urlLang) {
      return;
    }

    document.querySelectorAll("a[href]").forEach((node) => {
      const href = node.getAttribute("href");
      if (!href || href.startsWith("http") || href.startsWith("mailto:") || href.startsWith("#") || !href.includes(".html")) {
        return;
      }

      const target = new URL(href, window.location.href);
      target.searchParams.set("lang", lang);
      const relativeHref = `${target.pathname.split("/").pop()}${target.search}${target.hash}`;
      node.setAttribute("href", relativeHref);
    });
  }

  function updateDocumentTitle(lang) {
    const datasetKey = lang === "en" ? "titleEn" : "titleDe";
    const title = document.documentElement.dataset[datasetKey];
    if (title) {
      document.title = title;
    }
  }

  function updateSwitches(lang) {
    document.querySelectorAll("[data-set-lang]").forEach((node) => {
      const targetLang = node.getAttribute("data-set-lang");
      if (targetLang === "en" && !hasEnglishVersion()) {
        setVisibility(node, false);
        return;
      }

      setVisibility(node, true);

      const url = new URL(window.location.href);
      url.searchParams.set("lang", targetLang);
      node.setAttribute("href", `${url.pathname}?${url.searchParams.toString()}`);
      node.classList.toggle("lang_active", targetLang === lang);
      node.addEventListener("click", (event) => {
        event.preventDefault();
        window.location.href = node.getAttribute("href");
      });
    });
  }

  function applyLanguage(lang) {
    window.hslSiteLang = lang;
    document.documentElement.lang = lang;
    updateBlocks(lang);
    updateLocalizedLabels(lang);
    updateLocalizedAttributes(lang);
    localizeInternalLinks(lang);
    updateDocumentTitle(lang);
    updateSwitches(lang);
  }

  window.hslApplyLanguage = applyLanguage;
  applyLanguage(resolveLanguage());
})();