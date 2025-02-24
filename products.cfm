<!--- URL Params --->
<cfparam name="url.categoryId" default="">
<cfparam name="url.subCategoryId" default="">
<cfparam name="url.search" default="">
<cfparam name="url.sort" default="">

<!--- Form Variables --->
<cfparam name="url.min" default=0>
<cfparam name="url.max" default=0>

<!--- Other variables --->
<cfparam name="variables.categoryName" default="">
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

	<cfif arrayLen(variables.products.data)>
		<cfset variables.categoryName = variables.products.data[1].categoryName>
	<cfelse>
		<cfset variables.categoryName = application.dataFetch.getCategories(
			categoryId = url.categoryId
		).data[1].categoryName>
	</cfif>
<cfelseif len(trim(url.subCategoryId)) OR len(trim(url.search))>
	<!--- Sub Category or Search Product Listing --->
	<cfset variables.products = application.dataFetch.getProducts(
		subCategoryId = url.subCategoryId,
		searchTerm = trim(url.search),
		limit = variables.limit,
		min = val(url.min),
		max = val(url.max),
		sort = (arrayContainsNoCase(["","asc","desc"], url.sort) ? url.sort : "")
	)>
<cfelse>
	<cflocation url="/" addToken="false">
</cfif>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column mx-2 mt-4 mb-5">
		<cfif len(trim(url.categoryId))>
			<div class="h4 fw-normal text-muted">#variables.categoryName#</div>
			<hr class="text-muted m-0 p-0 opacity-25">
		<cfelse>
			<!--- Don't show sorting and filtering for category product listing --->
			<div class="d-flex justify-content-start p-1">
				<!--- Sorting --->
				<div class="d-flex px-3 pb-2 gap-2">
					<select class="form-select shadow-sm" id="sortSelect">
						<option value="featured" selected>Featured</option>
						<option value="price-asc" #(url.sort EQ "asc" ? "selected" : "")#>Price - Low to High</option>
						<option value="price-desc" #(url.sort EQ "desc" ? "selected" : "")#>Price - High to Low</option>
					</select>
				</div>

				<!--- Filtering --->
				<div class="filter dropdown pe-3">
					<button class="btn btn-secondary me-2 shadow-sm" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside" aria-expanded="false">
						<i class="fa-solid fa-filter-circle-dollar"></i>
						Filter
					</button>
					<ul class="productFilterMenu dropdown-menu p-3 shadow-lg">
						<div class="d-flex align-items-center justify-content-between fw-semibold mb-2 gap-2">
							Price Filter
						</div>

						<div class="d-flex gap-2">
							<div>
								<label for="min">Min</label>
								<input type="number" class="form-control mb-2" id="min" name="min" min="0" step="500" value="#url.min#"
									oninput="this.value = this.value.replace(/^0+/, '');">
							</div>
							<div class="d-flex">
								<button type="button" class="btn btn-sm mt-3" onclick="swapFilter()">
									<i class="fa-solid fa-right-left pe-none"></i>
								</button>
							</div>
							<div>
								<label for="max">Max</label>
								<input type="number" class="form-control mb-2" id="max" name="max" max="10000000" step="500" value="#url.max#"
									oninput="this.value = this.value.replace(/^0+/, '');">
							</div>
						</div>

						<button class="btn btn-success w-100" type="submit" id="filterBtn" onclick="applyFilter()">Apply</button>
					</ul>
					<cfif val(url.min) OR val(url.max)>
						<button type="button" id="clearFilterBtn" class="btn btn-outline-danger shadow-sm" onclick="clearFilter()">
							<i class="fa-solid fa-circle-xmark"></i>
							Clear Filter
						</button>
					</cfif>
				</div>
			</div>
		</cfif>
		<cfif arrayLen(variables.products.data)>
			<cfif len(trim(url.categoryId))>
				<!--- Category Product Listing --->
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

						<div class="px-3 pt-3 pb-2">
							<a href="/products.cfm?subCategoryId=#variables.encodedSubCategoryId#" class="h5 text-decoration-none">
								#variables.subCategoryMapping[subCategoryId].name#
								<i class="fs-6 fa-solid fa-circle-chevron-right ms-1"></i>
							</a>
						</div>
					</cfif>
					<cf_productlist products="#variables.subCategoryMapping[subCategoryId].data#">
				</cfloop>
			<cfelse>
				<!--- Sub category / Search Product listing --->
				<cf_productlist products="#variables.products.data#">
			</cfif>

			<!--- View More Button --->
			<cfif variables.products.hasMoreRows AND NOT len(trim(url.categoryId))>
				<div>
					<button class="btn btn-warning mx-3" id="viewMoreBtn" type="button" onclick="viewMore()">View More</button>
				</div>
			</cfif>
		<cfelse>
			<div class="d-flex flex-column align-items-center justify-content-center">
				<img src="#application.imageDirectory#empty-cart.svg" width="300" alt="Shopping Cart Empty">
				<div class="fs-4 fw-semibold text-center mx-3">No Products Found</div>
			</div>
		</cfif>
	</div>
</cfoutput>
