// const urlSubCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('subCategoryId');
const urlcategoryId = new URLSearchParams(document.URL.split('?')[1]).get('categoryId');

$(document).ready(function() {
	$("#categorySelect").change(function() {
		const categoryId = this.value;
		if (categoryId == 0) {
			$("#subCategorySelect").prop('disabled', true);
		}
		else {
			$("#subCategorySelect").prop("disabled", false);
			$.ajax({
				type: "POST",
				url: "./components/shoppingCart.cfc",
				data: {
					method: "getSubCategories",
					categoryId: categoryId
				},
				success: function(response) {
					const responseJSON = JSON.parse(response);
					$("#subCategorySelect").empty();
					responseJSON.data.forEach(function(item) {
						const optionTag = `<option value="${item.subCategoryId}">${item.subCategoryName}</option>`;
						$("#subCategorySelect").append(optionTag);
					});
					// if (categoryId == urlcategoryId) {
					// 	$("#subCategorySelect").val(urlSubCategoryId).change();
					// }
				}
			});
		}
	});
});

function processproductForm() {
	event.preventDefault();

	const productId= $("#productId").val();
	const categorySelect = $("#categorySelect").val();
	const subCategorySelect = $("#subCategorySelect").val();
	const brandSelect = $("#brandSelect").val();
	const productName = $("#productName").val().trim();
	const productDesc = $("#productDesc").val().trim();
	const brandName = $(`#brandSelect option[value='${brandSelect}']`).text();
	const productTax = $("#productTax").val().trim();
	const productPrice = $("#productPrice").val().trim();
	const productImage = $("#productImage")[0].files;
	let valid = true;

	// Reset Errors
	$(".error").text("");

	// Category Validation
	if (categorySelect == 0) {
		$("#categorySelectError").text("Select a category");
		valid = false;
	}

	// SubCategory Validation
	if (subCategorySelect == 0) {
		$("#subCategorySelectError").text("Select a subcategory");
		valid = false;
	}

	// Product Name Validation
	if (productName.length == 0) {
		$("#productNameError").text("Input a product name");
		valid = false;
	}

	// Brand Name Validation
	if (brandSelect == 0) {
		$("#brandSelectError").text("Select a brand");
		valid = false;
	}

	// Product Description Validation
	if (productDesc.length == 0) {
		$("#productDescError").text("Input a description");
		valid = false;
	}

	// Product Price Validation
	if (productPrice.length == 0) {
		$("#productPriceError").text("Input a price");
		valid = false;
	}

	// Product Tax Validation
	if (productTax.length == 0) {
		$("#productTaxError").text("Input tax");
		valid = false;
	}

	// Product Image Validation
	if (productId.length == 0 && productImage.length == 0) { // Validate product image only when adding products not when editing
		$("#productImageError").text("Select atleast one image");
		valid = false;
	}

	if (!valid) return false;

	const formData = new FormData($("#productForm")[0]);
	formData.append("categorySelect", categorySelect);
	formData.append("subCategorySelect", subCategorySelect);
	formData.append("brandSelect", brandSelect);
	formData.append("method", "modifyProduct");
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: formData,
		enctype: 'multipart/form-data',
		processData: false,
		contentType: false,
		success: function(response) {
			const responseJSON = JSON.parse(response);
			if(responseJSON.message == "Product Updated") {
				$(`#productName-${productId}`).text(productName);
				$(`#brandName-${productId}`).text(brandName);
				$(`#price-${productId}`).text(productPrice);
			}
			else if (responseJSON.message == "Product Added") {
				createProductItem(responseJSON.productId, productName, brandName, productPrice, responseJSON.defaultImageFile)
			}
			$("#productEditModalMsg").text(responseJSON.message);
		}
	});
}

function showAddProductModal() {
	$("#productForm")[0].reset();
	$(".error").text("");
	$("#productId").val("-1");
	// $("#categorySelect").val(urlcategoryId).change();
	$("#subCategoryModalBtn").text("Add Product");
}

