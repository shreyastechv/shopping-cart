const urlCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('categoryId');

function createSubCategoryItem(subCategoryId, subCategoryName) {
	const containerId = "subCategoryContainer_" + Math.floor(Math.random() * 1e9);;
	const subCategoryItem = `
		<div class="d-flex justify-content-between align-items-center border rounded-2 px-2" id="${containerId}">
			<div name="subCategoryName" class="fs-5">${subCategoryName}</div>
			<div>
				<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="#subCategoryModal" onclick="showEditSubCategoryModal('${containerId}', '${subCategoryId}')">
					<i class="fa-solid fa-pen-to-square pe-none"></i>
				</button>
				<button class="btn btn-lg" onclick="deleteSubCategory('${containerId}', '${subCategoryId}', '${subCategoryName}')">
					<i class="fa-solid fa-trash pe-none"></i>
				</button>
				<a class="btn btn-lg" href="/productEdit.cfm?subCategoryId=${encodeURIComponent(subCategoryId)}">
					<i class="fa-solid fa-chevron-right"></i>
				</a>
			</div>
		</div>
	`;
	$("#subCategoryMainContainer").append(subCategoryItem);
}

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
	const prevSubCategoryName = $("#subCategoryName").attr("data-sc-prevSubCategoryName").trim();
	const categoryId = $("#categorySelect").val().trim();
	let valid = true;

	// Category Select Validation
	if (categoryId < 1) {
		$("#categorySelect").addClass("border-danger");
		$("#categorySelectError").text("Select a category");
		valid = false;
	}

	// Subcategory Name Validation
	if (subCategoryName.length == 0) {
		$("#subCategoryName").addClass("border-danger");
		$("#subCategoryModalMsg").text("SubCategory name should not be empty");
		valid = false;
	}
	else if (!/^[A-Za-z'& ]+$/.test(subCategoryName)) {
		$("#subCategoryName").addClass("border-danger");
		$("#subCategoryModalMsg").text("SubCategory name should only contain letters!");
		valid = false;
	}
	else if (urlCategoryId == categoryId && prevSubCategoryName === subCategoryName) {
		$("#subCategoryName").addClass("border-danger");
		$("#subCategoryModalMsg").text("SubCategory name unchanged");
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
			const responseJSON = JSON.parse(response);
			$("#subCategoryModalMsg").addClass("text-success");
			$("#subCategoryModalMsg").removeClass("text-danger");
			$("#subCategoryModalMsg").text(responseJSON.message);
			if (responseJSON.message == "SubCategory Added") {
				subCategoryId = responseJSON.subCategoryId;
				if (categoryId == urlCategoryId) {
					createSubCategoryItem(subCategoryId, subCategoryName);
				}
			}
			else if (responseJSON.message == "SubCategory Updated") {
				location.reload();
			}
			else {
				$("#subCategoryModalMsg").removeClass("text-success");
				$("#subCategoryModalMsg").addClass("text-danger");
			}
		},
		error: function () {
			$("#subCategoryModalMsg").removeClass("text-success");
			$("#subCategoryModalMsg").addClass("text-danger");
			$("#subCategoryModalMsg").text("We encountered an error!");
		}
	});
}

function showAddSubCategoryModal() {
	clearSubCategoryModal();
	$("#subCategoryModalLabel").text("ADD SUBCATEGORY");
	$("#subCategoryModalBtn").text("Save");
	$("#categorySelect").val(urlCategoryId).change();
	$("#subCategoryId").val("");
	$("#subCategoryName").attr("data-sc-prevSubCategoryName", "");
	$("#subCategoryForm")[0].reset();
}

function showEditSubCategoryModal(containerId, subCategoryId) {
	const subCategoryName = $(`#${containerId} [name='subCategoryName']`).text();
	clearSubCategoryModal();
	$("#subCategoryModalLabel").text("EDIT SUBCATEGORY");
	$("#subCategoryModalBtn").text("Save Changes");
	$("#categorySelect").val(urlCategoryId).change();
	$("#subCategoryId").val(subCategoryId);
	$("#subCategoryName").attr("data-sc-prevSubCategoryName", subCategoryName);
	$("#subCategoryName").val(subCategoryName);
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
