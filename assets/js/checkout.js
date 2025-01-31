function handleCheckout(productId) {
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

	// Show modal
	$("#orderSuccess").modal("show");

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
				if (productId.trim().length) {
					buyNow(addressId, productId);
				} else {
					createOrder(addressId);
				}
			} else {
				cardNumber.addClass("border-danger");
				cvv.addClass("border-danger");
				cardNumberError.text(resposeJSON.message);
			}
		}
	})
}

function createOrder(addressId) {
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
				$("#orderSuccess div[name='success']").removeClass("d-none")
			}, 1000);
		}
	})
}

function buyNow(addressId, productId) {
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "buyNow",
			addressId: addressId,
			productId: productId,
			quantity: 1
		},
		success: function () {
			setTimeout(() => {
				$("#orderSuccess div[name='loading']").addClass("d-none");
				$("#orderSuccess div[name='success']").removeClass("d-none")
			}, 1000);
		},
		error: function() {
			$("#orderSuccess div[name='loading']").addClass("d-none");
			$("#orderSuccess div[name='error']").removeClass("d-none")
		}
	})
}
