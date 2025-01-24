function editCartItem(productId, action) {
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "modifyCart",
			productId: productId,
			action: action
		},
		success: function() {
			if (action == "delete") {
				// Do things
			}
		}
	});
}