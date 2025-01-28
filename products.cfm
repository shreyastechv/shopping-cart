<!--- Clear variables scope to prevent issues --->
<cfset structClear(variables)>

<!--- URL Params --->
<cfparam name="url.categoryId" default="">
<cfparam name="url.subCategoryId" default="">
<cfparam name="url.search" default="">

<!--- Decrypt URL Params --->
<cfset variables.categoryId = application.shoppingCart.decryptUrlParam(url.categoryId)>
<cfset variables.subCategoryId = application.shoppingCart.decryptUrlParam(url.subCategoryId)>

<!--- Form Variables --->
<cfparam name="form.filterRange" default="">
<cfparam name="form.min" default="0">
<cfparam name="form.max" default="">
<cfparam name="form.sort" default="">
<cfparam name="form.limit" default=6>

<!--- Check filtering --->
<cfif len(trim(form.filterRange))>
	<cfset variables.rangeArray = ListToArray(form.filterRange, "-")>
	<cfif arrayLen(variables.rangeArray) GTE 2 AND (variables.rangeArray[1] GTE 0 AND variables.rangeArray[2] GT variables.rangeArray[1])>
		<cfset form.min = variables.rangeArray[1]>
		<cfset form.max = variables.rangeArray[2]>
	</cfif>
</cfif>

<!--- Check URL Params --->
<cfif variables.categoryId NEQ -1>
	<!--- Get Data if categoryId is given --->
	<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories(categoryId = variables.categoryId)>
<cfelseif variables.subCategoryId NEQ -1>
	<!--- Get Data if subCategoryId is given --->
	<cfset variables.qryProducts = application.shoppingCart.getProducts(
		subCategoryId = variables.subCategoryId,
		limit = form.limit,
		min = form.min,
		max = (len(trim(form.max)) ? val(form.max) : ""),
		sort = form.sort
	)>
<cfelseif len(trim(url.search))>
	<!--- Get Data if search is given --->
	<cfset variables.qryProducts = application.shoppingCart.getProducts(
		searchTerm = trim(url.search)
	)>
<cfelse>
	<!--- Exit if Required URL Params are not passed --->
	<cflocation url="/" addToken="false">
</cfif>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column m-3">
		<cfif structKeyExists(variables, "qrySubCategories")>
			<!--- Category Listing --->
			<cfloop query="variables.qrySubCategories">
				<!--- Encrypt SubCategory ID since it is passed to URL param --->
				<cfset variables.encryptedSubCategoryId = application.shoppingCart.encryptUrlParam(variables.qrySubCategories.fldSubCategory_Id)>

				<!--- Gather products --->
				<cfset variables.qryProducts = application.shoppingCart.getProducts(
					subCategoryId = variables.qrySubCategories.fldSubCategory_Id,
					random = 1,
					limit = 6
				)>

				<!--- Show subcategory if it has products --->
				<cfif variables.qryProducts.recordCount>
					<a href="/products.cfm?subCategoryId=#variables.encryptedSubCategoryId#" class="h4 text-decoration-none">#variables.qrySubCategories.fldSubCategoryName#</a>
					<cf_productlist qryProducts="#variables.qryProducts#">
				</cfif>
			</cfloop>
		<cfelse>
			<div class="d-flex justify-content-start p-1">

				<!--- Sorting and Filtering only shown if search results are not shown --->
				<cfif len(trim(url.search))>
					<div class="fs-4 fw-semibold px-2">
						<cfif variables.qryProducts.recordCount>
							Search Results for '#trim(url.search)#'
						<cfelse>
							No Results found for '#trim(url.search)#'
						</cfif>
					</div>
				<cfelse>
					<!--- Sorting --->
					<div class="d-flex px-3 pb-2">
						<form method="post">
							<button class="btn btn-primary me-sm-2" type="submit" name="sort" value="asc">Price: Low to High</button>
							<button class="btn btn-primary" type="submit" name="sort" value="desc">Price: High to Low</button>
						</form>
					</div>

					<!--- Filtering --->
					<div class="filter dropdown pe-3">
						<button class="btn btn-secondary" type="button" data-bs-toggle="dropdown" aria-expanded="false">
							<i class="fa-solid fa-filter"></i>
							Filter
						</button>
						<ul class="dropdown-menu p-2">
							<div class="text-center">Price Filter</div>
							<form id="filterForm" name="filterForm" method="post">
								<li class="d-flex flex-column justify-content-start">
									<div>
										<input type="radio" name="filterRange" value="0-100"> 0 - 100
									</div>
									<div>
										<input type="radio" name="filterRange" value="101-500"> 101 - 500
									</div>
									<div>
										<input type="radio" name="filterRange" value="501-1000"> 501 - 1000
									</div>
									<div>
										<input type="radio" name="filterRange" value="1001-2000"> 1001 - 2000
									</div>
									<div>
										<input type="radio" name="filterRange" value="2001-5000"> 2001 - 5000
									</div>
								</li>
								<li class="d-flex m-1">
									<input type="number" class="form-control" id="min" name="min" min="0" placeholder="Min">
									<input type="number" class="form-control" id="max" name="max" placeholder="Max">
								<li>
								<li>
									<button class="btn btn-success" type="submit" id="filterBtn">Apply</button>
								</li>
							</form>
						</ul>
					</div>
				</cfif>
			</div>

			<!--- Sub Category / Search Listing --->
			<cf_productlist qryProducts="#variables.qryProducts#">

			<cfif NOT len(trim(url.search))>
				<cfif variables.qryProducts.recordCount>
					<!--- View More Button --->
					<div>
						<button class="btn btn-warning mx-3" id="viewMoreBtn" type="button" onclick="viewMore(#variables.subCategoryId#)">View More</button>
					</div>
				<cfelse>
					<div class="fs-4 fw-semibold text-center mx-3 mt-4">No Products Found</div>
				</cfif>
			</cfif>
		</cfif>
	</div>
</cfoutput>
