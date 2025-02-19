const urlSubCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('subCategoryId');

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
				url: "./components/dataFetch.cfc",
				data: {
					method: "getSubCategories",
					categoryId: categoryId
				},
				success: function(response) {
					const responseJSON = JSON.parse(response);
					$("#subCategorySelect").empty();
					responseJSON.data.forEach(function(item) {
						let optionTag;
						if (item.subCategoryId == urlSubCategoryId) {
							optionTag = `<option value="${item.subCategoryId}" selected>${item.subCategoryName}</option>`;
						} else {
							optionTag = `<option value="${item.subCategoryId}">${item.subCategoryName}</option>`;
						}
						$("#subCategorySelect").append(optionTag);
					});
				}
			});
		}
	});

	$("#productImage").on("change", function () {
		let files = this.files;
		let dt = new DataTransfer();
		let previewContainer = $("#productImagePreview").empty();

		$.each(files, function (i, file) {
			if (file.type.startsWith("image/")) {
				dt.items.add(file);

				let imgDiv = $(`
					<div id="productImageContainer_${i}" class="d-inline-block border p-2 rounded text-center pw-100 mt-3">
						<img src="${URL.createObjectURL(file)}" class="img-fluid mb-2 h-75">
						<div class="d-flex justify-content-around">
							<input type="radio" name="defaultImageId" value="${i+1}" checked>
							<button type="button" class="btn btn-sm" onclick="removeSelectedFile('productImageContainer_${i}', 'productImage', '${file.name}')">
								<i class="fa-solid fa-xmark pe-none"></i>
							</button>
						</div>
					</div>
                `);
				previewContainer.append(imgDiv);
			}
		});

		this.files = dt.files;
	});
});

function removeSelectedFile(containerId, inputId, fileName) {
	let files = $(`#${inputId}`)[0].files;
	let dt = new DataTransfer();

	$.each(files, function (i, file) {
		if (file.name != fileName) {
			dt.items.add(file);
		}
	});

	$(`#${inputId}`)[0].files = dt.files;
	$(`#${containerId}`).remove();
}

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
	if (productId.length == 0 && (productImage.length == 0 || $('input[name="defaultImageId"]:checked').is(":checked") == false)) { // Validate product image only when adding products not when editing
		$("#productImageError").text("Select atleast one image");
		valid = false;
	}

	if (!valid) return false;

	const formData = new FormData($("#productForm")[0]);
	formData.append("subCategorySelect", subCategorySelect);
	formData.append("brandSelect", brandSelect);
	formData.append("method", "modifyProduct");

	$.ajax({
		type: "POST",
		url: "./components/productManagement.cfc",
		data: formData,
		enctype: 'multipart/form-data',
		processData: false,
		contentType: false,
		success: function(response) {

			const responseJSON = JSON.parse(response);
			if(responseJSON.message == "Product Updated") {
				location.reload();
			}
			else if (responseJSON.message == "Product Added") {
				createProductItem(responseJSON.productId, productName, brandName, productPrice, responseJSON.defaultImageFile)
			}
			$("#productEditModalMsg").text(responseJSON.message);
		}
	});
}

function showAddProductModal(categoryId) {
	$("#productForm")[0].reset();
	$(".error").text("");
	$("#productId").val("");
	 $("#categorySelect").val(categoryId).change();
	$("#subCategoryModalLabel").text("ADD PRODUCT");
	$("#subCategoryModalBtn").text("Save");
	$("#productImagePreview").empty();
	$("#uploadedProductImages").empty();
}

function showEditProductModal(categoryId, productId) {
	$(".error").text("");
	$("#productId").val(productId);
	$.ajax({
		type: "POST",
		url: "./components/dataFetch.cfc",
		data: {
			method: "getProducts",
			productId: productId
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);
			const objProductData = responseJSON.data[0];
			const productImages = objProductData.productImages.split(",");
			const productImageIds = objProductData.productImageIds.split(",");

			 $("#categorySelect").val(categoryId).change();
			$("#productName").val(objProductData.productName);
			$("#brandSelect").val(objProductData.brandId).change();
			$("#productDesc").val(objProductData.description);
			$("#productPrice").val(objProductData.price);
			$("#productTax").val(objProductData.tax);
			$("#productImage").val("");
			$("#subCategoryModalLabel").text("EDIT PRODUCT");
			$("#subCategoryModalBtn").text("Save Changes");
			$("#productImagePreview").empty();
			$("#uploadedProductImages").empty();
			$.each(productImages, function (i, file) {
				let imgDiv = $(`
					<div id="uploadedProductImageContainer_${i}" class="d-inline-block border p-2 rounded text-center pw-100 ph-150 mt-3">
						<img src="${productImageDirectory}${file}" class="img-fluid mb-2 h-75">
						<div class="d-flex justify-content-around">
							<input type="radio" name="defaultImageId" value="${productImageIds[i]}" ${i == 0 ? "checked" : ""}>
							<button type="button" class="btn btn-sm ${i == 0 ? 'd-none' : ''}" onclick="deleteImage('uploadedProductImageContainer_${i}', '${productImageIds[i]}')">
								<i class="fa-solid fa-xmark pe-none"></i>
							</button>
						</div>
					</div>
				`);
				$("#uploadedProductImages").append(imgDiv);
			});
		}
	});
}

function deleteProduct (containerId, productId) {
	if (confirm("Delete product?")) {
		$.ajax({
			type: "POST",
			url: "./components/productManagement.cfc",
			data: {
				method: "deleteProduct",
				productId: productId
			},
			success: function() {
				$(`#${containerId}`).remove();
			}
		})
	}
}

function createProductItem(prodId, prodName, brand, price, imageFile) {
	const containerId = "productContainer_" + Math.floor(Math.random() * 1e9);;
	const productItem = `
		<div id="${containerId}" class="d-flex justify-content-between align-items-center border rounded-2 px-2">
			<div class="d-flex flex-column fs-5">
				<div name="productName" class="fw-bold">${prodName}</div>
				<div name="brandName" class="fw-semibold">${brand}</div>
				<div name="price" class="text-success">Rs.${price}</div>
			</div>
			<div class="d-flex gap-4">
				<img src="${productImageDirectory}${imageFile}" alt="Product Image" width="50">
				<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="#productEditModal" onclick="showEditProductModal('${containerId}', '${prodId}')">
					<i class="fa-solid fa-pen-to-square pe-none"></i>
				</button>
				<button class="btn btn-lg" onclick="deleteProduct('${containerId}', '${prodId}')">
					<i class="fa-solid fa-trash pe-none"></i>
				</button>
			</div>
		</div>
	`;
	$("#productMainContainer").append(productItem);
}

function deleteImage(containerId, imageId) {
	$.ajax({
		type: "POST",
		url: "./components/productManagement.cfc",
		data: {
			method: "deleteImage",
			imageId: imageId
		},
		success: function() {
			$(`#${containerId}`).remove();
		}
	});
}
