<cfoutput>
	<!--- Check presence of url params --->
	<cfif NOT structKeyExists(url, "subCategoryId")>
		<cflocation url="#cgi.http_referer#" addToken="no">
	</cfif>

	<!--- URL params --->
	<cfparam  name="url.subCategoryName" default="Products">
	<cfparam  name="url.categoryId" default="0">
	<cfparam  name="url.categoryName" default="Sub categories">

	<!--- Decrypt URL Params --->
	<cfset variables.subCategoryId = application.shoppingCart.decryptUrlParam(url.subCategoryId)>

	<!--- Get Data --->
	<cfset variables.qryCategories = application.shoppingCart.getCategories()>
	<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories(categoryId = url.categoryId)>
	<cfset variables.qryProducts = application.shoppingCart.getProducts(subCategoryId = variables.subCategoryId)>
	<cfset variables.qryBrands = application.shoppingCart.getBrands()>

	<!--- Main Content --->
	<div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
		<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center">
			<div id="productMainContainer" class="bg-white col-md-8 p-4 rounded-end-4 w-100">
				<div class="d-flex justify-content-between align-items-center mb-4">
					<a href="#cgi.http_referer#" class="btn">
						<i class="fa-solid fa-chevron-left"></i>
					</a>
					<div class="d-flex">
						<h3 class="fw-semibold text-center mb-0 me-3">#url.subCategoryName#</h3>
						<button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="##productEditModal" onclick="showAddProductModal(#variables.subCategoryId#)">
							Add+
						</button>
					</div>
					<div></div>
				</div>
				<cfloop query="variables.qryProducts">
					<div id="productContainer-#variables.qryProducts.fldProduct_Id#" class="d-flex justify-content-between align-items-center border rounded-2 px-2">
						<div class="d-flex flex-column fs-5">
							<div id="productName-#variables.qryProducts.fldProduct_Id#" class="fw-bold">#variables.qryProducts.fldProductName#</div>
							<div id="brandName-#variables.qryProducts.fldProduct_Id#" class="fw-semibold">#variables.qryProducts.fldBrandName#</div>
							<div id="price-#variables.qryProducts.fldProduct_Id#" class="text-success">Rs.#variables.qryProducts.fldPrice#</div>
						</div>
						<div>
							<button class="btn rounded-circle p-0 m-0 me-5" onclick="editDefaultImage(#variables.qryProducts.fldProduct_Id#)">
								<img class="pe-none" src="#application.productImageDirectory&variables.qryProducts.fldProductImage#" alt="Product Image" width="50">
							</button>
							<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="##productEditModal" onclick="showEditProductModal(#variables.qryProducts.fldProduct_Id#,#variables.subCategoryId#)">
								<i class="fa-solid fa-pen-to-square pe-none"></i>
							</button>
							<button class="btn btn-lg" onclick="deleteProduct(#variables.qryProducts.fldProduct_Id#)">
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
		  <form id="productForm" method="post" class="form-group" enctype="multipart/form-data" onsubmit="processproductForm()">
			  <div class="modal-body">
				<input type="hidden" id="productId" name="productId" value="">

				<!--- Category Select --->
				<label for="categorySelect" class="fw-semibold">Category Name</label>
				<select id="categorySelect" class="form-select" aria-label="Category Select">
					<option value="0">Category Select</option>
					<cfloop query="variables.qryCategories">
						<option
							<cfif url.categoryId EQ variables.qryCategories.fldCategory_Id>
								selected
							</cfif>
							value="#variables.qryCategories.fldCategory_Id#"
						>
							#variables.qryCategories.fldCategoryName#
						</option>
					</cfloop>
				</select>
				<div id="categorySelectError" class="mt-2 text-danger error error"></div>

				<!--- SubCategory Select --->
				<label for="subCategorySelect" class="fw-semibold">SubCategory Name</label>
				<select id="subCategorySelect" class="form-select" aria-label="SubCategory Select">
					<option value="0">SubCategory Select</option>
					<cfloop query="variables.qrySubCategories">
						<option
							<cfif variables.subCategoryId EQ variables.qrySubCategories.fldSubCategory_Id>
								selected
							</cfif>
							value="#variables.qrySubCategories.fldSubCategory_Id#"
						>
							#variables.qrySubCategories.fldSubCategoryName#
						</option>
					</cfloop>
				</select>
				<div id="subCategorySelectError" class="mt-2 text-danger error"></div>

				<!--- Product Name --->
				<label for="productName" class="fw-semibold">Product Name</label>
				<input type="text" id="productName" name="productName" placeholder="Product Name" class="form-control mb-1">
				<div id="productNameError" class="text-danger error"></div>

				<!--- Product Brand --->
				<label for="brandSelect" class="fw-semibold">Product Brand</label>
				<select id="brandSelect" class="form-select" aria-label="SubCategory Select">
					<option value="0">Brand Name</option>
					<cfloop query="variables.qryBrands">
						<option value="#variables.qryBrands.fldBrand_Id#">#variables.qryBrands.fldBrandName# </option>
					</cfloop>
				</select>
				<div id="brandSelectError" class="text-danger error"></div>

				<!--- Product Description --->
				<label for="productDesc" class="fw-semibold">Product Description</label>
				<textarea class="form-control mb-1" id="productDesc" name="productDesc" rows="4" cols="50" maxlength="400" placeholder="Product Description"></textarea>
				<div id="productDescError" class="text-danger error"></div>

				<!--- Product Price --->
				<label for="productPrice" class="fw-semibold">Product Price</label>
				<input type="number" step="0.01" min="0" id="productPrice" name="productPrice" placeholder="Product Price" class="form-control mb-1">
				<div id="productPriceError" class="text-danger error"></div>

				<!--- Product Tax --->
				<label for="productTax" class="fw-semibold">Product Price</label>
				<input type="number" step="0.01" min="0" id="productTax" name="productTax" placeholder="Product Tax" class="form-control mb-1">
				<div id="productTaxError" class="text-danger error"></div>

				<!--- Product Image --->
				<label for="productImage" class="fw-semibold">Product Image</label>
				<input type="file" accept="image/*" id="productImage" name="productImage" placeholder="Product Image" class="form-control mb-1" multiple>
				<div id="productImageError" class="text-danger error"></div>
			  </div>
			  <div class="modal-footer">
				<div id="productEditModalMsg" class="mt-2 error"></div>
				<button type="submit" id="subCategoryModalBtn" class="btn btn-primary">Add Product</button>
			  </div>
		  </form>
		</div>
	  </div>
	</div>

	<!--- Product Image Modal --->
	<div class="modal fade" id="productImageModal">
	  <div class="modal-dialog w-50">
		<div class="modal-content">
		  <div class="modal-header">
			<h1 class="modal-title fs-5" id="imageModalLabel">Product Images</h1>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <div class="modal-body" data-bs-theme="dark">
			<div id="productImageCarousel" class="carousel slide">
			  <div id="carouselContainer" class="carousel-inner">
			  </div>
			  <button class="carousel-control-prev" type="button" data-bs-target="##productImageCarousel" data-bs-slide="prev">
				<span class="carousel-control-prev-icon" aria-hidden="true"></span>
				<span class="visually-hidden">Previous</span>
			  </button>
			  <button class="carousel-control-next" type="button" data-bs-target="##productImageCarousel" data-bs-slide="next">
				<span class="carousel-control-next-icon" aria-hidden="true"></span>
				<span class="visually-hidden">Next</span>
			  </button>
			</div>
		  </div>
		</div>
	  </div>
	</div>
</cfoutput>
