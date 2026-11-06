document
	.querySelectorAll(
		'#chapter-navBarNavDropdown .dropdown-menu, #edition-navBarNavDropdown .dropdown-menu, .annotation-options > .dropdown-menu'
	)
	.forEach((menu) => {
		menu.addEventListener('click', (event) => {
			if (event.target instanceof Element && event.target.closest('.dropdown-item')) {
				event.stopPropagation();
			}
		});
	});
