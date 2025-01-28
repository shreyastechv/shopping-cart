<!--- Redirect to login page if user is not logged in --->
<cfif NOT structKeyExists(session, "cart")>
	<cflocation url="/login.cfm?redirect=cart.cfm" addToken="no">
</cfif>

<!--- Variables to store total price and total actual price --->
<cfset variables.totalPrice = 0>
<cfset variables.totalActualPrice = 0>

<cfoutput>
	<div class="container my-5">
<div id="maxQuantityAlert" class="alert alert-warning alert-dismissible fade show d-none" role="alert">
  <strong>Hey, #session.fullName#</strong> Maximum allowed quantity for this item is reached.
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
		<div class="row">
			<!-- Products Section -->
			<div class="col-md-8">
				<cfloop collection="#session.cart#" item="local.productId">
					<!--- Get Product Details --->
					<cfset local.qryProductInfo = application.shoppingCart.getProducts(productId = local.productId)>

					<!--- Encrypt Product ID since it is passed to URL param --->
					<cfset variables.encryptedProductId = application.shoppingCart.encryptUrlParam(local.productId)>

					<!--- Calculate price and actual price --->
					<cfset local.actualPrice = local.qryProductInfo.fldPrice>
					<cfset local.price = local.qryProductInfo.fldPrice * (100 + local.qryProductInfo.fldTax) / 100>

					<!--- Sum up total price and total actual price --->
					<cfset variables.totalPrice += local.price>
					<cfset variables.totalActualPrice += local.actualPrice>

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
									<p class="mb-1">Price: <span class="fw-bold">Rs. #local.price#</span></p>
									<p class="mb-1">Actual Price: <span class="fw-bold">Rs. #local.actualPrice#</span></p>
									<p class="mb-1">Tax: <span class="fw-bold">#local.qryProductInfo.fldTax# %</span></p>
									<div class="d-flex align-items-center">
										<button class="btn btn-outline-primary btn-sm me-2" name="decBtn" onclick="editCartItem('#local.randomId#', #local.productId#, 'decrement')"
										<cfif session.cart[local.productId].quantity EQ 1>
											disabled
										</cfif>
										>-</button>

										<input type="text" name="quantity" class="form-control text-center w-25" value="#session.cart[local.productId].quantity#" onchange="handleQuantityChange('#local.randomId#')" readonly>
										<button class="btn btn-outline-primary btn-sm ms-2" name="incBtn" onclick="editCartItem('#local.randomId#', #local.productId#, 'increment')">+</button>
									</div>
									<button class="btn btn-danger btn-sm mt-3" onclick="editCartItem('#local.randomid#', #local.productId#, 'delete')">Remove</button>
								</div>
							</div>
						</div>
					</div>
				</cfloop>
			</div>

			<!--- Calculate Total Tax amount --->
			<cfset variables.totalTax = variables.totalPrice - variables.totalActualPrice>

			<!-- Price Details Section -->
			<div class="col-md-4">
				<div class="card shadow">
					<div class="card-body">
						<h4 class="card-title">Price Details</h4>
						<hr>
						<p class="d-flex justify-content-between">
							<span>Total Price:</span>
							<span class="fw-bold">Rs. #variables.totalPrice#</span>
						</p>
						<p class="d-flex justify-content-between">
							<span>Total Tax:</span>
							<span class="fw-bold">Rs. #variables.totalTax#</span>
						</p>
						<p class="d-flex justify-content-between">
							<span>Actual Price:</span>
							<span class="fw-bold">Rs. #variables.totalActualPrice#</span>
						</p>
						<button class="btn btn-success w-100">Checkout</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>