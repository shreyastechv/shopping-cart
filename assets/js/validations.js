function validateRequiredField(field, fieldName, errorContainer) {
	if (field.val().trim().length == 0) {
		field.addClass("border-danger");
		errorContainer.text(`${fieldName} is required!`);
		return false;
	}

	return true;
}

function validateName(field, fieldName, errorContainer) {
	if (!validateRequiredField(field, fieldName, errorContainer)) {
		return false;
	} else if (!/^[A-Za-z ]+$/.test(field.val().trim())) {
		field.addClass("border-danger");
		errorContainer.text(`${fieldName} should only contain letters and spaces`);
		return false;
	}

	return true;
}

function validatePincode(field, errorContainer) {
	if (!validateRequiredField(field, "Pincode", errorContainer)) {
		return false;
	} else if (!/^\d{6}$/.test(field.val().trim())) {
		field.addClass("border-danger");
		errorContainer.text("Pincode should be 6 digits");
		return false;
	}

	return true;
}

function validatePhoneNumber(field, errorContainer) {
	if (!validateRequiredField(field, "Phone number", errorContainer)) {
		return false;
	} else if (!/^\d{10}$/.test(field.val().trim())) {
		field.addClass("border-danger");
		errorContainer.text("Phone number should be 10 digits");
		return false;
	}

	return true;
}

function validateCategoryName(field, fieldName, errorContainer) {
	if (!validateRequiredField(field, fieldName, errorContainer)) {
		return false;
	} else if (!/^[A-Za-z'& ]+$/.test(field.val().trim())) {
		field.addClass("border-danger");
		errorContainer.text(`${fieldName} name should only contain letters, spaces, single quotes and ampersand symbol.`);
		return false;
	}

	return true;
}

function validateCardNumber(field, errorContainer) {
	const cardNumber = field.val().trim().replaceAll("-", "");

	if (!validateRequiredField(field, "Card number", errorContainer)) {
		return false;
	} else if (cardNumber.length != 16) {
		field.addClass("border-danger");
		errorContainer.text("Not a valid card number!");
		return false;
	}

	return true;
}

function validateCVV(field, errorContainer) {
	if (!validateRequiredField(field, "CVV number", errorContainer)) {
		return false;
	} else if (field.val().trim().replaceAll("-", "").length != 3) {
		field.addClass("border-danger");
		errorContainer.text("CVV is not valid!");
		return false;
	}

	return true;
}
function validateEmail(field, errorContainer) {
	const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;

	if (!validateRequiredField(field, "Email", errorContainer)) {
		return false;
	} else if (!emailRegex.test(field.val().trim())) {
		field.addClass("border-danger");
		errorContainer.text("Not a valid email address!");
		return false;
	}
	return true;
}
function validatePassword(field, errorContainer) {
	const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;

	if (!validateRequiredField(field, "Password", errorContainer)) {
		return false;
	} else if (!passwordRegex.test(field.val().trim())) {
		field.addClass("border-danger");
		errorContainer.text("Password must be at least 8 characters long, contain one uppercase letter, one lowercase letter, one number, and one special character!");
		return false;
	}

	return true;
}

function validateConfirmPassword(field, passwordField, errorContainer) {
	if (passwordField.val().trim().length == 0) {
		return true;
	}

	if (field.val().trim().length == 0) {
		field.addClass("border-danger");
		errorContainer.text("Type the password again to confirm!");
		return false;
	} else if (passwordField.val().trim() != field.val().trim()) {
		field.addClass("border-danger");
		errorContainer.text("Passwords don't match!");
		return false;
	}

	return true;
}

function validatePrice(field, errorContainer) {
	const priceRegex = /^\d+(\.\d{1,2})?$/;

	if (!validateRequiredField(field, "Price", errorContainer)) {
		return false;
	} else if (!priceRegex.test(field.val().trim())) {
		field.addClass("border-danger");
		errorContainer.text("Not a valid price! Must be a positive number with up to two decimal places.");
		return false;
	}

	return true;
}

function validateTax(field, errorContainer) {
	const taxRegex = /^(100|(\d{1,2}(\.\d{1,2})?))$/;

	if (!validateRequiredField(field, "Tax", errorContainer)) {
		return false;
	} else if (!taxRegex.test(field.val().trim())) {
		field.addClass("border-danger");
		errorContainer.text("Not a valid tax! Must be a number between 0 and 100.");
		return false;
	}

	return true;
}

function validateDescription(field, errorContainer) {
	const description = field.val().trim();

	if (!validateRequiredField(field, "Description", errorContainer)) {
		return false;
	} else if (description.length < 10 || description.length > 400) {
		field.addClass("border-danger");
		errorContainer.text("Description must be between 10 and 500 characters.");
		return false;
	}

	return true;
}

function validateProductName(field, errorContainer) {
	if (!validateRequiredField(field, "Product name", errorContainer)) {
		return false;
	} else if (field.val().trim().length > 100) {
		field.addClass("border-danger");
		errorContainer.text("Product name must be less than 100 characters.");
		return false;
	}

	return true;
}

function validateSelectTag(field, fieldName, errorContainer) {
	if (field.val().trim() == 0) {
		field.addClass("border-danger");
		errorContainer.text(`${fieldName} is required!`);
		return false;
	}

	return true;
}