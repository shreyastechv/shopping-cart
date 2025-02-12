const limit = 6;
let offset = 0;

function createProduct(id, image, name, desc, price) {
	const newDiv = `
		<div class="col-sm-2 mb-4">
			<div class="card rounded-3 h-100 shadow"
				onclick="location.href='/productPage.cfm?${id}'" role="button">
				<img src="${productImageDirectory}${image}" class="p-1 rounded-3"
					alt="Random Product Image">
				<div class="card-body">
					<div class="card-text fw-semibold mb-1">${name}</div>
					<div class="card-text text-secondary text-truncate mb-1">${desc}</div>
					<div class="card-text fw-bold mb-1">Rs. ${price}</div>
				</div>
			</div>
		</div>
	`

	$("#products").append(newDiv);
}

function viewMore(subCategoryId) {
	// Increment offset to fetch next set of products
	offset += limit;

	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "getProducts",
			subCategoryId: subCategoryId,
			limit: limit,
			offset: offset
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);

			// Loop over product data to get info we need
			for (let item of responseJSON.data) {
				// Create product div
				createProduct(item.productId, item.productImage, item.productName, item.description, item.price);
			}

			// Remove view more btn if there are no products to be fetched
			if (responseJSON.DATA.length < limit) {
				$("#viewMoreBtn").hide();
				return;
			}

		}
	});
}
