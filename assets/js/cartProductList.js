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
	const currentPage = new URL(document.URL).pathname.split('/').pop();
	let quantity = parseInt($(`#${containerId} input[name="quantity"]`).val());

	// Create alert if quantity is maxed out
	if (action == "increment" && quantity == 5) {
		createAlert(containerId, "Maximmmmum allowed quantity for this item is reached.");
		return;
	}

	// Confirm before deleting product
	if (action == "delete" && !confirm("Delete Product?")) {
		return;
	}

	//Go on with execution if no alert is generated
	$.ajax({
		type: "POST",
		url: "./components/cartManagement.cfc",
		data: {
			method: currentPage == "checkout.cfm" ? "modifyCheckout" : "modifyCart",
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
					$("#cartCount").text(Number($("#cartCount").text())-1);
				}

				// Update total price and tax
				$("#totalPrice").text(totalPrice.toFixed(2));
				$("#totalActualPrice").text(totalActualPrice.toFixed(2));
				$("#totalTax").text(totalTax.toFixed(2));

				// If total price is 0 (cart empty) then reload
				if (totalPrice == 0) {
					if (currentPage == "checkout.cfm") {
						$("#productsNextBtn").prop("disabled", true);
						$("#paymentSectionAccordionBtn").prop("disabled", true);
						$("#accordionBody").append(`
							<div class="d-flex flex-column align-items-center justify-content-center pt-4">
								<div class="fs-5 text-secondary mb-3">Product List is Empty</div>
								<a class="btn btn-primary" href="/">Shop Now</a>
							</div>
						`);
					} else {
						location.reload();
					}
				}
			} else {
				createAlert(containerId, "Sorry. Unable to proceed. Try again.");
			}
		}
	});
}
