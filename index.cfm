<cfset variables.qryRandomProducts = application.shoppingCart.getProducts(
	random = 1,
	limit = 12
)>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex align-items-center">
		<img class="w-100" src="assets/images/homepage-slider-1.jpg" alt="Slider Image 1">
	</div>

	<!--- Random Products --->
	<div class="h2 px-2 pt-3 pb-1">Random Products</div>
	<div class="d-flex flex-wrap px-3 py-1">
		<cfloop query="#variables.qryRandomProducts#">
			<div class="w-16 d-flex flex-column align-items-center border rounded border-dark mb-3">
				<img src="#application.productImageDirectory&variables.qryRandomProducts.fldProductImage#" class="productThumbnail" alt="Random Product Image">
				<div>
					<p class="fs-3 text-dark fw-semibold">#variables.qryRandomProducts.fldProductName#</p>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>