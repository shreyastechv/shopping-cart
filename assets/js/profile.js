$("#profileModal").on("hidden.bs.modal", function () {
  // Remove error msgs
  $(".profileError").empty();
});

function handleProfileChange() {
	const firstNameNoChange = $("#userFirstName").val().trim() == $("#userFirstName").prop("defaultValue");
	const lastNameNoChange = $("#userLastName").val().trim() == $("#userLastName").prop("defaultValue");
	const emailNoChange = $("#userEmail").val().trim() == $("#userEmail").prop("defaultValue");
	const phoneNoChange = $("#userPhone").val().trim() == $("#userPhone").prop("defaultValue");

	if (firstNameNoChange && lastNameNoChange && emailNoChange && phoneNoChange) {
		$("#profileSubmitBtn").prop("disabled", true);
	} else {
		$("#profileSubmitBtn").prop("disabled", false);
	}
}

$(document).ready(function () {
	// Handle enabling or disabling submit btn when input fields are updated
	$(".profileInput").each((index, element) => {
		$(element).keyup(handleProfileChange);
	});
});

function deleteAddress(containerId, addressId) {
	$.ajax({
		type: "POST",
		url: "./components/userManagement.cfc",
		data: {
			method: "deleteAddress",
			addressId: addressId
		},
		success: function () {
			if ($(`#${containerId}`).parent().children().length == 1) {
				// Reload page in case there is no address left
				location.reload();
			} else {
				// Delete address container if there are other addressess left
				$(`#${containerId}`).remove();
			}
		}
	});
}

function processProfileForm() {
	event.preventDefault();

	// Remove error msgs and red borders from inputs
	$(".profileInput").removeClass("border-danger");
	$(".profileError").empty();

	let valid = true;
	const firstName = $("#userFirstName");
	const firstNameError = $("#userFirstNameError");
	const lastName = $("#userLastName");
	const lastNameError = $("#userLastNameError");
	const email = $("#userEmail");
	const emailError = $("#userEmailError");
	const phone = $("#userPhone");
	const phoneError = $("#userPhoneError");

	if (firstName.val().trim().length == 0) {
		firstName.addClass("border-danger");
		firstNameError.text("First name is required.")
		valid = false;
	} else if (/\d/.test(firstName.val().trim())) {
		firstName.addClass("border-danger");
		firstNameError.text("First name should not contain any digits")
		valid = false;
	}

	if (lastName.val().trim().length == 0) {
		lastName.addClass("border-danger");
		lastNameError.text("Last name is required.")
		valid = false;
	} else if (/\d/.test(lastName.val().trim())) {
		lastName.addClass("border-danger");
		lastNameError.text("Last name is required.")
		valid = false;
	}

	if (email.val().trim().length == 0) {
		email.addClass("border-danger");
		emailError.text("Email is required");
		valid = false;
	}
	else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.val().trim())) {
		email.addClass("border-danger");
		emailError.text("Invalid email");
		valid = false;
	}

	if (phone.val().trim().length == 0) {
		phone.addClass("border-danger");
		phoneError.text("Phone number is required.")
		valid = false;
	} else if (!/^\d{10}$/.test(phone.val().trim())) {
		phone.addClass("border-danger");
		phoneError.text("Phone number should be 10 digits")
		valid = false;
	}

	if (!valid) return;

	$.ajax({
		type: "POST",
		url: "./components/userManagement.cfc",
		data: {
			method: "editProfile",
			firstName: firstName.val().trim(),
			lastName: lastName.val().trim(),
			email: email.val().trim(),
			phone: phone.val().trim()
		},
		success: function (response) {
			const responseJSON = JSON.parse(response);
			if (responseJSON.message == "Profile Updated successfully") {
				location.reload()
			} else {
				$("#profileError").text(responseJSON.message);
			}
		}
	});
}

// Handle profile modal close event to re-fill data
$("#profileModal").on("hidden.bs.modal", function () {
	// Reset value of all input fields to their originale value
	$(".profileInput").each((index, element) => {
		element.value = element.defaultValue;
	});
});
