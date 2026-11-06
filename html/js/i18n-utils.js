(function () {
	const current = new URL(window.location.href);
	const target = new URL("<xsl:value-of select="$canonicalPath"/>", current.href);
	current.searchParams.forEach((value, key) =&gt; target.searchParams.set(key, value));
	if (!['de', 'en'].includes(target.searchParams.get('lang'))) {
		target.searchParams.set('lang', '<xsl:value-of select="$defaultLang"/>');
	}
	window.location.replace(`${target.pathname}?${target.searchParams.toString()}`);
})();
