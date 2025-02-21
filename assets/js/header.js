function logOut() {
	Swal.fire({
		icon: "warning",
		title: "Log out ?",
		showDenyButton: false,
		showCancelButton: true,
		confirmButtonText: "Ok",
		denyButtonText: "Deny"
	}).then((result) => {
		if (result.isConfirmed) {
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
	});
}
