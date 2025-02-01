<!--- Redirect to login page if user is not logged in --->
<cfif NOT structKeyExists(session, "userId")>
	<cflocation url="/login.cfm" addToken="no">
</cfif>

<!--- Set default value for productId --->
<cfparam name="form.productId" default="">

<!--- Get Data --->
<cfset variables.addresses = application.shoppingCart.getAddress()>

<!--- Variables to store total price and total actual price --->
<cfset variables.totalPrice = 0>
<cfset variables.totalActualPrice = 0>

<!--- Variable to store products (different for buy now and cart checkout) --->
<cfif structKeyExists(form, "productId") AND len(trim(form.productId))>
	<!--- Get product price details since this is not in cart --->
	<cfset variables.productDetails = application.shoppingCart.getProducts(
		productId = form.productId
	)>

	<!--- Product details when this page was opened by clicking buy now from product page --->
	<cfset variables.products[form.productId] = {
		"quantity" = 1,
		"unitPrice" = variables.productDetails.fldPrice,
		"unitTax" = variables.productDetails.fldTax
	}>

	<!--- Session variable to store checkout products --->
	<cfset session.checkout = duplicate(variables.products)>
<cfelseif structKeyExists(session, "cart") AND structCount(session.cart)>
	<!--- Product details when this page was opened by clicking clicking checkout from cart page --->
	<cfset variables.products = session.cart>

	<!--- Session variable to store checkout products --->
	<cfset session.checkout = duplicate(session.cart)>
<cfelse>
	<!--- If this page was opened by user and cart is empty --->
	<cflocation  url="/cart.cfm" addToken="no">
