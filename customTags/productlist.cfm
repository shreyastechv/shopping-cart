<cfoutput>
	<!--- Attribute Params --->
	<cfparam name="attributes.products" default="#arrayNew(1)#">

	<div class="row px-3 py-1" id="products">
		<cfloop array="#attributes.products#" item="item" index="index">
			<!--- Encode Product ID since it is passed to URL param --->
			<cfset variables.encodedProductId = urlEncodedFormat(item.productId)>

			<div class="col-sm-2 mb-4">
				<div class="card rounded-3 h-100 shadow" onclick="location.href='/productPage.cfm?productId=#variables.encodedProductId#'" role="button">

					<!--- Show carousel if there are images otherwise show a default image --->
					<cfif arrayLen(item.productImages)>
						<div id="productListCarousel" class="carousel productList slide" data-bs-ride="carousel" data-bs-interval="700">
							<div class="carousel-inner productList">
								<cfloop array="#item.productImages#" item="imageItem" index="imageIndex">
									<div class="carousel-item productList #(imageIndex EQ 1 ? 'active' : '')#">
										<img src="#application.productImageDirectory&imageItem#" class="p-3 rounded-3" alt="Product Image #index & "-" & imageIndex#">
									</div>
								</cfloop>
							</div>
						</div>
					<cfelse>
						<img src="#application.imageDirectory & "no-image.png"#" class="p-3 rounded-3" alt="Product Image #index#">
					</cfif>

					<div class="card-body">
						<div class="card-text text-truncate fw-semibold mb-1">#item.productName#</div>
						<div class="card-text text-secondary text-truncate mb-1">#item.description#</div>
						<div class="card-text fw-bold mb-1">Rs. #item.price#</div>
					</div>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>
