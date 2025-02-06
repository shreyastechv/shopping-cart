<cfset variables.qryRandomProducts = application.shoppingCart.getProducts(
	random = 1,
	limit = 12
)>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex align-items-center">
		<img class="w-100" src="#application.imageDirectory#homepage-slider-1.jpg" alt="Slider Image 1">
	</div>

	<!--- Random Products --->
	<div class="h2 px-2 pt-3 pb-1">Random Products</div>
	<cf_productlist qryProducts="#variables.qryRandomProducts#">
</cfoutput>
