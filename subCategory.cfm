<cfoutput>
	<!--- Variables used in the page --->
	<cfparam name="variables.categoryName" default="Sub Categories">

	<!--- Check presence of url params --->
	<cfif NOT structKeyExists(url, "categoryId")>
		<cflocation url="/adminDashboard.cfm" addToken="no">
	</cfif>

	<!--- Decrypt URL Params --->
	<cfset variables.categoryId = application.shoppingCart.decryptUrlParam(url.categoryId)>

	<!--- Get Data --->
	<cfset variables.qryCategories = application.shoppingCart.getCategories()>
	<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories(categoryId = variables.categoryId)>

	<!--- Get Category Name --->
	<cfloop query="variables.qryCategories">
		<cfif variables.qryCategories.fldCategory_Id EQ variables.categoryId>
			<cfset variables.categoryName = variables.qryCategories.fldCategoryName>
		</cfif>
	</cfloop>

	<!--- Main Content --->
	<div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
		<div class="row shadow-lg border-0 rounded-4 w-50 justify-content-center">
			<div id="subCategoryMainContainer" class="bg-white col-md-8 p-4 rounded-end-4 w-100">
				<div class="d-flex justify-content-between align-items-center mb-4">
					<a href="/adminDashboard.cfm" class="btn">
						<i class="fa-solid fa-chevron-left"></i>
					</a>
					<div class="d-flex">
						<h3 class="fw-semibold text-center mb-0 me-3">#variables.categoryName#</h3>
						<button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="##subCategoryModal" onclick="showAddSubCategoryModal()">
							Add+
						</button>
					</div>
					<div></div>
				</div>
				<cfloop query="variables.qrySubCategories">
					<!--- Encrypt SubCategory ID since it is passed to URL param --->
					<cfset variables.encryptedSubCategoryId = application.shoppingCart.encryptUrlParam(variables.qrySubCategories.fldSubCategory_Id)>

					<div class="d-flex justify-content-between align-items-center border rounded-2 px-2">
						<div id="subCategoryName-#variables.qrySubCategories.fldSubCategory_Id#" class="fs-5">#variables.qrySubCategories.fldSubCategoryName#</div>
						<div>
							<button class="btn btn-lg" data-bs-toggle="modal" data-bs-target="##subCategoryModal" onclick="showEditSubCategoryModal(#variables.qrySubCategories.fldSubCategory_Id#)">
								<i class="fa-solid fa-pen-to-square pe-none"></i>
							</button>
							<button class="btn btn-lg" onclick="deleteSubCategory(#variables.qrySubCategories.fldSubCategory_Id#)">
								<i class="fa-solid fa-trash pe-none"></i>
							</button>
							<a class="btn btn-lg" href="/productEdit.cfm?subCategoryId=#variables.encryptedSubCategoryId#&subCategoryName=#variables.qrySubCategories.fldSubCategoryName#&categoryId=#variables.categoryId#&categoryName=#variables.categoryName#">
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
					<cfloop query="variables.qryCategories">
						<option
							<cfif variables.categoryId EQ variables.qryCategories.fldCategory_Id>
								selected
							</cfif>
							value="#variables.qryCategories.fldCategory_Id#"
						>
							#variables.qryCategories.fldCategoryName#
						</option>
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
