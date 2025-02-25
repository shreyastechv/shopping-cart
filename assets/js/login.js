function validateForm() {
	const userInput = $("#userInput");
	const password = $("#password");
	const passwordError = $("#passwordError");
	const userInputError = $("#userInputError");
	let valid = true;

	$(".error").text("");
	$("#userInput").removeClass("border-danger bg-danger-subtle");
	$("#password").removeClass("border-danger bg-danger-subtle");

	valid &= validateRequiredField(userInput, "Email or phone number", userInputError);
	if (valid) {
		if (isNaN(userInput.val().trim())) {
			// NaN means input must be an email
			valid &= validateEmail(userInput, userInputError);
		}
		else {
			// Not NaN means it must be phone number
			valid &= validatePhoneNumber(userInput, userInputError);
		}
	}
	valid &= validateRequiredField(password, "Password", passwordError);

	if (!valid) event.preventDefault();
}
