const urlCategoryId = new URLSearchParams(document.URL.split('?')[1]).get('categoryId');
const urlCategoryName = new URLSearchParams(document.URL.split('?')[1]).get('categoryName');

function createSubCategoryItem(subCategoryId, subCategoryName) {
	const subCategoryItem = `
		<div class="d-flex justify-content-between align-items-center border rounded-2 px-2">
			<div id="subCategoryName-${subCategoryId}" class="fs-5">${subCategoryName}</div>
			<div>
				<button class="btn btn-lg" value="${subCategoryId}" data-bs-toggle="modal" data-bs-target="#subCategoryModal" onclick="showEditSubCategoryModal()">
					<i class="fa-solid fa-pen-to-square pe-none"></i>
				</button>
				<button class="btn btn-lg" value="${subCategoryId}" onclick="deleteSubCategory()">
					<i class="fa-solid fa-trash pe-none"></i>
				</button>
				<a class="btn btn-lg" href="productEdit.cfm?subCategoryId=${subCategoryId}&subCategoryName=${subCategoryName}&categoryId=${urlCategoryId}&categoryName=${urlCategoryName}">
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
	if (subCategoryName.length === 0) {
		$("#subCategoryName").addClass("border-danger");
		$("#subCategoryModalMsg").text("SubCategory name should not be empty");
		valid = false;
	}
	else if (!/^[A-Za-z ]+$/.test(subCategoryName)) {
		$("#subCategoryName").addClass("border-danger");
		$("#subCategoryModalMsg").text("SubCategory name should only contain letters!");
		valid = false;
	}
	else if (urlCategoryId === categoryId && prevSubCategoryName === subCategoryName) {
		$("#subCategoryName").addClass("border-danger");
		$("#subCategoryModalMsg").text("SubCategory name unchanged");
		valid = false;
	}

	if (!valid) return false;

	$.ajax({
		type: "POST",
		url: "./components/shoppingCart.cfc?method=modifySubCategory",
		data: {
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
				if (categoryId === urlCategoryId) {
					createSubCategoryItem(subCategoryId, subCategoryName);
				}
			}
			else if (responseJSON.message == "SubCategory Updated") {
				if (categoryId === urlCategoryId) {
					$("#subCategoryName-" + subCategoryId).text(subCategoryName);
				}
				else {
					$("#subCategoryName-" + subCategoryId).parent().remove();
				}
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

	event.preventDefault();
}

function showAddSubCategoryModal() {
	clearSubCategoryModal();
	$("#subCategoryModalLabel").text("ADD CATEGORY");
	$("#subCategoryModalBtn").text("Add SubCategory");
	$("#subCategoryId").val("");
	$("#subCategoryName").attr("data-sc-prevSubCategoryName", "");
	$("#subCategoryForm")[0].reset();
}

function showEditSubCategoryModal(categoryId) {
	const subCategoryName = $("#subCategoryName-" + subCategoryId).text();
	clearSubCategoryModal();
	$("#subCategoryModalLabel").text("EDIT CATEGORY");
	$("#subCategoryModalBtn").text("Edit SubCategory");
	$("#subCategoryId").val(subCategoryId);
	$("#subCategoryName").attr("data-sc-prevSubCategoryName", subCategoryName);
	$("#subCategoryName").val(subCategoryName);
}

function deleteSubCategory(subCategoryId) {
	const subCategoryName = $("#subCategoryName-" + subCategoryId).text();
	if (confirm(`Delete subCategory - '${subCategoryName}'?`)) {
		$.ajax({
			type: "POST",
			url: "./components/shoppingCart.cfc?method=deleteSubCategory",
			data: {
				subCategoryId: subCategoryId
			},
			success: function() {
				$("#subCategoryName-" + subCategoryId).parent().remove();
			}
		});
	}
}
