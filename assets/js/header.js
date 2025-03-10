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
				dataType: "json",
				data: {
					method: "logOut"
				},
				success: function() {
					location.href = "/";
				}
			});
		}
	});
}

// Code to focus search bar when CTRL + K is pressed
// and unfocus on pressing ESC
$(window).keydown(function(event) {
	if (event.ctrlKey && (event.key == 'k' || event.keyCode == 75)) {
		event.preventDefault(); // Prevent the default browser behavior
		$("#search").focus().select();
	}

	if (event.keyCode == 27) {
		$("#search").blur();
	}
});