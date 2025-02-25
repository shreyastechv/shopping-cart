function handleCheckout() {
	event.preventDefault();

	// Remove error msgs and red borders from inputs
	$(".cardInput").removeClass("border-danger");
	$(".cardError").empty();

	let valid = true;
	const cardNumber = $("#cardNumber");
	const cardNumberError = $("#cardNumberError");
	const cvv = $("#cvv");
	const cvvError = $("#cvvError");
	const addressId = $('input[name="addressId"]:checked').val();

	valid &= validateCardNumber(cardNumber, cardNumberError);
	valid &= validateCVV(cvv, cvvError);

	if (!valid) return;

	// Validate card nummber and cvv
	$.ajax({
		type: "POST",
		url: "./components/cartManagement.cfc",
		data: {
			method: "validateCard",
			cardNumber: formattedCardNumber,
			cvv: cvv.val().trim()
		},
		success: function (response) {
			const result = JSON.parse(response);

			if (result.success) {
				createOrder(addressId);
			} else {
				cardNumber.addClass("border-danger");
				cvv.addClass("border-danger");
				cardNumberError.text(result.message);
			}
		}
	})
}

function createOrder(addressId) {
	// Open modal
	$("#orderResult").modal("show");

	$.ajax({
		type: "POST",
		url: "./components/cartManagement.cfc",
		data: {
			method: "createOrder",
			addressId: addressId
		},
		success: function (response) {
			const result = JSON.parse(response);

			if (result.success == true) {
				setTimeout(() => {
					$("#orderResult div[name='loading']").addClass("d-none");
					$("#orderResult div[name='error']").addClass("d-none");
					$("#orderResult div[name='success']").removeClass("d-none")
				}, 800);
			} else {
				setTimeout(() => {
					$("#orderResult div[name='loading']").addClass("d-none");
					$("#orderResult div[name='success']").addClass("d-none");
					$("#orderResult div[name='error']").removeClass("d-none")
				}, 800);
			}
		},
		error: function() {
			setTimeout(() => {
				$("#orderResult div[name='loading']").addClass("d-none");
				$("#orderResult div[name='success']").addClass("d-none");
				$("#orderResult div[name='error']").removeClass("d-none")
			}, 800);
		}
	})
}
