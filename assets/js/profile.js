$(document).ready(function () {
	// Handle enabling or disabling submit btn when input fields are updated
	$(".profileInput").each((index, element) => {
		$(element).keyup(handleProfileChange);
	});

  // Remove error msgs and re-fill data on modal closing
  $("#profileModal").on("hidden.bs.modal", function () {
    $(".profileError").empty();
    $(".profileInput").removeClass("border-danger");
    $(".profileInput").each((index, element) => {
      element.value = element.defaultValue;
    });
  });
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

function deleteAddress(containerId, addressId) {
	Swal.fire({
		icon: "warning",
		title: "Delete address?",
		showDenyButton: false,
		showCancelButton: true,
		confirmButtonText: "Ok",
		denyButtonText: "Deny"
	}).then((result) => {
		if (result.isConfirmed) {
			$.ajax({
				type: "POST",
				url: "/components/usersManagement.cfc",
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

	valid &= validateName(firstName, "First name", firstNameError);
	valid &= validateName(lastName, "Last name", lastNameError);
	valid &= validateEmail(email, emailError);
	valid &= validatePhoneNumber(phone, phoneError);

	if (!valid) return;

	$.ajax({
		type: "POST",
		url: "./components/usersManagement.cfc",
		dataType: "json",
		data: {
			method: "editProfile",
			firstName: firstName.val().trim(),
			lastName: lastName.val().trim(),
			email: email.val().trim(),
			phone: phone.val().trim()
		},
		success: function (response) {
			if (response.message == "Profile Updated successfully") {
				location.reload()
			} else {
				$("#profileError").text(response.message);
			}
		}
	});
}
