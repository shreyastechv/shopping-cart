<!--- Clear variables scope to prevent issues --->
<cfset structClear(variables)>

<!--- URL params --->
<cfparam name="url.categoryId" default="0">
<cfparam name="url.subCategoryId" default="0">
<cfparam name="url.sort" default="">
<cfparam name="url.filterRange" default="">
<cfparam name="url.min" default="0">
<cfparam name="url.max" default="">

<!--- Check filtering --->
<cfif len(trim(url.filterRange))>
	<cfset variables.rangeArray = ListToArray(url.filterRange, "-")>
	<cfif arrayLen(variables.rangeArray) GTE 2 AND (variables.rangeArray[1] GTE 0 AND variables.rangeArray[2] GT variables.rangeArray[1])>
		<cfset url.min = variables.rangeArray[1]>
		<cfset url.max = variables.rangeArray[2]>
	</cfif>
</cfif>
<!--- Check other url params --->
<cfif url.categoryId EQ 0 AND url.subCategoryId EQ 0>
	<!--- Exit if categoryId and subCategoryId are not given --->
	<cflocation  url="/" addToken="false">
<cfelseif url.categoryId NEQ 0>
	<!--- Get Data if categoryId is given --->
	<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories(categoryId = url.categoryId)>
<cfelse>
	<!--- Get Data if subCategoryId is given --->
	<cfset variables.qryProducts = application.shoppingCart.getProducts(
		subCategoryId = url.subCategoryId,
		limit = 8,
		min = url.min,
		max = (len(trim(url.max)) ? val(url.max) : ""),
		sort = url.sort
	)>
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
				<!--- Sorting --->
				<div class="d-flex gap-2 px-3 py-2">
					<a class="text-decoration-none" href="/products.cfm?subCategoryId=#url.subCategoryId#&sort=asc">Price: Low to High</a>
					<a class="text-decoration-none" href="/products.cfm?subCategoryId=#url.subCategoryId#&sort=desc">Price: High to Low</a>
				</div>

				<!--- Filtering --->
				<div class="filter dropdown">
					<button class="btn btn-secondary" type="button" data-bs-toggle="dropdown" aria-expanded="false">
						<i class="fa-solid fa-filter"></i>
						Filter
					</button>
					<ul class="dropdown-menu p-2">
						<div class="text-center">Price Filter</div>
						<form id="filterForm" name="filterForm" method="get">
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
			</div>

			<!--- Sub Category Listing --->
			<cf_productlist qryProducts="#variables.qryProducts#">
		</cfif>
	</div>
</cfoutput>