<!--- Attribute Params --->
<cfparam name="attributes.products" type="struct" default={}>

<cfoutput>
	<cfloop collection="#attributes.products#" item="productId">
		<!--- Get Product Details --->
		<cfset local.qryProductInfo = application.shoppingCart.getProducts(productId = productId)>

		<!--- Encrypt Product ID since it is passed to URL param --->
		<cfset variables.encryptedProductId = application.shoppingCart.encryptUrlParam(productId)>

		<!--- Calculate price and actual price --->
		<cfset local.quantity = attributes.products[productId].quantity>
		<cfset local.actualPrice = local.qryProductInfo.fldPrice * local.quantity>
		<cfset local.price = local.qryProductInfo.fldPrice * (1 + (local.qryProductInfo.fldTax / 100)) * local.quantity>

		<!--- Sum up total price and total actual price --->
		<cfset caller.totalPrice += local.price>
		<cfset caller.totalActualPrice += local.actualPrice>

		<!--- Generate random id for the mian container div --->
		<cfset local.randomId = replace(rand(), ".", "", "all")>

		<div class="card mb-3 shadow" id="#local.randomId#">
			<div class="row g-0">
				<div class="col-md-4 p-3">
					<a href="/productPage.cfm?productId=#variables.encryptedProductId#">
						<img src="#application.productImageDirectory&local.qryProductInfo.fldProductImage#" class="img-fluid rounded-start" alt="Product">
					</a>
				</div>
				<div class="col-md-8">
					<div class="card-body">
						<h5 class="card-title">#local.qryProductInfo.fldProductName#</h5>
						<p class="mb-1">Price: <span class="fw-bold">Rs. <span name="price">#local.price#</span></span></p>
						<p class="mb-1">Actual Price: <span class="fw-bold">Rs. <span name="actualPrice">#local.actualPrice#</span></span></p>
						<p class="mb-1">Tax: <span class="fw-bold"><span name="tax">#local.qryProductInfo.fldTax#</span> %</span></p>
						<div class="d-flex align-items-center">
							<button type="button" class="btn btn-outline-primary btn-sm me-2" name="decBtn" onclick="editCartItem('#local.randomId#', #productId#, 'decrement')"
							<cfif attributes.products[productId].quantity EQ 1>
								disabled
							</cfif>
							>-</button>

							<input type="text" name="quantity" class="form-control text-center w-25" value="#attributes.products[productId].quantity#" onchange="handleQuantityChange('#local.randomId#')" readonly>
							<button type="button" class="btn btn-outline-primary btn-sm ms-2" name="incBtn" onclick="editCartItem('#local.randomId#', #productId#, 'increment')">+</button>
						</div>
						<button type="button" class="btn btn-danger btn-sm mt-3" onclick="editCartItem('#local.randomid#', #productId#, 'delete')">Remove</button>
					</div>
				</div>
			</div>
		</div>
	</cfloop>
</cfoutput>
