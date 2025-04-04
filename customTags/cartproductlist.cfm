<cfoutput>
	<!--- Variables --->
	<cfparam name="attributes.products" type="struct" default="#structNew()#">

	<!--- Get Product Details --->
	<cfif structCount(attributes.products)>
		<cfset variables.productInfo = application.dataFetch.getProducts(productIdList = structKeyList(attributes.products))>

		<cfloop array="#variables.productInfo.data#" item="item" index="i">
			<!--- Encode Product ID since it is passed to URL param --->
			<cfset variables.encodedProductId = urlEncodedFormat(item.productId)>

			<!--- Calculate price and actual price --->
			<cfset variables.quantity = attributes.products[item.productId].quantity>
			<cfset variables.actualPrice = item.price * variables.quantity>
			<cfset variables.price = item.price * (1 + (item.tax / 100)) * variables.quantity>

			<!--- Sum up total price and total actual price --->
			<cfset caller.totalPrice += variables.price>
			<cfset caller.totalActualPrice += variables.actualPrice>

			<!--- Set image if there is no product image --->
			<cfif arrayLen(item.productImages)>
				<cfset variables.productImage = application.productImageDirectory & item.productImages[1]>
			<cfelse>
				<cfset variables.productImage = application.imageDirectory & "no-image.png">
			</cfif>

			<div class="card mb-3 shadow" id="productContainer_#i#">
				<div class="row g-0">
					<div class="col-md-4 p-3">
						<a href="/productPage.cfm?productId=#variables.encodedProductId#">
							<img src="#variables.productImage#" class="img-fluid rounded-start" alt="Product Image #i#">
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
								<cfif attributes.products[item.productId].quantity EQ 1>
									disabled
								</cfif>
								>-</button>

								<input type="text" name="quantity" class="form-control text-center w-25" value="#attributes.products[item.productId].quantity#" onchange="handleQuantityChange('productContainer_#i#')" readonly>
								<button type="button" class="btn btn-outline-primary btn-sm ms-2" name="incBtn" onclick="editCartItem('productContainer_#i#', '#item.productId#', 'increment')">+</button>
							</div>
							<button type="button" class="btn btn-danger btn-sm mt-3" onclick="editCartItem('productContainer_#i#', '#item.productId#', 'delete')">Remove</button>
						</div>
					</div>
				</div>
			</div>
		</cfloop>
	<cfelse>
		<div id="empty-productlist" class="d-flex flex-column align-items-center justify-content-center pt-4">
			<div class="fs-5 text-secondary mb-3">Product List is Empty</div>
			<a class="btn btn-primary" href="/">Shop Now</a>
		</div>
	</cfif>
</cfoutput>
