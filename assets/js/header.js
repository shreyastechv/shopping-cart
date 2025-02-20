function logOut() {
	if(confirm("Log out from shopping cart?")) {
		$.ajax({
			type: "POST",
			url: "./components/userManagement.cfc",
			data: {
				method: "logOut"
			},
			success: function() {
				location.reload();
			}
		});
	}
}
