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
				<form method="post" id="checkoutForm" onsubmit="handleCheckout()">
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
											<cf_addresslist addresses="#variables.addresses#" currentPage="checkout">
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
									<cf_cartproductlist products="#variables.products#">
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
												autocomplete="cc-number">
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
												autocomplete="cc-csc">
											<div id="cvvError" class="form-text text-danger cardError"></div>
										</div>
									</div>
								</div>
								<div class="d-flex justify-content-end p-3">
									<button type="submit" class="btn btn-success">
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
						<cf_totalprice totalPrice=#variables.totalPrice# totalActualPrice="#variables.totalActualPrice#" totalTax="#variables.totalTax#">
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
