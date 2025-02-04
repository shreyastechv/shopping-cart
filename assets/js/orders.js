$(document).ready(function() {
	$('#searchOrders').on('input', function() {
		var searchText = $(this).val().toLowerCase();
		$('.order-card').each(function() {
			var orderText = $(this).text().toLowerCase();
			$(this).toggle(orderText.includes(searchText));
		});
	});
});
