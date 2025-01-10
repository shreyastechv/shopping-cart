function processCategoryForm() {
	const categoryId = $("#categoryId").val().trim();
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
		url: "./components/shoppingCart.cfc?method=modifyCategory",
		data: {
			categoryId: categoryId,
			categoryName: categoryName
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);
			$("#categoryNameError").addClass("text-success");
			$("#categoryNameError").removeClass("text-danger");
			$("#categoryNameError").text(responseJSON.message);
			if (responseJSON.message == "Category Added") {
				// location.reload();
			}
			else if (responseJSON.message == "Category Updated") {
				$("#categoryName-" + categoryId).text(categoryName);
			}
		},
		error: function () {
			$("#categoryNameError").removeClass("text-success");
			$("#categoryNameError").addClass("text-danger");
			$("#categoryNameError").text("We encountered an error!");
		}
	});

	event.preventDefault();
}

function showAddCategoryModal() {
	$("#categoryModalLabel").text("ADD CATEGORY");
	$("#categoryModalBtn").text("Add Category");
	$("#categoryId").val("");
	$("#categoryName").val("");
}

function showEditCategoryModal() {
	$("#categoryModalLabel").text("EDIT CATEGORY");
	$("#categoryModalBtn").text("Edit Category");
	$("#categoryId").val(event.target.value);
	$("#categoryName").val(event.target.parentNode.parentNode.childNodes[1].textContent);
}

function deleteCategory() {
	const deleteBtn = event.target;
	if (confirm(`Delete contact '${event.target.parentNode.parentNode.childNodes[1].textContent}'?`)) {
		$.ajax({
			type: "POST",
			url: "./components/shoppingCart.cfc?method=deleteCategory",
			data: {
				categoryId: deleteBtn.value
			},
			success: function() {
				deleteBtn.parentNode.parentNode.remove();
			}
		});
	}
}