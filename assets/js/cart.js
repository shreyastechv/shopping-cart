// Disable decrement btn when quantity is 1
function handleQuantityChange(containerId) {
	let quantity = $(`#${containerId} input[name="quantity"]`).val();
	if (quantity == 1) {
		$(`#${containerId} [name="decBtn"]`).prop("disabled", true);
	} else {
		$(`#${containerId} [name="decBtn"]`).prop("disabled", false);
	}
}

function editCartItem(containerId, productId, action) {
	let quantity = $(`#${containerId} input[name="quantity"]`).val();
	if (action == "increment" && quantity == 5) {
		$("#maxQuantityAlert").removeClass("d-none");
		return;
	}
	if (action == "increment") {
		$(`#${containerId} input[name="quantity"]`).val(++quantity).change();
	}
	else if (action == "decrement") {
		$(`#${containerId} input[name="quantity"]`).val(--quantity).change();
	}
	else if (action == "delete") {
		$(`#${containerId}`).remove();
	}
	// $.ajax({
	// 	type: "POST",
	// 	url: "./components/shoppingCart.cfc",
	// 	data: {
	// 		method: "modifyCart",
	// 		productId: productId,
	// 		action: action
	// 	},
	// 	success: function() {
	// 	}
	// });
}