function showEditProductModal(productId) {
	$(".error").text("");
	$("#productId").val(productId);
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "getProducts",
			productId: productId
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);
			const objProductData = responseJSON.data[0];

			$("#categorySelect").val(urlcategoryId).change();
			// $("#subCategorySelect").val(urlSubCategoryId).change();
			$("#productName").val(objProductData.productName);
			$("#brandSelect").val(objProductData.brandId).change();
			$("#productDesc").val(objProductData.description);
			$("#productPrice").val(objProductData.price);
			$("#productTax").val(objProductData.tax);
			$("#productImage").val("");
			$("#subCategoryModalBtn").text("Edit Product");
		}
	});
}

function deleteProduct (productId) {
	if (confirm("Delete product?")) {
		$.ajax({
			type: "POST",
			url: "./components/shoppingCart.cfc",
			data: {
				method: "deleteProduct",
				productId: productId
			},
			success: function() {
				$(`#productContainer-${productId}`).remove();
			}
		})
	}
}

function createProductItem(prodId, prodName, brand, price, imageFile) {
	const productItem = `
		<div id="productContainer-${prodId}" class="d-flex justify-content-between align-items-center border rounded-2 px-2">
			<div class="d-flex flex-column fs-5">
				<div id="productName-${prodId}" class="fw-bold">${prodName}</div>
				<div id="brandName-${prodId}" class="fw-semibold">${brand}</div>
				<div id="price-${prodId}" class="text-success">Rs.${price}</div>
			</div>
			<div>
				<button class="btn rounded-circle p-0 m-0 me-5" onclick="editDefaultImage(${prodId})">
					<div class="d-flex justify-content-center">
						<img class="pe-none" src="${productImageDirectory}${imageFile}" alt="Product Image" width="50">
					</div>
				</button>
				<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="#productEditModal" onclick="showEditProductModal(${prodId})">
					<i class="fa-solid fa-pen-to-square pe-none"></i>
				</button>
				<button class="btn btn-lg" onclick="deleteProduct(${prodId})">
					<i class="fa-solid fa-trash pe-none"></i>
				</button>
			</div>
		</div>
	`;
	$("#productMainContainer").append(productItem);
}

function createCarousel(productId) {
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "getProductImages",
			productId: productId
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);
			$("#carouselContainer").empty();
			for(let i=0; i<responseJSON.data.length; i++) {
				const isActive = i === 0 ? "active" : ""; // Set active for the first item
				const bottomDiv = responseJSON.data[i].defaultImage === 1 ? `
					<div class="text-center p-2">
						Default Image
					</div>
				`: `
					<div class="d-flex justify-content-center pt-3 gap-5">
						<button class="btn btn-success" onclick="setDefaultImage(${responseJSON.data[i].imageId})">Set as Default</button>
						<button class="btn btn-danger" onclick="deleteImage(${responseJSON.data[i].imageId})">Delete</button>
					</div>
				`;
				const carouselItem = `
					<div class="carousel-item ${isActive}" id="imageContainer_${responseJSON.data[i].imageId}">
						<div class="d-flex justify-content-center">
							<img src="${productImageDirectory}${responseJSON.data[i].imageFileName}" class="d-block h-100" alt="Product Image">
						</div>
						${bottomDiv}
					</div>
				`;
				$("#carouselContainer").append(carouselItem);
				$("#carouselContainer").attr("data-sc-productId", productId);
			}
		}
	});
}

function editDefaultImage(productId) {
	createCarousel(productId);
	$("#productImageModal").modal("show");
}

function setDefaultImage(imageId) {
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "setDefaultImage",
			imageId: imageId
		},
		success: function() {
			window.location.reload();
		}
	});
}

function deleteImage(imageId) {
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc",
		data: {
			method: "deleteImage",
			imageId: imageId
		},
		success: function() {
			const carousel = new bootstrap.Carousel($('#productImageCarousel'));
			carousel.next();
			$(`imageContainer_${imageId}`).parent().parent().remove();
		}
	});
}
