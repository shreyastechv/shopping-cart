<!--- Clear variables scope to prevent issues --->
<cfset structClear(variables)>

<!--- URL Params --->
<cfparam name="url.categoryId" default="">
<cfparam name="url.subCategoryId" default="">
<cfparam name="url.search" default="">
<cfparam name="url.sort" default="">

<!--- Form Variables --->
<cfparam name="form.filterRange" default="">
<cfparam name="form.min" default="0">
<cfparam name="form.max" default="0">

<!--- Other variables --->
<cfset variables.limit = 6>

<!--- Check filtering --->
<cfif len(trim(form.filterRange))>
	<cfset variables.rangeArray = ListToArray(form.filterRange, "-")>
	<cfif arrayLen(variables.rangeArray) GTE 2 AND (variables.rangeArray[1] GTE 0 AND variables.rangeArray[2] GT variables.rangeArray[1])>
		<cfset form.min = variables.rangeArray[1]>
		<cfset form.max = variables.rangeArray[2]>
	</cfif>
</cfif>

<!--- Check URL Params --->
<cfif len(trim(url.categoryId))>
	<!--- Category Product Listing --->
	<cfset variables.products = application.dataFetch.getProducts(
		categoryId = url.categoryId,
		random = 1,
		limit = variables.limit
	)>
<cfelse>
	<!--- Sub Category or Search Product Listing --->
	<cfset variables.products = application.dataFetch.getProducts(
		subCategoryId = url.subCategoryId,
		searchTerm = trim(url.search),
		limit = variables.limit,
		min = form.min,
		max = (len(trim(form.max)) ? val(form.max) : ""),
		sort = (arrayContainsNoCase(["","asc","desc"], url.sort) ? url.sort : "")
	)>
</cfif>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column m-3">
		<cfif len(trim(url.categoryId))>
			<!--- Category Listing --->
			<cfset variables.subCategoryMapping = {}>
			<cfloop array="#variables.products.data#" item="item">
				<cfif NOT structKeyExists(variables.subCategoryMapping, item.subCategoryId)>
					<cfset variables.subCategoryMapping[item.subCategoryId].name = item.subCategoryName>
					<cfset variables.subCategoryMapping[item.subCategoryId].data = []>
				</cfif>
				<cfset arrayAppend(variables.subCategoryMapping[item.subCategoryId].data, {
					"productId" = item.productId,
					"productImages" = item.productImages,
					"productName" = item.productName,
					"description" = item.description,
					"price" = item.price
				})>
			</cfloop>
			<cfloop collection="#variables.subCategoryMapping#" item="subCategoryId">
				<!--- Encode Sub Category ID since it is passed to URL param --->
				<cfset variables.encodedSubCategoryId  = urlEncodedFormat(subCategoryId)>

				<a href="/products.cfm?subCategoryId=#variables.encodedSubCategoryId#" class="h4 text-decoration-none">#variables.subCategoryMapping[subCategoryId].name#</a>
				<cf_productlist products="#variables.subCategoryMapping[subCategoryId].data#">
			</cfloop>
		<cfelse>
			<div class="d-flex justify-content-start p-1">

				<!--- Sorting and Filtering only shown if search results are not shown --->
				<cfif len(trim(url.search))>
					<div class="fs-4 fw-semibold px-2">
						<cfif arrayLen(variables.products.data)>
							Search Results for '#trim(url.search)#'
						</cfif>
					</div>
				<cfelse>
					<!--- Sorting --->
					<div class="d-flex px-3 pb-2">
						<form method="get">
							<input type="hidden" name="subCategoryId" value="#url.subCategoryId#">
							<button class="btn btn-primary me-sm-2" type="submit" name="sort" value="asc">Price: Low to High</button>
							<button class="btn btn-primary" type="submit" name="sort" value="desc">Price: High to Low</button>
						</form>
					</div>

					<!--- Filtering --->
					<div class="filter dropdown pe-3">
						<button class="btn btn-secondary" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false">
							<i class="fa-solid fa-filter"></i>
							Filter
						</button>
						<ul class="dropdown-menu p-3 shadow">
							<div class="text-center fw-semibold">Price Filter</div>
							<form method="post">
								<li class="d-flex flex-column justify-content-start p-1">
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
								<li class="d-flex gap-2">
									<input type="number" class="form-control mb-2" id="min" name="min" min="0" value="#form.min#" placeholder="Min" oninput="this.value = this.value.replace(/^0+/, '');">
									<input type="number" class="form-control mb-2" id="max" name="max" max="10000000" value="#form.max#" placeholder="Max" oninput="this.value = this.value.replace(/^0+/, '');">
								<li>
								<li class="d-flex">
									<button class="btn btn-success w-100" type="submit" id="filterBtn">Apply</button>
								</li>
							</form>
						</ul>
					</div>
				</cfif>
			</div>

			<!--- Sub Category / Search Listing --->
			<cf_productlist products="#variables.products.data#">

			<cfif arrayLen(variables.products.data)>
				<!--- View More Button --->
				<cfif variables.products.hasMoreRows>
					<div>
						<button class="btn btn-warning mx-3" id="viewMoreBtn" type="button" onclick="viewMore()">View More</button>
					</div>
				</cfif>
			<cfelse>
				<div class="fs-4 fw-semibold text-center mx-3 mt-4">No Products Found</div>
			</cfif>
		</cfif>
	</div>
</cfoutput>
