function validateForm() {
	const firstName = $("#firstName");
	const firstNameError = $("#firstNameError");
	const lastName = $("#lastName");
	const lastNameError = $("#lastNameError");
	const email = $("#email");
	const emailError = $("#emailError");
	const phone = $("#phone");
	const phoneError = $("#phoneError");
	const password = $("#password");
	const passwordError = $("#passwordError");
	const confirmPassword = $("#confirmPassword");
	const confirmPasswordError = $("#confirmPasswordError");
	let valid = true;

	$(".error").text("");
	$(".input").removeClass("border-danger");

	valid &= validateName(firstName, "First name", firstNameError);
	valid &= validateName(lastName, "Last name", lastNameError);
	valid &= validateEmail(email, emailError);
	valid &= validatePhoneNumber(phone, phoneError);
	valid &= validatePassword(password, passwordError);
	valid &= validateConfirmPassword(confirmPassword, password, confirmPasswordError);

	if (!valid) event.preventDefault();
}
