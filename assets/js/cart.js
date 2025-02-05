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
			method: "modifyCart",
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

				// If total price is 0 (cart empty) then reload
				if (totalPrice == 0) location.reload();
			} else {
				createAlert(containerId, "Sorry. Unable to proceed. Try again.");
			}
		}
	});
}
