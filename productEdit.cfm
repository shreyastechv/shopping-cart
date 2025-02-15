<!--- Variables --->
<cfparam name="url.subCategoryId" default="">
<cfparam name="variables.categoryId" default="">
<cfparam name="variables.subCategoryName" default="Products">

<cfoutput>
	<!--- Go to home page if sub category id is empty --->
	<cfif len(trim(url.subCategoryId)) EQ 0>
		<cflocation url="/" addToken="no">
	</cfif>

	<!--- Get Data --->
	<cfset variables.categories = application.shoppingCart.getCategories()>
	<cfset variables.products = application.shoppingCart.getProducts(subCategoryId = url.subCategoryId)>
	<cfset variables.brands = application.shoppingCart.getBrands()>
	<cfset variables.categoryId = arrayLen(variables.products.data) ? variables.products.data[1].categoryId : 0>
	<cfset variables.subCategories = application.shoppingCart.getSubCategories(categoryId = variables.categoryId)>
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
					<div id="productContainer_#i#" class="d-flex justify-content-between align-items-center border rounded-2 px-2">
						<div class="d-flex flex-column fs-5">
							<div name="productName" class="fw-bold">#item.productName#</div>
							<div name="brandName" class="fw-semibold">#item.brandName#</div>
							<div name="price" class="text-success">Rs.#item.price#</div>
						</div>
						<div>
							<button class="btn rounded-circle p-0 m-0 me-5" onclick="editDefaultImage('#item.productId#')">
								<img class="pe-none" src="#application.productImageDirectory&item.productImage#" alt="Product Image" width="50">
							</button>
							<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="##productEditModal" onclick="showEditProductModal('#variables.categoryId#', '#item.productId#')">
								<i class="fa-solid fa-pen-to-square pe-none"></i>
							</button>
							<button class="btn btn-lg" onclick="deleteProduct('productContainer_#i#', '#item.productId#')">
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
			<h1 class="modal-title fs-5" id="subCategoryModalLabel">Edit Product</h1>
			<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		  </div>
		  <form id="productForm" method="post" class="form-group" enctype="multipart/form-data" onsubmit="processproductForm()">
			  <div class="modal-body">
				<input type="hidden" id="productId" name="productId" value="">

				<!--- Category Select --->
				<label for="categorySelect" class="fw-semibold">Category Name</label>
				<select id="categorySelect" class="form-select" aria-label="Category Select">
					<option value="0">Category Select</option>
					<cfloop array="#variables.categories.data#" item="item">
						<option
							<cfif variables.categoryId EQ item.categoryId>
								selected
							</cfif>
							value="#item.categoryId#"
						>
							#item.categoryName#
						</option>
					</cfloop>
				</select>
				<div id="categorySelectError" class="mt-2 text-danger error error"></div>

				<!--- SubCategory Select --->
				<label for="subCategorySelect" class="fw-semibold">SubCategory Name</label>
				<select id="subCategorySelect" class="form-select" aria-label="SubCategory Select">
					<option value="0">SubCategory Select</option>
					<cfloop array="#variables.subCategories.data#" item="item">
						<option
							<cfif url.subCategoryId EQ item.subCategoryId>
								selected
							</cfif>
							value="#item.subCategoryId#"
						>
							#item.subCategoryName#
						</option>
					</cfloop>
				</select>
				<div id="subCategorySelectError" class="mt-2 text-danger error"></div>

				<!--- Product Name --->
				<label for="productName" class="fw-semibold">Product Name</label>
				<input type="text" id="productName" name="productName" class="form-control mb-1">
				<div id="productNameError" class="text-danger error"></div>

				<!--- Product Brand --->
				<label for="brandSelect" class="fw-semibold">Product Brand</label>
				<select id="brandSelect" class="form-select" aria-label="SubCategory Select">
					<option value="0">Brand Name</option>
					<cfloop array="#variables.brands.data#" item="item">
						<option value="#item.brandId#">#item.brandName#</option>
					</cfloop>
				</select>
				<div id="brandSelectError" class="text-danger error"></div>

				<!--- Product Description --->
				<label for="productDesc" class="fw-semibold">Product Description</label>
				<textarea class="form-control mb-1" id="productDesc" name="productDesc" rows="4" cols="50" maxlength="400"></textarea>
				<div id="productDescError" class="text-danger error"></div>

				<!--- Product Price --->
				<label for="productPrice" class="fw-semibold">Product Price</label>
				<input type="number" step="0.01" min="0" id="productPrice" name="productPrice" class="form-control mb-1">
				<div id="productPriceError" class="text-danger error"></div>

				<!--- Product Tax --->
				<label for="productTax" class="fw-semibold">Product Tax (%)</label>
				<input type="number" step="0.01" min="0" max="100" id="productTax" name="productTax" class="form-control mb-1">
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
