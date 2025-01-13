function createCategoryItem(categoryId, categoryName) {
	const categoryItem = `
		<div class="d-flex justify-content-between align-items-center border rounded-2 px-2">
			<div id="categoryName-${categoryId}" class="fs-5">${categoryName}</div>
			<div>
				<button class="btn btn-lg" value="${categoryId}" data-bs-toggle="modal" data-bs-target="#categoryModal" onclick="showEditCategoryModal()">
					<i class="fa-solid fa-pen-to-square pe-none"></i>
				</button>
				<button class="btn btn-lg" value="${categoryId}" onclick="deleteCategory()">
					<i class="fa-solid fa-trash pe-none"></i>
				</button>
				<button class="btn btn-lg">
					<i class="fa-solid fa-chevron-right"></i>
				</button>
			</div>
		</div>
	`;
	$("#categoryMainContainer").append(categoryItem);
}

function clearCategoryModal() {
	$("#categoryName").removeClass("border-danger");
	$("#categoryModalMessage").text("");
}

function processCategoryForm() {
	clearCategoryModal();
	let categoryId = $("#categoryId").val().trim();
	const categoryName = $("#categoryName").val().trim();
	const prevCategoryName = $("#categoryName").attr("data-sc-prevCategoryName").trim();

	// Validation
	if (categoryName.length === 0) {
		$("#categoryName").addClass("border-danger");
		$("#categoryModalMessage").text("Category name should not be empty");
		return false;
	}
	else if (!/^[A-Za-z ]+$/.test(categoryName)) {
		$("#categoryName").addClass("border-danger");
		$("#categoryModalMessage").text("Category name should only contain letters!");
		return false;
	}
	else if (prevCategoryName && prevCategoryName === categoryName) {
		$("#categoryName").addClass("border-danger");
		$("#categoryModalMessage").text("Category name unchanged");
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
			$("#categoryModalMessage").addClass("text-success");
			$("#categoryModalMessage").removeClass("text-danger");
			$("#categoryModalMessage").text(responseJSON.message);
			if (responseJSON.message == "Category Added") {
				categoryId = responseJSON.categoryId;
				createCategoryItem(categoryId, categoryName);
			}
			else if (responseJSON.message == "Category Updated") {
				$("#categoryName-" + categoryId).text(categoryName);
			}
			else {
				$("#categoryModalMessage").removeClass("text-success");
				$("#categoryModalMessage").addClass("text-danger");
			}
		},
		error: function () {
			$("#categoryModalMessage").removeClass("text-success");
			$("#categoryModalMessage").addClass("text-danger");
			$("#categoryModalMessage").text("We encountered an error!");
		}
	});

	event.preventDefault();
}

function showAddCategoryModal() {
	clearCategoryModal();
	$("#categoryModalLabel").text("ADD CATEGORY");
	$("#categoryModalBtn").text("Add Category");
	$("#categoryId").val("");
	$("#categoryName").val("");
	$("#categoryName").attr("data-sc-prevCategoryName", "");
}

function showEditCategoryModal() {
	clearCategoryModal();
	$("#categoryModalLabel").text("EDIT CATEGORY");
	$("#categoryModalBtn").text("Edit Category");
	$("#categoryId").val(event.target.value);
	$("#categoryName").attr("data-sc-prevCategoryName", event.target.parentNode.parentNode.getElementsByTagName("div")[0].textContent);
	$("#categoryName").val(event.target.parentNode.parentNode.getElementsByTagName("div")[0].textContent);
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
