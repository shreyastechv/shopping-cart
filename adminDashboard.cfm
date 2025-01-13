<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Dashboard - Shopping Cart</title>
		<link rel="icon" href="favicon.ico">
		<link href="assets/css/bootstrap.min.css" rel="stylesheet">
    </head>

    <body>
		<cfoutput>
			<!--- Get Data --->
			<cfset objShoppingCart = createObject("component", "components.shoppingCart")>
			<cfset qryCategories = objShoppingCart.getCategories()>

			<!--- Header --->
			<cfinclude template = "includes/header.cfm">

			<!--- Main Content --->
			<div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
				<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center">
					<div id="categoryMainContainer" class="bg-white col-md-8 p-4 rounded-end-4 w-100">
						<div class="d-flex justify-content-center align-items-center mb-4">
							<h3 class="fw-semibold text-center mb-0 me-3">CATEGORIES</h3>
							<button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="##categoryModal" onclick="showAddCategoryModal()">
								Add+
							</button>
						</div>
						<cfloop query="qryCategories">
							<div class="d-flex justify-content-between align-items-center border rounded-2 px-2">
								<div id="categoryName-#qryCategories.fldCategory_Id#" class="fs-5">#qryCategories.fldCategoryName#</div>
								<div>
									<button class="btn btn-lg" value="#qryCategories.fldCategory_Id#" data-bs-toggle="modal" data-bs-target="##categoryModal" onclick="showEditCategoryModal()">
										<i class="fa-solid fa-pen-to-square pe-none"></i>
									</button>
									<button class="btn btn-lg" value="#qryCategories.fldCategory_Id#" onclick="deleteCategory()">
										<i class="fa-solid fa-trash pe-none"></i>
									</button>
									<a class="btn btn-lg" href="subCategory.cfm?categoryId=#qryCategories.fldCategory_Id#&categoryName=#qryCategories.fldCategoryName#">
										<i class="fa-solid fa-chevron-right"></i>
									</a>
								</div>
							</div>
						</cfloop>
					</div>
				</div>
			</div>

			<!--- Category Modal --->
			<div class="modal fade" id="categoryModal">
			  <div class="modal-dialog">
				<div class="modal-content">
				  <div class="modal-header">
					<h1 class="modal-title fs-5" id="categoryModalLabel">Add Category</h1>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				  </div>
				  <form id="categoryForm" method="post" class="form-group" onsubmit="return processCategoryForm()">
					  <div class="modal-body">
					  	<input type="hidden" id="categoryId" name="categoryId" value="">
						<input type="text" id="categoryName" name="categoryName" placeholder="Category name" class="form-control">
						<div id="categoryModalMsg" class="mt-2"></div>
					  </div>
					  <div class="modal-footer">
						<button type="submit" id="categoryModalBtn" class="btn btn-primary">Add Category</button>
					  </div>
				  </form>
				</div>
			  </div>
			</div>
		</cfoutput>
		<cfinclude template="includes/scripts.cfm">
		<script src="assets/js/adminDashboard.js"></script>
    </body>
</html>
