// Disable decrement btn when quantity is 1
function handleQuantityChange(containerId) {
	let quantity = $(`#${containerId} input[name="quantity"]`).val();
	if (quantity == 1) {
		$(`#${containerId} button[name="decBtn"]`).prop("disabled", true);
	} else {
		$(`#${containerId} button[name="decBtn"]`).prop("disabled", false);
	}
}

function createAlert(containerId) {
	// Prevent more than one divs from being created
	if ($(`#${containerId} div[name="maxQuantityAlert"]`).length > 0) return;

	// Create div
	const alertDiv = `
		<div name="maxQuantityAlert" class="alert alert-warning alert-dismissible fade show m-2" role="alert">
			Maximum allowed quantity for this item is reached.
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
		createAlert(containerId);
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
		success: function() {
			if (action == "increment") {
				const oldPrice = parseFloat($(`#${containerId} span[name="price"]`).text());
				const newPrice = oldPrice * ((quantity+1)/quantity);

				const oldActualPrice = parseFloat($(`#${containerId} span[name="actualPrice"]`).text());
				const newActualPrice = oldActualPrice * ((quantity+1)/quantity);

				const oldTotalPrice = parseFloat($("#totalPrice").text());
				const newTotalPrice = oldTotalPrice + (oldPrice/quantity);

				const oldTotalActualPrice = parseFloat($("#totalActualPrice").text());
				const newTotalActualPrice = oldTotalActualPrice + (oldActualPrice/quantity);

				const newTotalTax = newTotalPrice - newTotalActualPrice;

				$(`#${containerId} span[name="price"]`).text(newPrice);
				$(`#${containerId} span[name="actualPrice"]`).text(newActualPrice);
				$("#totalPrice").text(newTotalPrice);
				$("#totalActualPrice").text(newTotalActualPrice);
				$("#totalTax").text(newTotalTax);
				$(`#${containerId} input[name="quantity"]`).val(quantity+1).change();
			}
			else if (action == "decrement") {
				const oldPrice = parseFloat($(`#${containerId} span[name="price"]`).text());
				const newPrice = oldPrice * ((quantity-1)/quantity);

				const oldActualPrice = parseFloat($(`#${containerId} span[name="actualPrice"]`).text());
				const newActualPrice = oldActualPrice * ((quantity-1)/quantity);

				const oldTotalPrice = parseFloat($("#totalPrice").text());
				const newTotalPrice = oldTotalPrice - (oldPrice/quantity);

				const oldTotalActualPrice = parseFloat($("#totalActualPrice").text());
				const newTotalActualPrice = oldTotalActualPrice - (oldActualPrice/quantity);

				const newTotalTax = newTotalPrice - newTotalActualPrice;

				$(`#${containerId} span[name="price"]`).text(newPrice);
				$(`#${containerId} span[name="actualPrice"]`).text(newActualPrice);
				$("#totalPrice").text(newTotalPrice);
				$("#totalActualPrice").text(newTotalActualPrice);
				$("#totalTax").text(newTotalTax);
				$(`#${containerId} input[name="quantity"]`).val(quantity-1).change();
			}
			else if (action == "delete") {
				$(`#${containerId}`).remove();
			}
		}
	});
}
