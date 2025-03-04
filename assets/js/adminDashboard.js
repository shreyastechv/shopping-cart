function clearCategoryModal() {
	$("#categoryName").removeClass("border-danger");
	$("#categoryModalMsg").text("");
}

function processCategoryForm() {
	event.preventDefault();
	clearCategoryModal();

	let categoryId = $("#categoryId").val().trim();
	const categoryName = $("#categoryName");
	const categoryModalMsg = $("#categoryModalMsg");
	const valid = validateCategoryName(categoryName, "Category", categoryModalMsg);

	if(!valid) return false;

	$.ajax({
		type: "POST",
		url: "./components/productManagement.cfc",
		data: {
			method: "modifyCategory",
			categoryId: categoryId,
			categoryName: categoryName.val().trim()
		},
		success: function(response) {
			const result = JSON.parse(response);
			if (result.message == "Category Added") {
				Swal.fire({
					icon: "success",
					title: `Category Created`,
					showDenyButton: false,
					showCancelButton: false,
					confirmButtonText: "Ok",
					denyButtonText: "",
					allowOutsideClick: false,
					allowEscapeKey: false
				}).then((result) => {
					if (result.isConfirmed) {
						location.reload();
					}
				});
			}
			else if (result.message == "Category Updated") {
				Swal.fire({
					icon: "success",
					title: `Category Updated`,
					showDenyButton: false,
					showCancelButton: false,
					confirmButtonText: "Ok",
					denyButtonText: "",
					allowOutsideClick: false,
					allowEscapeKey: false
				}).then((result) => {
					if (result.isConfirmed) {
						location.reload();
					}
				});
			}
			else {
				categoryModalMsg.text(result.message);
			}
		},
		error: function () {
			categoryModalMsg.text("We encountered an error!");
		}
	});
}

function showAddCategoryModal() {
	clearCategoryModal();
	$("#categoryModalLabel").text("ADD CATEGORY");
	$("#categoryModalBtn").text("Save");
	$("#categoryId").val("");
	$("#categoryName").val("");
	$("#categoryName").attr("data-prevcategoryname", "");
}

function showEditCategoryModal(containerId, categoryId) {
	const categoryName = $(`#${containerId} [name='categoryName']`).text();
	clearCategoryModal();
	$("#categoryModalLabel").text("EDIT CATEGORY");
	$("#categoryModalBtn").text("Save Changes");
	$("#categoryId").val(categoryId);
	$("#categoryName").attr("data-prevcategoryname", categoryName);
	$("#categoryName").val(categoryName);
}

function deleteCategory(containerId, categoryId) {
	const categoryName = $(`#${containerId} [name='categoryName']`).text();

	Swal.fire({
		icon: "warning",
		title: `Delete category - '${categoryName}'?`,
		showDenyButton: false,
		showCancelButton: true,
		confirmButtonText: "Ok",
		denyButtonText: "Deny"
	}).then((result) => {
		if (result.isConfirmed) {
			$.ajax({
				type: "POST",
				url: "./components/productManagement.cfc",
				data: {
					method: "deleteItem",
					itemName: "category",
					itemId: categoryId
				},
				success: function() {
					$(`#${containerId}`).fadeOut(200, function() {
						$(this).remove();
					});
				}
			});
		}
	});
}

$(document).ready(function() {
	// Disable submit button if category name is empty or it is unchanged
	$("#categoryName").on("input", function() {
		const categoryName = $("#categoryName").val();
		const prevCategoryName = $("#categoryName").attr("data-prevcategoryname");
		$("#categoryModalMsg").text("");
		if (categoryName.trim().length == 0 || categoryName == prevCategoryName) {
			$("#categoryModalBtn").prop("disabled", true);
		} else {
			$("#categoryModalBtn").prop("disabled", false);
		}
	});
});
