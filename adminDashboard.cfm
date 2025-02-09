<cfoutput>
	<!--- Get Data --->
	<cfset variables.categories = application.shoppingCart.getCategories()>

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
				<cfloop array="#variables.categories.data#" item="item">
			<!--- Encode Category ID since it is passed to URL param --->
					<cfset variables.encodedCategoryId = urlEncodedFormat(item.categoryId)>

					<div class="d-flex justify-content-between align-items-center border rounded-2 px-2">
						<div id="categoryName-#item.categoryId#" class="fs-5">#item.categoryName#</div>
						<div>
							<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="##categoryModal" onclick="showEditCategoryModal('#item.categoryId#')">
								<i class="fa-solid fa-pen-to-square pe-none"></i>
							</button>
							<button class="btn btn-lg" onclick="deleteCategory('#item.categoryId#')">
								<i class="fa-solid fa-trash pe-none"></i>
							</button>
							<a class="btn btn-lg" href="/subCategory.cfm?categoryId=#variables.encodedCategoryId#">
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
		  <form id="categoryForm" method="post" class="form-group" onsubmit="processCategoryForm()">
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
