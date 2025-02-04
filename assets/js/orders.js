$(document).ready(function() {
	$('#searchOrders').on('input', function() {
		var searchText = $(this).val().toLowerCase();
		$('.order-card').each(function() {
			var orderText = $(this).attr("data-order-id").toLowerCase();
			$(this).toggle(orderText.includes(searchText));
		});
	});
});

function downloadInvoice(orderId) {
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "downloadInvoice",
			orderId: orderId
		}
	});
}