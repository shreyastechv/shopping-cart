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
			const pageUrl = window.location.pathname;

			/* Since admin have different cfc, it needs to be specified
			in order to clear the session vairables that are admin-specific*/
			if (pageUrl.startsWith("/admin")) {
				componentUrl = "/components/userManagement.cfc";
			} else {
				componentUrl = "/admin/components/admin.cfc";
			}

			$.ajax({
				type: "POST",
				url: componentUrl,
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