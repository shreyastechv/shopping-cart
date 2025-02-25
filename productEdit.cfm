<!--- Variables --->
<cfparam name="url.subCategoryId" default="">
<cfparam name="variables.categoryId" default="">
<cfparam name="variables.subCategoryName" default="Products">

<cfoutput>
	<!--- Get Data --->
	<cfset variables.categories = application.dataFetch.getCategories()>
	<cfset variables.products = application.dataFetch.getProducts(subCategoryId = url.subCategoryId)>
	<cfset variables.brands = application.dataFetch.getBrands()>
	<cfset variables.categoryId = arrayLen(variables.products.data) ? variables.products.data[1].categoryId : 0>
	<cfset variables.subCategories = application.dataFetch.getSubCategories(categoryId = variables.categoryId)>
	<cfset variables.subCategoryName = arrayLen(variables.products.data) ? variables.products.data[1].subCategoryName : "Products">

	<!--- Main Content --->
	<div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
		<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center">
			<div id="productMainContainer" class="bg-white col-md-8 p-4 rounded-end-4 w-100">
				<div class="d-flex justify-content-between align-items-center mb-4">
					<a href="/subCategory.cfm?categoryId=#urlEncodedFormat(variables.categoryId)#" class="btn">
						<i class="fa-solid fa-chevron-left"></i>
					</a>
					<div class="d-flex">
						<h3 class="fw-semibold text-center mb-0 me-3">#variables.subCategoryName#</h3>
						<button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="##productEditModal" onclick="showAddProductModal('#variables.categoryId#', '#url.subCategoryId#')">
							Add+
						</button>
					</div>
					<div></div>
				</div>
				<cfloop array="#variables.products.data#" item="item" index="i">
					<div id="productContainer_#i#" class="d-flex justify-content-between align-items-center border rounded-2 px-3 py-2 mb-3 shadow-sm">
						<div class="d-flex flex-column fs-5">
							<div name="productName" class="fw-bold">#item.productName#</div>
							<div name="brandName">#item.brandName#</div>
							<div name="price" class="text-success">Rs.#item.price#</div>
						</div>
						<div class="d-flex gap-4">
							<img src="#application.productImageDirectory&listGetAt(item.productImages, 1)#" alt="Product Image" class="img-fluid p-1" width="90">
							<div class="d-flex flex-column">
								<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="##productEditModal" onclick="showEditProductModal('#variables.categoryId#', '#item.productId#')">
									<i class="fa-solid fa-pen-to-square pe-none"></i>
								</button>
								<button class="btn btn-lg" onclick="deleteProduct('productContainer_#i#', '#item.productId#')">
									<i class="fa-solid fa-trash pe-none"></i>
								</button>
							</div>
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
			<h1 class="modal-title fs-5" id="subCategoryModalLabel">Edit Product</h1>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <form id="productForm" method="post" class="form-group" enctype="multipart/form-data" onsubmit="processProductForm()">
			  <div class="modal-body">
				<input type="hidden" id="productId" name="productId" value="">

				<!--- Category Select --->
				<label for="categorySelect" class="fw-semibold">Category Name</label>
				<select id="categorySelect" class="form-select productInput" aria-label="Category Select">
					<option value="0">Category Select</option>
					<cfloop array="#variables.categories.data#" item="item">
						<option value="#item.categoryId#" #(variables.categoryId EQ item.categoryId ? "selected" : "")#>
							#item.categoryName#
						</option>
					</cfloop>
				</select>
				<div id="categorySelectError" class="text-danger productError ps-2"></div>

				<!--- SubCategory Select --->
				<label for="subCategorySelect" class="fw-semibold mt-2">SubCategory Name</label>
				<select id="subCategorySelect" class="form-select productInput" aria-label="SubCategory Select">
					<option value="0">SubCategory Select</option>
					<cfloop array="#variables.subCategories.data#" item="item">
						<option value="#item.subCategoryId#" #(url.subCategoryId EQ item.subCategoryId ? "selected" : "")#>
							#item.subCategoryName#
						</option>
					</cfloop>
				</select>
				<div id="subCategorySelectError" class="text-danger productError ps-2"></div>

				<!--- Product Name --->
				<label for="productName" class="fw-semibold mt-2">Product Name</label>
				<input type="text" id="productName" name="productName" maxlength="100" class="form-control productInput">
				<div id="productNameError" class="text-danger productError ps-2"></div>

				<!--- Product Brand --->
				<label for="brandSelect" class="fw-semibold mt-2">Product Brand</label>
				<select id="brandSelect" class="form-select" aria-label="SubCategory Select">
					<option value="0">Brand Name</option>
					<cfloop array="#variables.brands.data#" item="item">
						<option value="#item.brandId#">#item.brandName#</option>
					</cfloop>
				</select>
				<div id="brandSelectError" class="text-danger productError ps-2"></div>

				<!--- Product Description --->
				<label for="productDesc" class="fw-semibold mt-2">Product Description</label>
				<textarea class="form-control productInput" id="productDesc" name="productDesc" rows="4" cols="50" maxlength="400"></textarea>
				<div id="productDescError" class="text-danger productError ps-2"></div>

				<!--- Product Price --->
				<label for="productPrice" class="fw-semibold mt-2">Product Price</label>
				<input type="number" step="0.01" min="0" id="productPrice" max="99999999" name="productPrice" class="form-control productInput">
				<div id="productPriceError" class="text-danger productError ps-2"></div>

				<!--- Product Tax --->
				<label for="productTax" class="fw-semibold mt-2">Product Tax (%)</label>
				<input type="number" step="0.01" min="0" max="100" id="productTax" name="productTax" class="form-control productInput">
				<div id="productTaxError" class="text-danger productError ps-2"></div>

				<!--- Product Image --->
				<label for="productImage" class="fw-semibold mt-2">Product Image</label>
				<input type="file" accept="image/*" id="productImage" name="productImage" placeholder="Product Image" class="form-control productInput" multiple>
				<div id="uploadedProductImages" class="row p-3 gap-3 mt-1"></div>
				<div id="productImageError" class="text-danger productError mt-1 ps-2"></div>
			  </div>
			  <div class="modal-footer">
				<div id="productEditModalMsg" class="mt-2 productError"></div>
				<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
				<button type="submit" id="subCategoryModalBtn" class="btn btn-primary">Save</button>
			  </div>
		  </form>
		</div>
	  </div>
	</div>
</cfoutput>
