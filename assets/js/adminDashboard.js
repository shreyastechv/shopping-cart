function createCategoryItem(categoryId, categoryName) {
	const containerId = "categoryContainer_" + Math.floor(Math.random() * 1e9);;
	const categoryItem = `
		<div class="d-flex justify-content-between align-items-center border rounded-2 px-2" id="${containerId}">
			<div name="categoryName" class="fs-5">${categoryName}</div>
			<div>
				<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="#categoryModal" onclick="showEditCategoryModal('${containerId}', '${categoryId}')">
					<i class="fa-solid fa-pen-to-square pe-none"></i>
				</button>
				<button class="btn btn-lg" onclick="deleteCategory('${containerId}', '${categoryId}')">
					<i class="fa-solid fa-trash pe-none"></i>
				</button>
				<a class="btn btn-lg" href="/subCategory.cfm?categoryId=${encodeURIComponent(categoryId)}">
					<i class="fa-solid fa-chevron-right"></i>
				</a>
			</div>
		</div>
	`;
	$("#categoryMainContainer").append(categoryItem);
}

function clearCategoryModal() {
	$("#categoryName").removeClass("border-danger");
	$("#categoryModalMsg").text("");
}

function processCategoryForm() {
	event.preventDefault();
	clearCategoryModal();
	let categoryId = $("#categoryId").val().trim();
	const categoryName = $("#categoryName").val().trim();
	const prevCategoryName = $("#categoryName").attr("data-sc-prevCategoryName").trim();
	let valid = true;

	// Validation
	if (categoryName.length == 0) {
		$("#categoryName").addClass("border-danger");
		$("#categoryModalMsg").text("Category name should not be empty");
		valid = false;
	}
	else if (!/^[A-Za-z'& ]+$/.test(categoryName)) {
		$("#categoryName").addClass("border-danger");
		$("#categoryModalMsg").text("Category name should only contain letters!");
		valid = false;
	}
	else if (prevCategoryName == categoryName) {
		$("#categoryName").addClass("border-danger");
		$("#categoryModalMsg").text("Category name unchanged");
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
			$("#categoryModalMsg").addClass("text-success");
			$("#categoryModalMsg").removeClass("text-danger");
			$("#categoryModalMsg").text(responseJSON.message);
			if (responseJSON.message == "Category Added") {
				categoryId = responseJSON.categoryId;
				createCategoryItem(categoryId, categoryName);
			}
			else if (responseJSON.message == "Category Updated") {
				location.reload();
			}
			else {
				$("#categoryModalMsg").removeClass("text-success");
				$("#categoryModalMsg").addClass("text-danger");
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
	$("#categoryModalBtn").text("Add Category");
	$("#categoryId").val("");
	$("#categoryName").val("");
	$("#categoryName").attr("data-sc-prevCategoryName", "");
}

function showEditCategoryModal(containerId, categoryId) {
	const categoryName = $(`#${containerId} [name='categoryName']`).text();
	clearCategoryModal();
	$("#categoryModalLabel").text("EDIT CATEGORY");
	$("#categoryModalBtn").text("Edit Category");
	$("#categoryId").val(categoryId);
	$("#categoryName").attr("data-sc-prevCategoryName", categoryName);
	$("#categoryName").val(categoryName);
}

function deleteCategory(containerId, categoryId) {
	const categoryName = $(`#${containerId} [name='categoryName']`).text();
	if (confirm(`Delete category - '${categoryName}'?`)) {
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
}
