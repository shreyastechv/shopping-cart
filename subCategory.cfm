<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sub Category Edit - Shopping Cart</title>
		<link rel="icon" href="favicon.ico">
		<link href="assets/css/bootstrap.min.css" rel="stylesheet">
		<script src="assets/js/fontawesome.js"></script>
    </head>

    <body>
		<cfoutput>
			<!--- Get Data --->
			<cfset objShoppingCart = createObject("component", "components.shoppingCart")>
			<cfset qrySubCategories = objShoppingCart.getSubCategories()>

			<!--- Navbar --->
			<header class="header d-flex align-items-center justify-content-between fixed-top bg-success px-2">
				<a class="d-flex align-items-center text-decoration-none" href="/">
					<img class=" p-2 me-2" src="assets/images/shopping-cart-logo.png" height="45" alt="Logo Image">
					<div class="text-white fw-semibold">SHOPPING CART</div>
				</a>
				<nav class="d-flex align-items-center gap-4">
					<a class="text-white text-decoration-none" href="signup.cfm">
						<i class="fa-solid fa-right-from-bracket"></i>
						Logout
					</a>
				</nav>
			</header>

			<!--- Main Content --->
			<div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
				<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center">
					<div id="subCategoryMainContainer" class="bg-white col-md-8 p-4 rounded-end-4 w-100">
						<div class="d-flex justify-content-center align-items-center mb-4">
							<h3 class="fw-semibold text-center mb-0 me-3">SUB CATEGORIES</h3>
							<button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="##subCategoryModal" onclick="showAddSubCategoryModal()">
								Add+
							</button>
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
									<button class="btn btn-lg">
										<i class="fa-solid fa-chevron-right"></i>
									</button>
								</div>
							</div>
						</cfloop>
					</div>
				</div>
			</div>

			<!--- Sub Category Modal --->
			<div class="modal fade" id="subCategoryModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
			  <div class="modal-dialog">
				<div class="modal-content">
				  <div class="modal-header">
					<h1 class="modal-title fs-5" id="subCategoryModalLabel">Add Sub Category</h1>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				  </div>
				  <form id="subCategoryForm" class="form-group" onsubmit="return processSubCategoryForm()">
					  <div class="modal-body">
					  	<input type="hidden" id="subCategoryId" name="subCategoryId" value="">
						<input type="text" id="subCategoryName" name="subCategoryName" placeholder="Sub Category name" class="form-control">
						<div id="subCategoryNameError" class="text-danger"></div>
					  </div>
					  <div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
						<button type="submit" id="subCategoryModalBtn" class="btn btn-primary">Add Sub Category</button>
					  </div>
				  </form>
				</div>
			  </div>
			</div>
		</cfoutput>
		<script src="assets/js/bootstrap.bundle.min.js"></script>
		<script src="assets/js/jquery-3.7.1.min.js"></script>
		<script src="assets/js/adminDashboard.js"></script>
    </body>
</html>
