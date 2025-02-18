const urlSort = new URLSearchParams(document.URL.split('?')[1]).get('sort');
const urlSearchTerm = new URLSearchParams(document.URL.split('?')[1]).get('search');
const urlSubCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('subCategoryId');
const urlMin = new URLSearchParams(document.URL.split('?')[1]).get('min');
const urlMax = new URLSearchParams(document.URL.split('?')[1]).get('max');
const limit = 6;
let offset = 0;

function createProduct(id, image, name, desc, price) {
	const newDiv = `
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
	`

	$("#products").append(newDiv);
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
			min: urlMin || "",
			max: urlMax || "",
			limit: limit,
			offset: offset,
			sort: urlSort || ""
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);

			// Loop over product data to get info we need
			for (let item of responseJSON.data) {
				// Create product div
				createProduct(item.productId, item.productImages.split(",")[0], item.productName, item.description, item.price);
			}

			// Remove view more btn if there are no products to be fetched
			if (!responseJSON.hasMoreRows) {
				$("#viewMoreBtn").hide();
				return;
			}

		}
	});
}

function toggleClearBtn() {
	const minVal = $("#min").val();
	const maxVal = $("#max").val();
	if (minVal == 0 && maxVal == 0) {
		$("#clearBtn").prop("disabled", true);
	} else {
		$("#clearBtn").prop("disabled", false);
	}
}

$(document).ready(function () {
	$("#min").on("input", function () {
		let minVal = $(this).val();
		$("#max").attr("min", minVal);
		toggleClearBtn();
	});

	$("#max").on("input", function () {
		toggleClearBtn();
	})

	$("#clearBtn").click(function () {
		$("#min, #max").val(0);
		$("#priceFilterForm").submit();
	});
});
