<cfoutput>
	<!--- Get Data --->
	<cfset variables.categories = application.dataFetch.getCategories()>

	<!--- Main Content --->
	<div class="container d-flex flex-column justify-content-center align-items-center mt-5">
		<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center py-4">
			<div class="d-flex justify-content-center align-items-center">
				<h3 class="h4 fw-semibold text-center mb-0 me-3">CATEGORIES</h3>
				<button class="btn btn-sm btn-secondary" data-bs-toggle="modal" data-bs-target="##categoryModal" onclick="showAddCategoryModal()">
					Add+
				</button>
			</div>
			<div id="categoryMainContainer" class="bg-white col-md-8 p-4 rounded-4 w-100">
				<cfloop array="#variables.categories.data#" item="item" index="i">
					<!--- Encode Category ID since it is passed to URL param --->
					<cfset variables.encodedCategoryId = urlEncodedFormat(item.categoryId)>

					<div class="d-flex justify-content-between align-items-center border rounded-2 px-2 mb-2 shadow-sm" id="categoryContainer_#i#">
						<div name="categoryName" class="fs-5">#item.categoryName#</div>
						<div class="d-flex">
							<button class="btn btn" data-bs-toggle="modal" data-bs-target="##categoryModal" onclick="showEditCategoryModal('categoryContainer_#i#', '#item.categoryId#')">
								<i class="fa-solid fa-pen-to-square pe-none"></i>
							</button>
							<button class="btn btn" onclick="deleteCategory('categoryContainer_#i#', '#item.categoryId#')">
								<i class="fa-solid fa-trash pe-none"></i>
							</button>
							<a class="btn btn" href="/subCategory.cfm?categoryId=#variables.encodedCategoryId#">
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
				<input type="text" id="categoryName" name="categoryName" maxlength="64" placeholder="Category name" class="form-control">
				<div id="categoryModalMsg" class="ps-2 fs-6 mt-2 text-danger"></div>
			  </div>
			  <div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
				<button type="submit" id="categoryModalBtn" class="btn btn-primary" disabled>Save</button>
			  </div>
		  </form>
		</div>
	  </div>
	</div>
</cfoutput>