</cfif>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column align-items-center m-3" id="mainContent">
		<h1 class="h3 p-2">Order Summary</h1>

		<div class="row w-100 my-2">
			<div class="col-md-8">
				<form method="post" id="checkoutForm">
					<div class="accordion accordion-flush border rounded-2 shadow-sm" id="orderSummary">
						<!-- Address Section -->
						<div class="accordion-item">
							<h2 class="accordion-header">
								<button class="accordion-button collapsed text-uppercase fw-semibold" type="button" data-bs-toggle="collapse"
									data-bs-target="##flush-collapseOne" aria-expanded="false" aria-controls="flush-collapseOne"> Delivery Address
								</button>
							</h2>
							<div id="flush-collapseOne" class="accordion-collapse collapse show" data-bs-parent="##orderSummary">
								<div class="accordion-body">
									<div class="list-group">
										<cfif arrayLen(variables.addresses)>
											<cfloop array="#variables.addresses#" item="local.address">
												<div class="d-flex justify-content-between list-group-item shadow-sm mb-3">
													<div>
														<p class="fw-semibold mb-1">
															#local.address.fullName# -
															#local.address.phone#
														</p>
														<p class="mb-1">#local.address.addressLine1#</p>
														<p class="mb-0">#local.address.addressLine2#</p>
														<div class="mb-0">
															#local.address.city#,
															#local.address.state# -
															<span class="fw-semibold">#local.address.pincode#</span>
														</div>
													</div>
													<div class="d-flex align-items-center px-4">
														<input type="radio" name="addressId" value="#local.address.addressId#" checked>
													</div>
												</div>
											</cfloop>
										<cfelse>
											<div class="text-secondary">No Address Saved</div>
										</cfif>
									</div>
								</div>
								<div class="d-flex justify-content-end p-3">
									<button type="button" data-bs-toggle="collapse" data-bs-target="##flush-collapseTwo"
										aria-expanded="false" aria-controls="flush-collapseTwo"class="btn btn-success">
										Next
									</button>
								</div>
							</div>
						</div>

						<!--- Products Section --->
						<div class="accordion-item">
							<h2 class="accordion-header">
								<button class="accordion-button collapsed text-uppercase fw-semibold" type="button" data-bs-toggle="collapse"
									data-bs-target="##flush-collapseTwo" aria-expanded="false" aria-controls="flush-collapseTwo">
									Product Details
								</button>
							</h2>
							<div id="flush-collapseTwo" class="accordion-collapse collapse" data-bs-parent="##orderSummary">
								<div class="accordion-body">
									<cfloop collection="#variables.products#" item="local.productId">
										<!--- Get Product Details --->
										<cfset local.qryProductInfo = application.shoppingCart.getProducts(productId = local.productId)>

										<!--- Encrypt Product ID since it is passed to URL param --->
										<cfset variables.encryptedProductId = application.shoppingCart.encryptUrlParam(local.productId)>

										<!--- Calculate price and actual price --->
										<cfset local.quantity = session.cart[local.productId].quantity>
										<cfset local.actualPrice = local.qryProductInfo.fldPrice * local.quantity>
										<cfset local.price = local.qryProductInfo.fldPrice * (1 + (local.qryProductInfo.fldTax / 100)) * local.quantity>

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
														<p class="mb-1">Price: <span class="fw-bold">Rs. <span name="price">#local.price#</span></span></p>
														<p class="mb-1">Actual Price: <span class="fw-bold">Rs. <span name="actualPrice">#local.actualPrice#</span></span></p>
														<p class="mb-1">Tax: <span class="fw-bold"><span name="tax">#local.qryProductInfo.fldTax#</span> %</span></p>
														<div class="d-flex align-items-center">
															<button class="btn btn-outline-primary btn-sm me-2" name="decBtn" onclick="editCartItem('#local.randomId#', #local.productId#, 'decrement')"
															<cfif variables.products[local.productId].quantity EQ 1>
																disabled
															</cfif>
															>-</button>

															<input type="text" name="quantity" class="form-control text-center w-25" value="#variables.products[local.productId].quantity#" onchange="handleQuantityChange('#local.randomId#')" readonly>
															<button class="btn btn-outline-primary btn-sm ms-2" name="incBtn" onclick="editCartItem('#local.randomId#', #local.productId#, 'increment')">+</button>
														</div>
														<button class="btn btn-danger btn-sm mt-3" onclick="editCartItem('#local.randomid#', #local.productId#, 'delete')">Remove</button>
													</div>
												</div>
											</div>
										</div>
									</cfloop>
								</div>
								<div class="d-flex justify-content-end p-3">
									<button type="button" data-bs-toggle="collapse" data-bs-target="##flush-collapseThree"
										aria-expanded="false" aria-controls="flush-collapseThree"class="btn btn-success">
										Next
									</button>
								</div>
							</div>
						</div>

						<!--- Payment Options --->
						<div class="accordion-item">
							<h2 class="accordion-header">
								<button class="accordion-button collapsed text-uppercase fw-semibold" type="button" data-bs-toggle="collapse"
									data-bs-target="##flush-collapseThree" aria-expanded="false" aria-controls="flush-collapseThree">
									Payment Options
								</button>
							</h2>
							<div id="flush-collapseThree" class="accordion-collapse collapse" data-bs-parent="##orderSummary">
								<div class="accordion-body">
									<div class="row">
										<div class="col-sm-8 mb-3">
											<label for="cardNumber" class="form-label" >Card Number</label>
											<input type="text"
												inputmode="numeric"
												class="form-control cardInput"
												id="cardNumber"
												inputmode="numeric"
												oninput="this.value = this.value.replace(/[^0-9-]/g, '').replace(/(\d{4})(?=\d)/g, '$1-').slice(0, this.maxLength);"
												maxlength="19"
												placeholder="XXXX XXXX XXXX XXXX"
												autocomplete="cc-number"
												required>
											<div id="cardNumberError" class="form-text text-danger cardError"></div>
										</div>
										<div class="col-sm-4 mb-3">
											<label for="cvv" class="form-label">CVV</label>
											<input type="text"
												class="form-control cardInput"
												id="cvv"
												inputmode="numeric"
												oninput="this.value = this.value.replace(/[^0-9-]/g, '').replace(/(\d{4})(?=\d)/g, '$1-').slice(0, this.maxLength);"
												maxlength="3"
												placeholder="XXX"
												autocomplete="cc-csc"
												required>
											<div id="cvvError" class="form-text text-danger cardError"></div>
										</div>
									</div>
								</div>
								<div class="d-flex justify-content-end p-3">
									<button type="submit" class="btn btn-success" onclick="handleCheckout('#form.productId#')">
										Continue
									</button>
								</div>
							</div>
						</div>
					</div>
				</div>
			</form>

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
							<span class="fw-bold">Rs. <span id="totalPrice">#variables.totalPrice#</span></span>
						</p>
						<p class="d-flex justify-content-between">
							<span>Total Tax:</span>
							<span class="fw-bold">Rs. <span id="totalTax">#variables.totalTax#</span></span>
						</p>
						<p class="d-flex justify-content-between">
							<span>Actual Price:</span>
							<span class="fw-bold">Rs. <span id="totalActualPrice">#variables.totalActualPrice#</span></span>
						</p>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Order Success Modal -->
	<div class="modal fade" id="orderSuccess" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1"
		aria-labelledby="orderSuccessLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<div class="modal-body d-flex flex-column align-items-center justify-content-center p-4 gap-3">
					<div name="loading" class="text-info d-flex justify-content-center gap-2">
						<div class="spinner-border" role="status">
							<span class="visually-hidden">Please wait...</span>
						</div>
						<div class="fs-5">
							Please wait...
						</div>
					</div>
					<div name="success" class="d-none d-flex flex-column align-items-center justify-content-center gap-3 py-3">
						<img src="/assets/images/order-success.jpg" width="200px" alt="Order Success Image">
						<div class="text-success fs-5">
							Order Placed Successfully
							<i class="fa-regular fa-circle-check"></i>
						</div>
						<a class="btn btn-primary" href="/">Continue</a>
					<div name="error" class="d-none d-flex flex-column align-items-center justify-content-center gap-3 py-3">
						<img src="/assets/images/order-success.jpg" width="200px" alt="Order Success Image">
						<div class="text-danger fs-5">
							Sorry! There was an error.
							<i class="fa-regular fa-circle-check"></i>
						</div>
						<a class="btn btn-primary" href="/">Go to Home</a>
					</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>
