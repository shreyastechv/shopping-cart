<!--- Clear variables scope to prevent issues --->
<cfset structClear(variables)>

<!--- URL params --->
<cfparam name="url.categoryId" default="0">
<cfparam name="url.subCategoryId" default="0">
<cfparam name="url.search" default="">

<!--- Form Variables --->
<cfparam name="form.filterRange" default="">
<cfparam name="form.min" default="0">
<cfparam name="form.max" default="">
<cfparam name="form.sort" default="">

<!--- Check filtering --->
<cfif len(trim(form.filterRange))>
	<cfset variables.rangeArray = ListToArray(form.filterRange, "-")>
	<cfif arrayLen(variables.rangeArray) GTE 2 AND (variables.rangeArray[1] GTE 0 AND variables.rangeArray[2] GT variables.rangeArray[1])>
		<cfset form.min = variables.rangeArray[1]>
		<cfset form.max = variables.rangeArray[2]>
	</cfif>
</cfif>

<!--- Check other url params --->
<cfif url.categoryId NEQ 0>
	<!--- Get Data if categoryId is given --->
	<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories(categoryId = url.categoryId)>
<cfelseif url.subCategoryId NEQ 0>
	<!--- Get Data if subCategoryId is given --->
	<cfset variables.qryProducts = application.shoppingCart.getProducts(
		subCategoryId = url.subCategoryId,
		limit = 8,
		min = form.min,
		max = (len(trim(form.max)) ? val(form.max) : ""),
		sort = form.sort
	)>
<cfelseif len(trim(url.search))>
	<!--- Get Data if search is given --->
	<cfset variables.qryProducts = application.shoppingCart.getProducts(
		searchTerm = url.search
	)>
<cfelse>
	<!--- Exit if Required URL Params are not passed --->
	<cflocation url="/" addToken="false">
</cfif>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column">
		<cfif structKeyExists(variables, "qrySubCategories")>
			<!--- Category Listing --->
			<cfloop query="variables.qrySubCategories">
				<a href="/products.cfm?subCategoryId=#variables.qrySubCategories.fldSubCategory_Id#" class="h4 text-decoration-none">#variables.qrySubCategories.fldSubCategoryName#</a>
				<cfset local.qryProducts = application.shoppingCart.getProducts(
					subCategoryId = variables.qrySubCategories.fldSubCategory_Id,
					random = 1,
					limit = 4
				)>
				<cf_productlist qryProducts="#local.qryProducts#">
			</cfloop>
		<cfelse>
			<div class="d-flex justify-content-between p-1">

				<!--- Sorting and Filtering only shown if search results are not shown --->
				<cfif len(trim(url.search))>
					<div class="fs-4 fw-semibold px-2">
						Search Results for '#url.search#'
					</div>
				<cfelse>
					<!--- Sorting --->
					<div class="d-flex gap-2 px-1">
						<form method="post">
							<button class="btn" type="submit" name="sort" value="asc">Price: Low to High</button>
							<button class="btn" type="submit" name="sort" value="desc">Price: High to Low</button>
						</form>
					</div>

					<!--- Filtering --->
					<div class="filter dropdown">
						<button class="btn btn-secondary" type="button" data-bs-toggle="dropdown" aria-expanded="false">
							<i class="fa-solid fa-filter"></i>
							Filter
						</button>
						<ul class="dropdown-menu p-2">
							<div class="text-center">Price Filter</div>
							<form id="filterForm" name="filterForm" method="post">
								<input type="hidden" name="subCategoryId" value="#url.subCategoryId#">
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

			<!--- Sub Category Listing --->
			<cf_productlist qryProducts="#variables.qryProducts#">
		</cfif>
	</div>
</cfoutput>