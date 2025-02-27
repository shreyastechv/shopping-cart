const urlSort = new URLSearchParams(document.URL.split('?')[1]).get('sort');
const urlSearchTerm = new URLSearchParams(document.URL.split('?')[1]).get('search');
const urlSubCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('subCategoryId');
const urlMin = new URLSearchParams(document.URL.split('?')[1]).get('min');
const urlMax = new URLSearchParams(document.URL.split('?')[1]).get('max');
const limit = 6;
let offset = 0;

function createProduct(id, image, name, desc, price) {
	$(`
		<div class="col-sm-2 mb-4">
			<div class="card rounded-3 h-100 shadow"
				onclick="location.href='/productPage.cfm?productId=${encodeURIComponent(id)}'" role="button">
				<img src="${productImageDirectory}${image}" class="p-1 rounded-3"
					alt="Random Product Image">
				<div class="card-body">
					<div class="card-text fw-semibold mb-1">${name}</div>
					<div class="card-text text-secondary text-truncate mb-1">${desc}</div>
					<div class="card-text fw-bold mb-1">Rs. ${price}</div>
				</div>
			</div>
		</div>
	`).hide().appendTo("#products").fadeIn();
}

function viewMore() {
	// Increment offset to fetch next set of products
	offset += limit;

	$.ajax({
		type: "POST",
		url: "./components/dataFetch.cfc",
		data: {
			method: "getProducts",
			subCategoryId: urlSubCategoryId || "",
			searchTerm: urlSearchTerm || "",
			min: urlMin || 0,
			max: urlMax || 0,
			limit: limit,
			offset: offset,
			sort: urlSort || ""
		},
		success: function(response) {
			const result = JSON.parse(response);

			// Loop over product data to get info we need
			for (let item of result.data) {
				// Create product div
				createProduct(item.productId, item.productImages.split(",")[0], item.productName, item.description, item.price);
			}

			// Remove view more btn if there are no products to be fetched
			if (!result.hasMoreRows) {
				$("<div class='text-center text-secondary'>------  No more products  ------</div>").appendTo($("#viewMoreBtn").parent());
				$("#viewMoreBtn").remove();
			}
		}
	});
}

function clearFilter() {
	updateUrlParam({
		min: 0,
		max: 0
	});
}

function updateUrlParam(paramData) {
	const urlParams = new URLSearchParams(window.location.search);
	for (let urlParam in paramData) {
		if (paramData.hasOwnProperty(urlParam)) {
			urlParams.set(urlParam, paramData[urlParam]);
		}
	}
	window.location.href = window.location.pathname + '?' + urlParams.toString();
}

function applyFilter() {
	const min = $("#min").val();
	const max = $("#max").val();

	updateUrlParam({
		min: min,
		max: max
	});
}

function swapFilter() {
	const min = $("#min").val();
	const max = $("#max").val();

	$("#min").val(max).change();
	$("#max").val(min).change();
}

$(document).ready(function() {
	$('#sortSelect').on('change', function() {
		var selectedOption = $('#sortSelect option:selected').val();
		switch(selectedOption) {
			case "price-asc":
				updateUrlParam({ sort: "asc" });
				break;

			case "price-desc":
				updateUrlParam({ sort: "desc" });
				break;

			default:
				updateUrlParam({ sort: "" });
		}
	});
});
