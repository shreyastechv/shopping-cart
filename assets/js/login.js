function validateForm() {
	const userInput = $("#userInput").val().trim();
	const password = $("#password").val().trim();
	let valid = true;

	$(".error").text("");
	$("#userInput").removeClass("border-danger bg-danger-subtle");
	$("#password").removeClass("border-danger bg-danger-subtle");

	if (userInput.length == 0) {
		$("#userInputError").text("Field is required");
		$("#userInput").addClass("border-danger bg-danger-subtle");
		valid = false;
	}
	else if (isNaN(userInput)) {
		if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userInput)) {
			$("#userInputError").text("Invalid email");
			$("#userInput").addClass("border-danger bg-danger-subtle");
			valid = false;
		}
	}
	else {
		if (userInput.length != 10) {
			$("#userInputError").text("Phone number length should be 10");
			$("#userInput").addClass("border-danger bg-danger-subtle");
			valid = false;
		}
	}

	if (password.length == 0) {
		$("#passwordError").text("Field is required");
		$("#password").addClass("border-danger bg-danger-subtle");
		valid = false;
	}

	if (!valid) event.preventDefault();
}
