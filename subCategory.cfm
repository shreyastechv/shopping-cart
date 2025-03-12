<cfparam name="url.categoryId" default="">
<cfparam name="variables.categoryName" default="Sub Categories">

<!--- Go to admin dashboard if category id is empty --->
<cfif NOT len(trim(url.categoryId))>
	<cflocation url="/adminDashboard.cfm" addToken="false">
</cfif>

<cfoutput>
	<!--- Get Data --->
	<cfset variables.categories = application.dataFetch.getCategories()>
	<cfset variables.subCategories = application.dataFetch.getSubCategories(categoryId = url.categoryId)>
	<cfset variables.categoryName = arrayLen(variables.subCategories.data)
		? variables.subCategories.data[1].categoryName
		<!--- Below code is to fetch the category name when there are no products in it --->
		: application.dataFetch.getCategories(categoryId = url.categoryId).data[1].categoryName>

	<!--- Main Content --->
	<div class="container d-flex flex-column justify-content-center align-items-center my-5">
		<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center">
			<div id="subCategoryMainContainer" class="bg-white col-md-8 p-4 rounded-end-4 w-100">
				<div class="d-flex justify-content-between align-items-center mb-4">
					<a href="/adminDashboard.cfm" class="btn">
						<i class="fa-solid fa-chevron-left"></i>
					</a>
					<div class="d-flex">
						<h3 class="h5 text-uppercase fw-semibold text-center mb-0 me-3">#variables.categoryName#</h3>
						<button class="btn btn-sm btn-secondary" data-bs-toggle="modal" data-bs-target="##subCategoryModal" onclick="showAddSubCategoryModal()">
							Add+
						</button>
					</div>
					<div></div>
				</div>
				<cfloop array="#variables.subCategories.data#" item="item" index="i">
					<!--- Encode SubCategory ID since it is passed to URL param --->
					<cfset variables.encodedSubCategoryId  = urlEncodedFormat(item.subCategoryId)>

					<div class="d-flex justify-content-between align-items-center border rounded-2 px-2 mb-2 shadow-sm" id="subCategoryContainer_#i#">
						<div name="subCategoryName" class="fs-5">#item.subCategoryName#</div>
						<div>
							<button class="btn btn" data-bs-toggle="modal" data-bs-target="##subCategoryModal" onclick="showEditSubCategoryModal('subCategoryContainer_#i#', '#item.subCategoryId#')">
								<i class="fa-solid fa-pen-to-square pe-none"></i>
							</button>
							<button class="btn btn" onclick="deleteSubCategory('subCategoryContainer_#i#', '#item.subCategoryId#', '#item.subCategoryName#')">
								<i class="fa-solid fa-trash pe-none"></i>
							</button>
							<a class="btn btn" href="/productEdit.cfm?subCategoryId=#variables.encodedSubCategoryId#">
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
		  <form id="subCategoryForm" method="post" class="form-group" onsubmit="processSubCategoryForm()">
			  <div class="modal-body">
				<input type="hidden" id="subCategoryId" name="subCategoryId" value="">
				<select id="categorySelect" class="form-select" aria-label="Category Select">
					<option value="0">Category Select</option>
					<cfloop array="#variables.categories.data#" item="item">
						<option value="#item.categoryId#" #(url.categoryId EQ item.categoryId ? "selected" : "")#>
							#item.categoryName#
						</option>
					</cfloop>
				</select>
				<div id="categorySelectError" class="mt-2 text-danger"></div>
				<input type="text" id="subCategoryName" name="subCategoryName" maxlength="64" placeholder="Sub Category name" class="form-control mt-3">
				<div id="subCategoryModalMsg" class="text-danger mt-2"></div>
			  </div>
			  <div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
				<button type="submit" id="subCategoryModalBtn" class="btn btn-primary" disabled>Save</button>
			  </div>
		  </form>
		</div>
	  </div>
	</div>
</cfoutput>
