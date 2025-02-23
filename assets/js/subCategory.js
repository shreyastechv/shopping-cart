const urlCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('categoryId');

$(document).ready(function () {
	// Disable submit button if subcategory name and category id is empty or it is unchanged
	$("#subCategoryName, #categorySelect").on("input", function() {
		const categoryId = $("#categorySelect").val().trim();
		const subCategoryName = $("#subCategoryName").val().trim();
		const prevCategoryId = $("#categorySelect").attr("data-categoryid").trim();
		const prevSubCategoryName = $("#subCategoryName").attr("data-subcategoryname").trim();
		if (categoryId == 0 || subCategoryName.length == 0 || (categoryId == prevCategoryId && subCategoryName == prevSubCategoryName)) {
			$("#subCategoryModalBtn").prop("disabled", true);
		} else {
			$("#subCategoryModalBtn").prop("disabled", false);
		}
	});
});

function clearSubCategoryModal() {
	$("#categorySelect").removeClass("border-danger");
	$("#categorySelectError").text("");
	$("#subCategoryName").removeClass("border-danger");
	$("#subCategoryModalMsg").text("");
	$("#subCategoryModalMsg").removeClass("text-success");
	$("#subCategoryModalMsg").addClass("text-danger");
}

function processSubCategoryForm() {
	event.preventDefault();
	clearSubCategoryModal();
	let subCategoryId = $("#subCategoryId").val().trim();
	const subCategoryName = $("#subCategoryName").val().trim();
	const prevSubCategoryName = $("#subCategoryName").attr("data-subcategoryname").trim();
	const categoryId = $("#categorySelect").val().trim();
	let valid = true;

	// Subcategory Name Validation
	if (!/^[A-Za-z'& ]+$/.test(subCategoryName)) {
		$("#subCategoryName").addClass("border-danger");
		$("#subCategoryModalMsg").text("SubCategory name should only contain letters!");
		valid = false;
	}

	if (!valid) return false;

	$.ajax({
		type: "POST",
		url: "./components/productManagement.cfc",
		data: {
			method: "modifySubCategory",
			subCategoryId: subCategoryId,
			subCategoryName: subCategoryName,
			categoryId: categoryId
		},
		success: function(response) {
			const { message, success } = JSON.parse(response);
			if(success) {
				Swal.fire({
					icon: "warning",
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
				$("#subCategoryModalMsg").text(result.message);
			}
		},
		error: function () {
			$("#subCategoryModalMsg").text("We encountered an error!");
		}
	});
}

function showAddSubCategoryModal() {
	clearSubCategoryModal();
	$("#subCategoryModalLabel").text("ADD SUBCATEGORY");
	$("#subCategoryModalBtn").text("Save");
	$("#categorySelect").val(urlCategoryId).attr("data-categoryid", "").change();
	$("#subCategoryId").val("");
	$("#subCategoryName").attr("data-subcategoryname", "");
	$("#subCategoryForm")[0].reset();
}

function showEditSubCategoryModal(containerId, subCategoryId) {
	const subCategoryName = $(`#${containerId} [name='subCategoryName']`).text();
	clearSubCategoryModal();
	$("#subCategoryModalLabel").text("EDIT SUBCATEGORY");
	$("#subCategoryModalBtn").text("Save Changes");
	$("#categorySelect").val(urlCategoryId).attr("data-categoryid", urlCategoryId).change();
	$("#subCategoryId").val(subCategoryId);
	$("#subCategoryName").val(subCategoryName).attr("data-subcategoryname", subCategoryName);
}

function deleteSubCategory(containerId, subCategoryId, subCategoryName) {
	Swal.fire({
		icon: "warning",
		title: `Delete subCategory - '${subCategoryName}'?`,
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
					method: "deleteSubCategory",
					subCategoryId: subCategoryId
				},
				success: function() {
					$(`#${containerId}`).remove();
				}
			});
		}
	});
}
