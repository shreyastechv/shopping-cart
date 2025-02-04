function handleCheckout() {
	event.preventDefault();

	// Remove error msgs and red borders from inputs
	$(".cardInput").removeClass("border-danger");
	$(".cardError").empty();

	let valid = true;
	const cardNumber = $("#cardNumber");
	const cardNumberError = $("#cardNumberError");
	const formattedCardNumber = cardNumber.val().trim().replaceAll("-", "");
	const cvv = $("#cvv");
	const cvvError = $("#cvvError");
	const addressId = $('input[name="addressId"]:checked').val();

	if (formattedCardNumber.length == 0) {
		cardNumber.addClass("border-danger");
		cardNumberError.text("Card number is required");
		valid = false;
	} else if (formattedCardNumber.length != 16) {
		cardNumber.addClass("border-danger");
		cardNumberError.text("Not a valid card number");
		valid = false;
	}

	if (cvv.val().trim().length == 0) {
		cvv.addClass("border-danger");
		cvvError.text("CVV number is required");
		valid = false;
	} else if (cvv.val().trim().length != 3) {
		cvv.addClass("border-danger");
		cvvError.text("CVV is not valid");
		valid = false;
	}

	if (!valid) return;

	// Validate card nummber and cvv
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "validateCard",
			cardNumber: formattedCardNumber,
			cvv: cvv.val().trim()
		},
		success: function (response) {
			const resposeJSON = JSON.parse(response);

			if (resposeJSON.success) {
				createOrder(addressId);
			} else {
				cardNumber.addClass("border-danger");
				cvv.addClass("border-danger");
				cardNumberError.text(resposeJSON.message);
			}
		}
	})
}

function createOrder(addressId) {
	// Open modal
	$("#orderSuccess").modal("show");

	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "createOrder",
			addressId: addressId
		},
		success: function () {
			setTimeout(() => {
				$("#orderSuccess div[name='loading']").addClass("d-none");
				$("#orderSuccess div[name='error']").addClass("d-none");
				$("#orderSuccess div[name='success']").removeClass("d-none")
			}, 1000);
		},
		error: function() {
			$("#orderSuccess div[name='loading']").addClass("d-none");
			$("#orderSuccess div[name='success']").addClass("d-none");
			$("#orderSuccess div[name='error']").removeClass("d-none")
		}
	})
}

/* Below is cart.js code which needs to be refactored */

// Disable decrement btn when quantity is 1
function handleQuantityChange(containerId) {
	let quantity = $(`#${containerId} input[name="quantity"]`).val();
	if (quantity == 1) {
		$(`#${containerId} button[name="decBtn"]`).prop("disabled", true);
	} else {
		$(`#${containerId} button[name="decBtn"]`).prop("disabled", false);
	}
}

function createAlert(containerId, message) {
	// Prevent more than one divs from being created
	if ($(`#${containerId} div[name="maxQuantityAlert"]`).length > 0) return;

	// Create div
	const alertDiv = `
		<div name="maxQuantityAlert" class="alert alert-warning alert-dismissible fade show m-2" role="alert">
			${message}
			<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
		</div>
	`;

	// Append div to parent container
	$(`#${containerId}`).append(alertDiv);
}

function editCartItem(containerId, productId, action) {
	let quantity = parseInt($(`#${containerId} input[name="quantity"]`).val());

	// Create alert if quantity is maxed out
	if (action == "increment" && quantity == 5) {
		createAlert(containerId, "Maximum allowed quantity for this item is reached.");
		return;
	}

	//Go on with execution if no alert is generated
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "modifyCheckout",
			productId: productId,
			action: action
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);
			const { price, actualPrice, quantity, totalPrice, totalActualPrice, totalTax } = responseJSON.data;

			if (responseJSON.success) {
				if (["increment", "decrement"].includes(action)) {
					$(`#${containerId} span[name="price"]`).text(price.toFixed(2));
					$(`#${containerId} span[name="actualPrice"]`).text(actualPrice.toFixed(2));
					$(`#${containerId} input[name="quantity"]`).val(quantity).change();
				}
				else if (action == "delete") {
					$(`#${containerId}`).remove();
				}

				// Update total price and tax
				$("#totalPrice").text(totalPrice.toFixed(2));
				$("#totalActualPrice").text(totalActualPrice.toFixed(2));
				$("#totalTax").text(totalTax.toFixed(2));
			} else {
				createAlert(containerId, "Sorry. Unable to proceed. Try again.");
			}
		}
	});
}

// Below is profile.js code which needs to be made common
function processAddressForm() {
	// Remove error msgs and red borders from inputs
	$(".addressInput").removeClass("border-danger");
	$(".addressError").empty();

	let valid = true;
	const firstName = $("#firstName");
	const firstNameError = $("#firstNameError");
	const lastName = $("#lastName");
	const lastNameError = $("#lastNameError");
	const address = $("#address");
	const addressError = $("#addressError");
	const landmark = $("#landmark");
	const landmarkError = $("#landmarkError");
	const city = $("#city");
	const cityError = $("#cityError");
	const state = $("#state");
	const stateError = $("#stateError");
	const pincode = $("#pincode");
	const pincodeError = $("#pincodeError");
	const phone = $("#phone");
	const phoneError = $("#phoneError");

	if (firstName.val().trim().length === 0) {
		firstName.addClass("border-danger");
		firstNameError.text("First name is required.")
		valid = false;
	} else if (/\d/.test(firstName.val().trim())) {
		firstName.addClass("border-danger");
		firstNameError.text("First name should not contain any digits")
		valid = false;
	}

	if (lastName.val().trim().length === 0) {
		lastName.addClass("border-danger");
		lastNameError.text("Last name is required.")
		valid = false;
	} else if (/\d/.test(lastName.val().trim())) {
		lastName.addClass("border-danger");
		lastNameError.text("Last name is required.")
		valid = false;
	}

	if (address.val().trim().length === 0) {
		address.addClass("border-danger");
		addressError.text("Address is required.")
		valid = false;
	}

	if (landmark.val().trim().length === 0) {
		landmark.addClass("border-danger");
		landmarkError.text("Landmark is required.")
		valid = false;
	}

	if (city.val().trim().length === 0) {
		city.addClass("border-danger");
		cityError.text("City is required.")
		valid = false;
	}

	if (state.val().trim().length === 0) {
		state.addClass("border-danger");
		stateError.text("State is required.")
		valid = false;
	}

	if (pincode.val().trim().length === 0) {
		pincode.addClass("border-danger");
		pincodeError.text("Pincode is required.")
		valid = false;
	} else if (!/^\d{6}$/.test(pincode.val().trim())) {
		pincode.addClass("border-danger");
		pincodeError.text("Pincode should be 6 digits")
		valid = false;
	}

	if (phone.val().trim().length === 0) {
		phone.addClass("border-danger");
		phoneError.text("Phone number is required.")
		valid = false;
	} else if (!/^\d{10}$/.test(phone.val().trim())) {
		phone.addClass("border-danger");
		phoneError.text("Phone number should be 10 digits")
		valid = false;
	}

	if (!valid) event.preventDefault();
}

function deleteAddress(containerId, addressId) {
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "deleteAddress",
			addressId: addressId
		},
		success: function () {
			$(`#${containerId}`).remove();
		}
	});
}
