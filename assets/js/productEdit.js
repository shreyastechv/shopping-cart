const urlSubCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('subCategoryId');
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
				url: "./components/shoppingCart.cfc?method=getSubCategories",
				data: {
					categoryId: categoryId
				},
				success: function(response) {
					const responseJSON = JSON.parse(response);
					$("#subCategorySelect").empty();
					for(let i=0; i<responseJSON.DATA.length; i++) {
						const subCategoryId = responseJSON.DATA[i][0];
						const subCategoryName = responseJSON.DATA[i][1];
						const optionTag = `<option value="${subCategoryId}">${subCategoryName}</option>`;
						$("#subCategorySelect").append(optionTag);
					}
				}
			});
		}
	});
});

function processproductForm() {
	const productId= $("#productId").val();
	const categorySelect = $("#categorySelect").val();
	const subCategorySelect = $("#subCategorySelect").val();
	const brandSelect = $("#brandSelect").val();
	const formData = new FormData($("#productForm")[0]);
	formData.append("productId", productId);
	formData.append("categorySelect", categorySelect);
	formData.append("subCategorySelect", subCategorySelect);
	formData.append("brandSelect", brandSelect);
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc?method=modifyProduct",
		data: formData,
		enctype: 'multipart/form-data',
		processData: false,
		contentType: false,
		success: function(response) {
			const responseJSON = JSON.parse(response);
			console.log(responseJSON);
		}
	});
	event.preventDefault();
}

function showAddProductModal() {
	$("#productForm")[0].reset();
	$(".error").hide();
	$("#productId").val("");
	$("#categorySelect").val(urlcategoryId).change();
	$("#subCategorySelect").val(urlSubCategoryId).change();
	$("#subCategoryModalBtn").text("Add Product");
}

function showEditProductModal() {
	const productId = event.target.value;
	$(".error").hide();
	$("#productId").val(productId);
	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc?method=getProducts",
		data: {
			subCategoryId: urlSubCategoryId,
			productId: productId
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);
			const objProductData = {};
			for(let i=0; i<responseJSON.COLUMNS.length; i++) {
				objProductData[responseJSON.COLUMNS[i]] =responseJSON.DATA[0][i]
			}

			$("#categorySelect").val(urlcategoryId).change();
			$("#subCategorySelect").val(urlSubCategoryId).change();
			$("#productName").val(objProductData['FLDPRODUCTNAME']);
			$("#brandSelect").val(objProductData['FLDBRANDID']).change();
			$("#productDesc").val(objProductData['FLDDESCRIPTION']);
			$("#productPrice").val(objProductData['FLDPRICE']);
			$("#productTax").val(objProductData['FLDTAX']);
			$("#subCategoryModalBtn").text("Edit Product");
		}
	});
}

function deleteProduct () {
	const productId = event.target.value;
	console.log(productId)
	if (confirm("Delete product?")) {
		$.ajax({
			type: "POST",
			url: "./components/shoppingCart.cfc?method=deleteProduct",
			data: {
				productId: productId
			},
			success: function() {
				$(`#productContainer-${productId}`).remove();
			}
		})
	}
}