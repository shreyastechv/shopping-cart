<!--- Clear variables scope to prevent issues --->
<cfset structClear(variables)>

<!--- URL Params --->
<cfparam name="url.categoryId" default="">
<cfparam name="url.subCategoryId" default="">
<cfparam name="url.search" default="">
<cfparam name="url.sort" default="">

<!--- Form Variables --->
<cfparam name="url.min" default=0>
<cfparam name="url.max" default=0>

<!--- Other variables --->
<cfset variables.limit = 6>
<cfset variables.products = {
	data = []
}>

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
		min = val(url.min),
		max = val(url.max),
		sort = (arrayContainsNoCase(["","asc","desc"], url.sort) ? url.sort : "")
	)>
</cfif>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column m-3">
		<cfif arrayLen(variables.products.data)>
			<cfif NOT len(trim(url.categoryId))>
				<div class="d-flex justify-content-start p-1">
					<!--- Sorting --->
					<div class="d-flex px-3 pb-2">
						<form method="get">
							<input type="hidden" name="search" value="#url.search#">
							<input type="hidden" name="subCategoryId" value="#url.subCategoryId#">
							<input type="hidden" name="min" value="#url.min#">
							<input type="hidden" name="max" value="#url.max#">
							<button class="btn btn-primary me-sm-2" type="submit" name="sort" value="asc">
								<i class="fa-solid fa-arrow-up-wide-short"></i>
								Price: Low to High
							</button>
							<button class="btn btn-primary" type="submit" name="sort" value="desc">
								<i class="fa-solid fa-arrow-down-wide-short"></i>
								Price: High to Low
							</button>
						</form>
					</div>

					<!--- Filtering --->
					<div class="filter dropdown pe-3">
						<button class="btn btn-secondary" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false">
							<i class="fa-solid fa-filter-circle-dollar"></i>
							Filter
						</button>
						<ul class="dropdown-menu p-3 shadow">
							<div class="d-flex align-items-center justify-content-between fw-semibold mb-2 gap-2">
								Price Filter
								<button type="button" id="clearBtn" class="btn btn-sm btn-outline-danger" disabled>Clear</button>
							</div>

							<form method="get" id="priceFilterForm">
								<input type="hidden" name="search" value="#url.search#">
								<input type="hidden" name="subCategoryId" value="#url.subCategoryId#">
								<input type="hidden" name="sort" value="#url.sort#">

								<div class="d-flex gap-2">
									<div>
										<label for="min">Min</label>
										<input type="number" class="form-control mb-2" id="min" name="min" min="0" value="#url.min#"
											oninput="this.value = this.value.replace(/^0+/, '');">
									</div>
									<div>
										<label for="max">Max</label>
										<input type="number" class="form-control mb-2" id="max" name="max" max="10000000" value="#url.max#"
											oninput="this.value = this.value.replace(/^0+/, '');">
									</div>
								</div>

								<button class="btn btn-success w-100" type="submit" id="filterBtn">Apply</button>
							</form>
						</ul>
					</div>
				</div>
			</cfif>
			<!--- Product Listing --->
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
				<cfif len(trim(url.categoryId))>
					<!--- Encode Sub Category ID since it is passed to URL param --->
					<cfset variables.encodedSubCategoryId  = urlEncodedFormat(subCategoryId)>

					<a href="/products.cfm?subCategoryId=#variables.encodedSubCategoryId#" class="h4 text-decoration-none">#variables.subCategoryMapping[subCategoryId].name#</a>
				</cfif>
				<cf_productlist products="#variables.subCategoryMapping[subCategoryId].data#">
			</cfloop>

			<!--- View More Button --->
			<cfif variables.products.hasMoreRows>
				<div>
					<button class="btn btn-warning mx-3" id="viewMoreBtn" type="button" onclick="viewMore()">View More</button>
				</div>
			</cfif>
		<cfelse>
			<div class="fs-4 fw-semibold text-center mx-3 mt-4">No Products Found</div>
		</cfif>
	</div>
</cfoutput>
