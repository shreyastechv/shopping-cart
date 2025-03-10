const urlSubCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('subCategoryId');
let deletedImageIdArray = [];

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
				dataType: "json",
				data: {
					method: "getSubCategories",
					categoryId: categoryId
				},
				success: function(response) {
					$("#subCategorySelect").empty();
					response.data.forEach(function(item) {
						let optionTag = $(`<option value="${item.subCategoryId}">${item.subCategoryName}</option>`);
						if (item.subCategoryId == urlSubCategoryId) {
							optionTag.attr("selected", true);
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
		$(".newProductImage").remove();

		$.each(files, function (i, file) {
			if (file.type.startsWith("image/")) {
				dt.items.add(file);

				let imgDiv = $(`
					<div id="productImageContainer_${i}" class="newProductImage productImageContainer d-inline-block border p-1 mt-2 rounded text-center pw-100"
						onMouseOver="this.style.cursor='pointer'"
						onclick="$(this).children().find('input[name=defaultImageId]').prop('checked', true).trigger('change');"
					>
						<img src="${URL.createObjectURL(file)}" class="img-fluid h-80 border rounded">
						<div class="d-flex justify-content-around">
							<input type="radio" name="defaultImageId" value="${i+1}" checked>
							<button type="button" class="btn btn-sm" onclick="removeSelectedFile('productImageContainer_${i}', 'productImage', '${file.name}')">
								<i class="fa-solid fa-xmark pe-none"></i>
							</button>
						</div>
					</div>
				`);
				$("#uploadedProductImages").append(imgDiv);
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
	$("#productImage").change();
}

function processProductForm() {
	event.preventDefault();

	const productId= $("#productId").val().trim();
	const categorySelect = $("#categorySelect");
	const categorySelectError = $("#categorySelectError");
	const subCategorySelect = $("#subCategorySelect");
	const subCategorySelectError = $("#subCategorySelectError");
	const brandSelect = $("#brandSelect");
	const brandSelectError = $("#brandSelectError");
	const productName = $("#productName");
	const productNameError = $("#productNameError");
	const productDesc = $("#productDesc");
	const productDescError = $("#productDescError");
	const productTax = $("#productTax");
	const productTaxError = $("#productTaxError");
	const productPrice = $("#productPrice");
	const productPriceError = $("#productPriceError");
	const productImage = $("#productImage");
	const productImageError = $("#productImageError");
	let valid = true;

	// Reset Errors
	$(".productInput").removeClass("border-danger");
	$(".productImageContainer").removeClass("border-danger");
	$(".productError").text("");

	valid &= validateSelectTag(categorySelect, "Category", categorySelectError);
	valid &= validateSelectTag(subCategorySelect, "Sub category", subCategorySelectError);
	valid &= validateSelectTag(brandSelect, "Brand", brandSelectError);
	valid &= validateProductName(productName, productNameError);
	valid &= validateDescription(productDesc, productDescError);
	valid &= validatePrice(productPrice, productPriceError);
	valid &= validateTax(productTax, productTaxError);

	// Product Image Validation
	if(productId.trim().length == 0) {
		validateFileInput(productImage, "image", productImageError, 1)
	}

	// Default Image validation
	if ($("input[name='defaultImageId']:checked").is(":checked") == false) {
		$("#uploadedProductImages > div").addClass("border-danger");
		productImageError.text("Choose one image as default for the product!");
		valid = false;
	}

	if (!valid) return false;

	// Disable submit btn
	$("#subCategoryModalBtn").prop("disabled", true);

	const formData = new FormData($("#productForm")[0]);
	formData.append("subCategorySelect", subCategorySelect.val());
	formData.append("brandSelect", brandSelect.val());
	formData.append("deletedImageIdArray", JSON.stringify(deletedImageIdArray));
	formData.append("method", "modifyProduct");

	$.ajax({
		type: "POST",
		url: "./components/productManagement.cfc",
		dataType: "json",
		data: formData,
		enctype: 'multipart/form-data',
		processData: false,
		contentType: false,
		success: function(response) {
			const { message, success } = response;
			if(success) {
				Swal.fire({
					icon: "success",
					title: message,
					showDenyButton: false,
					showCancelButton: false,
					confirmButtonText: "Ok",
					denyButtonText: "Deny",
					allowOutsideClick: false,
					allowEscapeKey: false
				}).then((result) => {
					if (result.isConfirmed) {
						location.reload();
					}
				});
			} else {
				$("#productEditModalMsg").text(message);
			}
		}
	})
	.always(function() {
		// Enable submit btn back
		$("#subCategoryModalBtn").prop("disabled", false);
	});
}

function showAddProductModal(categoryId) {
	$("#productForm")[0].reset();
	$(".productInput").removeClass("border-danger");
	$(".productError").text("");
	$("#productId").val("");
	 $("#categorySelect").val(categoryId).change();
	$("#subCategoryModalLabel").text("ADD PRODUCT");
	$("#subCategoryModalBtn").text("Save");
	deletedImageIdArray = [];
	$("#uploadedProductImages").empty();
}

function showEditProductModal(categoryId, productId) {
	$(".productInput").removeClass("border-danger");
	$(".productError").text("");
	$("#productId").val(productId);
	$.ajax({
		type: "POST",
		url: "./components/dataFetch.cfc",
		dataType: "json",
		data: {
			method: "getProducts",
			productId: productId
		},
		success: function(response) {
			const objProductData = response.data[0];
			const productImages = objProductData.productImages;
			const productImageIds = objProductData.productImageIds;

			 $("#categorySelect").val(categoryId).change();
			$("#productName").val(objProductData.productName);
			$("#brandSelect").val(objProductData.brandId).change();
			$("#productDesc").val(objProductData.description);
			$("#productPrice").val(objProductData.price);
			$("#productTax").val(objProductData.tax);
			$("#productImage").val("");
			$("#subCategoryModalLabel").text("EDIT PRODUCT");
			$("#subCategoryModalBtn").text("Save Changes");
			deletedImageIdArray = [];
			$("#uploadedProductImages").empty();
			$.each(productImages, function (i, file) {
				let imgDiv = $(`
					<div id="uploadedProductImageContainer_${i}" class="productImageContainer d-inline-block border p-1 mt-2 rounded text-center pw-100"
						onMouseOver="this.style.cursor='pointer'"
						onclick="$(this).children().find('input[name=defaultImageId]').prop('checked', true).trigger('change');"
					>
						<img src="${productImageDirectory}${file}" class="img-fluid h-80 border rounded">
						<div class="d-flex justify-content-around">
							<input type="radio" name="defaultImageId" value="${productImageIds[i]}" ${i == 0 ? "checked" : ""}>
							<button type="button" class="btn btn-sm border-0" onclick="deleteImage('uploadedProductImageContainer_${i}', '${productImageIds[i]}')">
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
	Swal.fire({
		icon: "warning",
		title: "Delete Product ?",
		showDenyButton: false,
		showCancelButton: true,
		confirmButtonText: "Ok",
		denyButtonText: "Deny"
	}).then((result) => {
		if (result.isConfirmed) {
			$.ajax({
				type: "POST",
				url: "./components/productManagement.cfc",
				dataType: "json",
				data: {
					method: "deleteItem",
					itemName: "product",
					itemId: productId
				},
				success: function() {
					$(`#${containerId}`).remove();
				}
			})
		}
	});
}

function deleteImage(containerId, imageId) {
	event.stopPropagation(); // This is to prevent the image from getting selected as default
	deletedImageIdArray.push(imageId);
	$(`#${containerId}`).remove();
}
