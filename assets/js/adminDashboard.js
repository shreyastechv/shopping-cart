function processCategoryForm() {
	const categoryName = $("#categoryName").val().trim();

	$("#categoryName").removeClass("border-danger bg-danger-subtle");
	if (categoryName.length === 0) {
		$("#categoryName").addClass("border-danger bg-danger-subtle");
		$("#categoryNameError").text("Category name should not be empty");
		return false;
	}
	else if (!/^[A-Za-z]+$/.test(categoryName)) {
		$("#categoryName").addClass("border-danger bg-danger-subtle");
		$("#categoryNameError").text("Category name should only contain letters!");
		return false;
	}

	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc?method=addCategory",
		data: {
			categoryName: $("#categoryName").val()
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);
			$("#categoryNameError").text(responseJSON.message);
			if (responseJSON.message == "Category Added") {
				location.reload();
			}
		},
		error: function () {
			$("#categoryNameError").text("We encountered an error!");
		}
	});
}

function showAddCategoryModal() {
	$("#categoryModalLabel").text("ADD CATEGORY");
	$("#categoryId").val("");
}