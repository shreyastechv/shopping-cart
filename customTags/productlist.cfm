<cfoutput>
	<!--- Attribute Params --->
	<cfparam name="attributes.products" default="#arrayNew(1)#">

	<div class="row px-3 py-1" id="products">
		<cfloop array="#attributes.products#" item="item">
			<!--- Encode Product ID since it is passed to URL param --->
			<cfset variables.encodedProductId = urlEncodedFormat(item.productId)>

			<div class="col-sm-2 mb-4">
				<div class="card rounded-3 h-100 shadow" onclick="location.href='/productPage.cfm?productId=#variables.encodedProductId#'" role="button">
					<img src="#application.productImageDirectory&listGetAt(item.productImages, 1)#" class="p-3 rounded-3" alt="Random Product Image">
					<div class="card-body">
						<div class="card-text fw-semibold mb-1">#item.productName#</div>
						<div class="card-text text-secondary text-truncate mb-1">#item.description#</div>
						<div class="card-text fw-bold mb-1">Rs. #item.price#</div>
					</div>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>
