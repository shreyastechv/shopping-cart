function validateForm() {
	const username = $("#username").val();
	const password = $("#password").val();

	$(".error").text("");
	$("#username").removeClass("border-danger bg-danger-subtle");
	$("#password").removeClass("border-danger bg-danger-subtle");

	if (username.trim().length === 0) {
		$("#usernameError").text("Field is required");
		$("#username").addClass("border-danger bg-danger-subtle");
		valid = false;
	}
	if (password.trim().length === 0) {
		$("#passwordError").text("Field is required");
		$("#password").addClass("border-danger bg-danger-subtle");
		valid = false;
	}

	if (!valid) return false;
	return true;
}