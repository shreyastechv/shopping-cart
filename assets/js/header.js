function logOut() {
	if(confirm("Log out from shopping cart?")) {
		$.ajax({
			type: "POST",
			url: "./components/shoppingCart.cfc",
			data: {
				method: "logOut"
			},
			success: function() {
				location.reload();
			}
		});
	}
}