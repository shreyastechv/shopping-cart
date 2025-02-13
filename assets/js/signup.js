function validateForm() {
	const firstName = $("#firstName").val().trim();
	const lastName = $("#lastName").val().trim();
	const email = $("#email").val().trim();
	const phone = $("#phone").val().trim();
	const password = $("#password").val().trim();
	const confirmPassword = $("#confirmPassword").val().trim();
	let valid = true;

	$(".error").text("");
	$(".input").removeClass("border-danger");

	// Firstname Validation
	if (firstName.length === 0) {
		$("#firstNameError").text("First name is required");
		$("#firstName").addClass("border-danger");
		valid = false;
	}
	else if (/\d/.test(firstName)) {
		$("#firstNameError").text("First name should not contain any digits");
		$("#firstName").addClass("border-danger");
		valid = false;
	}

	// Lastname Validation
	if (lastName.length === 0) {
		$("#lastNameError").text("Last name is required");
		$("#lastName").addClass("border-danger");
		valid = false;
	}
	else if (/\d/.test(lastName)) {
		$("#lastNameError").text("Last name should not contain any digits");
		$("#lastName").addClass("border-danger");
		valid = false;
	}

	// Email Validation
	if (email.length === 0) {
		$("#emailError").text("Email is required");
		$("#email").addClass("border-danger");
		valid = false;
	}
	else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
		$("#emailError").text("Invalid email");
		$("#email").addClass("border-danger");
		valid = false;
	}

	// Phone Validation
	if (phone.length === 0) {
		$("#phoneError").text("Phone number is required");
		$("#phone").addClass("border-danger");
		valid = false;
	}
	else if (!/^\d{10}$/.test(phone)) {
		$("#phoneError").text("Phone number should be 10 digits long");
		$("#phone").addClass("border-danger");
		valid = false;
	}

	// Password Validation
	const passwordPattern = /^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$/;

	if (password.length === 0) {
		$("#passwordError").text("Input password");
		$("#password").addClass("border-danger");
		valid = false;
	} else if (!passwordPattern.test(password)) {
		$("#passwordError").text("Password must be at least 8 characters long and include uppercase, lowercase, number, and special character");
		$("#password").addClass("border-danger");
		valid = false;
	}

	// Confirm Password Validation
	if (password.length !== 0) {
		if (confirmPassword.length === 0) {
			$("#confirmPasswordError").text("Input password again");
			$("#confirmPassword").addClass("border-danger");
			valid = false;
		} else if (password !== confirmPassword) {
			$("#confirmPasswordError").text("Passwords don't match");
			$("#confirmPassword").addClass("border-danger");
			valid = false;
		}
	}

	if (!valid) event.preventDefault();
}