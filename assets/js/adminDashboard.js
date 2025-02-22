function clearCategoryModal() {
	$("#categoryName").removeClass("border-danger");
	$("#categoryModalMsg").text("");
}

function processCategoryForm() {
	event.preventDefault();
	clearCategoryModal();

	let categoryId = $("#categoryId").val().trim();
	const categoryName = $("#categoryName").val().trim();
	let valid = true;

	// Validation
	if (!/^[A-Za-z'& ]+$/.test(categoryName)) {
		$("#categoryName").addClass("border-danger");
		$("#categoryModalMsg").addClass("text-danger");
		$("#categoryModalMsg").text("Category name should only contain letters, spaces, single quotes and ampersand symbol.");
		valid = false;
	}

	if(!valid) return false;

	$.ajax({
		type: "POST",
		url: "./components/productManagement.cfc",
		data: {
			method: "modifyCategory",
			categoryId: categoryId,
			categoryName: categoryName
		},
		success: function(response) {
			const responseJSON = JSON.parse(response);
			if (responseJSON.message == "Category Added") {
				Swal.fire({
					icon: "success",
					title: `Category Created`,
					showDenyButton: false,
					showCancelButton: false,
					confirmButtonText: "Ok",
					denyButtonText: ""
				}).then((result) => {
					if (result.isConfirmed) {
						location.reload();
					}
				});
			}
			else if (responseJSON.message == "Category Updated") {
				Swal.fire({
					icon: "success",
					title: `Category Updated`,
					showDenyButton: false,
					showCancelButton: false,
					confirmButtonText: "Ok",
					denyButtonText: ""
				}).then((result) => {
					if (result.isConfirmed) {
						location.reload();
					}
				});
			}
			else {
				$("#categoryModalMsg").removeClass("text-success");
				$("#categoryModalMsg").addClass("text-danger");
				$("#categoryModalMsg").text(responseJSON.message);
			}
		},
		error: function () {
			$("#categoryModalMsg").removeClass("text-success");
			$("#categoryModalMsg").addClass("text-danger");
			$("#categoryModalMsg").text("We encountered an error!");
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
					method: "deleteCategory",
					categoryId: categoryId
				},
				success: function() {
					$(`#${containerId}`).remove();
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
