function createCategoryDiv(categoryId, categoryName) {
	// Create the main container div with classes
	const containerDiv = document.createElement("div");
	containerDiv.classList.add("d-flex", "justify-content-between", "align-items-center", "border", "rounded-2", "px-2");

	// Create the category name div
	const categoryNameDiv = document.createElement("div");
	categoryNameDiv.classList.add("fs-5");
	categoryNameDiv.id = `categoryName-${categoryId}`;
	categoryNameDiv.textContent = categoryName;

	// Append categoryNameDiv to the container
	containerDiv.appendChild(categoryNameDiv);

	// Create the div for buttons
	const buttonDiv = document.createElement("div");

	// Create the edit button
	const editButton = document.createElement("button");
	editButton.classList.add("btn", "btn-lg");
	editButton.value = categoryId;
	editButton.setAttribute("data-bs-toggle", "modal");
	editButton.setAttribute("data-bs-target", "#categoryModal");
	editButton.setAttribute("onclick", "showEditCategoryModal()");

	const editIcon = document.createElement("i");
	editIcon.classList.add("fa-solid", "fa-pen-to-square", "pe-none");
	editButton.appendChild(editIcon);

	// Append the edit button to the button container
	buttonDiv.appendChild(editButton);

	// Create the delete button
	const deleteButton = document.createElement("button");
	deleteButton.classList.add("btn", "btn-lg");
	deleteButton.value = categoryId;
	deleteButton.setAttribute("onclick", "deleteCategory()");

	const deleteIcon = document.createElement("i");
	deleteIcon.classList.add("fa-solid", "fa-trash", "pe-none");
	deleteButton.appendChild(deleteIcon);

	// Append the delete button to the button container
	buttonDiv.appendChild(deleteButton);

	// Create the chevron-right button
	const chevronButton = document.createElement("button");
	chevronButton.classList.add("btn", "btn-lg");

	const chevronIcon = document.createElement("i");
	chevronIcon.classList.add("fa-solid", "fa-chevron-right");
	chevronButton.appendChild(chevronIcon);

	// Append the chevron button to the button container
	buttonDiv.appendChild(chevronButton);

	// Append buttonDiv to the containerDiv
	containerDiv.appendChild(buttonDiv);

	// Append the containerDiv to the desired parent element
	document.getElementById("categoryMainContainer").appendChild(containerDiv);
}

function processCategoryForm() {
	const categoryId = $("#categoryId").val().trim();
	const categoryName = $("#categoryName").val().trim();

	$("#categoryName").removeClass("border-danger bg-danger-subtle");
	if (categoryName.length === 0) {
		$("#categoryName").addClass("border-danger bg-danger-subtle");
		$("#categoryNameError").text("Category name should not be empty");
		return false;
	}
	else if (!/^[A-Za-z ]+$/.test(categoryName)) {
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
				createCategoryDiv(categoryId, categoryName);
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