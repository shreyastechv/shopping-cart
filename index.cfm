<cfset variables.arrayRandomProducts = application.shoppingCart.getRandomProducts()>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex align-items-center">
		<img class="img-fluid" src="assets/images/homepage-slider-1.jpg" alt="Slider Image 1">
	</div>

	<!--- Random Products --->
	<div class="h2 px-2 pt-3 pb-1">Random Products</div>
	<div class="d-flex flex-wrap px-3 py-1">
		<cfloop array="#variables.arrayRandomProducts#" item="local.product">
			<div class="w-25 d-flex flex-column align-items-center border rounded border-dark mb-3">
				<img src="#application.productImageDirectory&local.product.imageFile#" class="productThumbnail" alt="Random Product Image">
				<div>
					<p class="text-dark fw-semibold">#local.product.productName#</p>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>