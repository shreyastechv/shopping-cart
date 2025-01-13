<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sub Category - Shopping Cart</title>
		<link rel="icon" href="favicon.ico">
		<link href="assets/css/bootstrap.min.css" rel="stylesheet">
    </head>

    <body>
		<cfoutput>
			<!--- URL params --->
			<cfparam  name="url.categoryId" default="0">
			<cfparam  name="url.categoryName" default="Sub Categories">
			<cfif url.categoryId LT 1>
				<cflocation  url="adminDashboard.cfm" addToken="false">
			</cfif>

			<!--- Get Data --->
			<cfset objShoppingCart = createObject("component", "components.shoppingCart")>
			<cfset qryCategories = objShoppingCart.getCategories()>
			<cfset qrySubCategories = objShoppingCart.getSubCategories(categoryId = url.categoryId)>

			<!--- Header --->
			<cfinclude template = "includes/header.cfm">

			<!--- Main Content --->
			<div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
				<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center">
					<div id="subCategoryMainContainer" class="bg-white col-md-8 p-4 rounded-end-4 w-100">
						<div class="d-flex justify-content-between align-items-center mb-4">
							<a href="adminDashboard.cfm" class="btn">
								<i class="fa-solid fa-chevron-left"></i>
							</a>
							<div class="d-flex">
								<h3 class="fw-semibold text-center mb-0 me-3">#url.categoryName#</h3>
								<button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="##subCategoryModal" onclick="showAddSubCategoryModal()">
									Add+
								</button>
							</div>
							<div></div>
						</div>
						<cfloop query="qrySubCategories">
							<div class="d-flex justify-content-between align-items-center border rounded-2 px-2">
								<div id="subCategoryName-#qrySubCategories.fldSubCategory_Id#" class="fs-5">#qrySubCategories.fldSubCategoryName#</div>
								<div>
									<button class="btn btn-lg" value="#qrySubCategories.fldSubCategory_Id#" data-bs-toggle="modal" data-bs-target="##subCategoryModal" onclick="showEditSubCategoryModal()">
										<i class="fa-solid fa-pen-to-square pe-none"></i>
									</button>
									<button class="btn btn-lg" value="#qrySubCategories.fldSubCategory_Id#" onclick="deleteSubCategory()">
										<i class="fa-solid fa-trash pe-none"></i>
									</button>
									<a class="btn btn-lg" href="productEdit.cfm?subCategoryId=#qrySubCategories.fldSubCategory_Id#&subCategoryName=#qrySubCategories.fldSubCategoryName#&categoryId=#url.categoryId#&categoryName=#url.categoryName#">
										<i class="fa-solid fa-chevron-right"></i>
									</a>
								</div>
							</div>
						</cfloop>
					</div>
				</div>
			</div>

			<!--- Sub Category Modal --->
			<div class="modal fade" id="subCategoryModal">
			  <div class="modal-dialog">
				<div class="modal-content">
				  <div class="modal-header">
					<h1 class="modal-title fs-5" id="subCategoryModalLabel">Add Sub Category</h1>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				  </div>
				  <form id="subCategoryForm" method="post" class="form-group" onsubmit="return processSubCategoryForm()">
					  <div class="modal-body">
					  	<input type="hidden" id="subCategoryId" name="subCategoryId" value="">
						<select id="categorySelect" class="form-select" aria-label="Category Select">
							<option value="0">Category Select</option>
							<cfloop query="qryCategories">
								<option value="#qryCategories.fldCategory_Id#">#qryCategories.fldCategoryName# </option>
							</cfloop>
						</select>
						<div id="categorySelectError" class="mt-2 text-danger"></div>
						<input type="text" id="subCategoryName" name="subCategoryName" placeholder="Sub Category name" class="form-control mt-3">
						<div id="subCategoryModalMsg" class="mt-2"></div>
					  </div>
					  <div class="modal-footer">
						<button type="submit" id="subCategoryModalBtn" class="btn btn-primary">Add Sub Category</button>
					  </div>
				  </form>
				</div>
			  </div>
			</div>
		</cfoutput>
		<cfinclude template="includes/scripts.cfm">
		<script src="assets/js/subCategory.js"></script>
    </body>
</html>
