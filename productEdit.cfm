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
			<cfparam  name="url.subCategoryId" default="0">
			<cfparam  name="url.subCategoryName" default="Products">
			<cfparam  name="url.categoryId" default="0">
			<cfparam  name="url.categoryName" default="Sub categories">
			<cfif url.subCategoryId LT 1>
				<cflocation  url="subCategory.cfm?categoryId=#url.categoryId#&categoryName=#url.categoryName#" addToken="false">
			</cfif>

			<!--- Get Data --->
			<cfset objShoppingCart = createObject("component", "components.shoppingCart")>
			<cfset qryCategories = objShoppingCart.getCategories()>
			<cfset qrySubCategories = objShoppingCart.getSubCategories(categoryId = url.categoryId)>
			<cfset qryProducts = objShoppingCart.getProducts(subCategoryId = url.subCategoryId)>
			<cfset qryBrands = objShoppingCart.getBrands()>

			<!--- Header --->
			<cfinclude template = "includes/header.cfm">

			<!--- Main Content --->
			<div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
				<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center">
					<div id="subCategoryMainContainer" class="bg-white col-md-8 p-4 rounded-end-4 w-100">
						<div class="d-flex justify-content-between align-items-center mb-4">
							<a href="subCategory.cfm?categoryId=#url.categoryId#&categoryName=#url.categoryName#" class="btn">
								<i class="fa-solid fa-chevron-left"></i>
							</a>
							<div class="d-flex">
								<h3 class="fw-semibold text-center mb-0 me-3">#url.subCategoryName#</h3>
								<button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="##productEditModal" onclick="showAddProductModal()">
									Add+
								</button>
							</div>
							<div></div>
						</div>
						<cfloop query="qryProducts">
							<div class="d-flex justify-content-between align-items-center border rounded-2 px-2">
								<div id="subCategoryName-#qryProducts.fldProduct_Id#" class="fs-5">#qryProducts.fldProductName#</div>
								<div>
									<button class="btn btn-lg" value="#qryProducts.fldProduct_Id#" data-bs-toggle="modal" data-bs-target="##productEditModal" onclick="showEditProductModal()">
										<i class="fa-solid fa-pen-to-square pe-none"></i>
									</button>
									<button class="btn btn-lg" value="#qryProducts.fldProduct_Id#" onclick="deleteProduct()">
										<i class="fa-solid fa-trash pe-none"></i>
									</button>
								</div>
							</div>
						</cfloop>
					</div>
				</div>
			</div>

			<!--- Product Edit Modal --->
			<div class="modal fade" id="productEditModal">
			  <div class="modal-dialog">
				<div class="modal-content">
				  <div class="modal-header">
					<h1 class="modal-title fs-5" id="subCategoryModalLabel">Add Sub Category</h1>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				  </div>
				  <form id="productForm" method="post" class="form-group" enctype="multipart/form-data" onsubmit="return processproductForm()">
					  <div class="modal-body">
					  	<input type="hidden" id="productId" name="productId" value="">

						<!--- Category Select --->
						<label for="categorySelect" class="fw-semibold">Category Name</label>
						<select id="categorySelect" class="form-select" aria-label="Category Select">
							<option value="0">Category Select</option>
							<cfloop query="qryCategories">
								<option
									<cfif url.categoryId EQ qryCategories.fldCategory_Id>
										selected
									</cfif>
									value="#qryCategories.fldCategory_Id#"
								>
									#qryCategories.fldCategoryName#
								</option>
							</cfloop>
						</select>
						<div id="categorySelectError" class="mt-2 text-danger"></div>

						<!--- SubCategory Select --->
						<label for="subCategorySelect" class="fw-semibold">SubCategory Name</label>
						<select id="subCategorySelect" class="form-select" aria-label="SubCategory Select">
							<option value="0">SubCategory Select</option>
							<cfloop query="qrySubCategories">
								<option
									<cfif url.subCategoryId EQ qrySubCategories.fldSubCategory_Id>
										selected
									</cfif>
									value="#qrySubCategories.fldSubCategory_Id#"
								>
									#qrySubCategories.fldSubCategoryName#
								</option>
							</cfloop>
						</select>
						<div id="subCategorySelectError" class="mt-2 text-danger"></div>

						<!--- Product Name --->
						<label for="productName" class="fw-semibold">Product Name</label>
						<input type="text" id="productName" name="productName" placeholder="Product Name" class="form-control mb-1">
						<div id="productNameError" class="text-danger"></div>

						<!--- Product Brand --->
						<label for="productBrandSelect" class="fw-semibold">Product Brand</label>
						<select id="productBrandSelect" class="form-select" aria-label="SubCategory Select">
							<option value="0">Brand Name</option>
							<cfloop query="qryBrands">
								<option value="#qryBrands.fldBrand_Id#">#qryBrands.fldBrandName# </option>
							</cfloop>
						</select>
						<div id="productBrandSelectError" class="text-danger"></div>

						<!--- Product Description --->
						<label for="productDesc" class="fw-semibold">Product Description</label>
						<textarea class="form-control mb-1" id="productDesc" name="productDesc" rows="4" cols="50" placeholder="Product Description"></textarea>
						<div id="productDescError" class="text-danger"></div>

						<!--- Product Price --->
						<label for="productPrice" class="fw-semibold">Product Price</label>
						<input type="number" step="0.01" min="0" id="productPrice" name="productPrice" placeholder="Product Price" class="form-control mb-1">
						<div id="productPriceError" class="text-danger"></div>

						<!--- Product Image --->
						<label for="productImage" class="fw-semibold">Product Image</label>
						<input type="file" accept="image/*" id="productImage" name="productImage" placeholder="Product Image" class="form-control mb-1" multiple>
						<div id="productImageError" class="text-danger"></div>
					  </div>
					  <div class="modal-footer">
						<div id="productEditModalMsg" class="mt-2"></div>
						<button type="submit" id="subCategoryModalBtn" class="btn btn-primary">Add Product</button>
					  </div>
				  </form>
				</div>
			  </div>
			</div>
		</cfoutput>
		<cfinclude template="includes/scripts.cfm">
		<script src="assets/js/productEdit.js"></script>
    </body>
</html>
