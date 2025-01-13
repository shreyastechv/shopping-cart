$(document).ready(function() {
	$("#categorySelect").change(function() {
		const categoryId = this.value;
		console.log(categoryId)
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
	const productId= "";
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
