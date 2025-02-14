<cfoutput>
	<!--- Variables --->
	<cfparam name="attributes.products" type="struct" default="#structNew()#">
	<cfparam name="variables.products" type="struct" default="#structNew()#">

	<!--- Get products with non-zero quantity --->
	<cfset variables.products = attributes.products.filter(function(key, val) {
		if (isStruct(val) && val.quantity != 0) {
			return true;
		}
		return false;
	})>

	<!--- Get Product Details --->
	<cfif structCount(variables.products)>
		<cfset variables.productInfo = application.shoppingCart.getProducts(productIdList = structKeyList(variables.products))>

		<cfloop array="#variables.productInfo.data#" item="item" index="i">
			<!--- Encode Product ID since it is passed to URL param --->
			<cfset variables.encodedProductId = urlEncodedFormat(item.productId)>

			<!--- Calculate price and tax so that in cfc, we don't have another db call --->
			<!--- This also makes sure that the price of product shown in cart is up-to-date --->
			<cfif cgi.SCRIPT_NAME EQ "/cart.cfm">
				<cfset session.cart[item.productId].unitPrice = item.price>
				<cfset session.cart[item.productId].unitTax = item.tax>
			<cfelse>
				<cfset session.checkout[item.productId].unitPrice = item.price>
				<cfset session.checkout[item.productId].unitTax = item.tax>
			</cfif>

			<!--- Calculate price and actual price --->
			<cfset variables.quantity = variables.products[item.productId].quantity>
			<cfset variables.actualPrice = item.price * variables.quantity>
			<cfset variables.price = item.price * (1 + (item.tax / 100)) * variables.quantity>

			<!--- Sum up total price and total actual price --->
			<cfset caller.totalPrice += variables.price>
			<cfset caller.totalActualPrice += variables.actualPrice>

			<div class="card mb-3 shadow" id="productContainer_#i#">
				<div class="row g-0">
					<div class="col-md-4 p-3">
						<a href="/productPage.cfm?productId=#variables.encodedProductId#">
							<img src="#application.productImageDirectory&item.productImage#" class="img-fluid rounded-start" alt="Product">
						</a>
					</div>
					<div class="col-md-8">
						<div class="card-body">
							<h5 class="card-title">#item.productName#</h5>
							<p class="mb-1">Price: <span class="fw-bold">Rs. <span name="price">#variables.price#</span></span></p>
							<p class="mb-1">Actual Price: <span class="fw-bold">Rs. <span name="actualPrice">#variables.actualPrice#</span></span></p>
							<p class="mb-1">Tax: <span class="fw-bold"><span name="tax">#item.tax#</span> %</span></p>
							<div class="d-flex align-items-center">
								<button type="button" class="btn btn-outline-primary btn-sm me-2" name="decBtn" onclick="editCartItem('productContainer_#i#', '#item.productId#', 'decrement')"
								<cfif variables.products[item.productId].quantity EQ 1>
									disabled
								</cfif>
								>-</button>

								<input type="text" name="quantity" class="form-control text-center w-25" value="#variables.products[item.productId].quantity#" onchange="handleQuantityChange('productContainer_#i#')" readonly>
								<button type="button" class="btn btn-outline-primary btn-sm ms-2" name="incBtn" onclick="editCartItem('productContainer_#i#', '#item.productId#', 'increment')">+</button>
							</div>
							<button type="button" class="btn btn-danger btn-sm mt-3" onclick="editCartItem('productContainer_#i#', '#item.productId#', 'delete')">Remove</button>
						</div>
					</div>
				</div>
			</div>
		</cfloop>
	</cfif>
</cfoutput>
