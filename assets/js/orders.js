function goToPage(pageNumber) {
	pageNumber = parseInt(pageNumber) || 1;
	if (isNaN(pageNumber) || pageNumber <= 0 || !Number.isInteger(pageNumber)) {
		pageNumber = 1;
	}
	const urlParams = new URLSearchParams(window.location.search);
	urlParams.set('pageNumber', pageNumber);
	window.location.href = window.location.pathname + '?' + urlParams.toString();
}