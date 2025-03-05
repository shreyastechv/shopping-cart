<!--- Url Params --->
<cfparam name="url.productId" default="">

<!--- Get Data --->
<cfset variables.addresses = application.dataFetch.getAddress()>
<cfset variables.addressEmpty = arrayLen(variables.addresses.data) EQ 0 ? "disabled" : "">

<!--- Variables to store total price and total actual price --->
<cfset variables.totalPrice = 0>
<cfset variables.totalActualPrice = 0>

<!--- Get product details into a session variable for easy quantity modifications --->
<cfset session.checkout = application.dataFetch.getCart(
	productId = url.productId
)>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column align-items-center m-3" id="mainContent">
		<h1 class="h3 p-2">Order Summary</h1>

		<div class="row w-100 my-2">
			<div class="col-md-8">
				<form method="post" name="checkoutForm" id="checkoutForm" onsubmit="handleCheckout()">
					<div class="accordion accordion-flush border rounded-2 shadow-sm" id="orderSummary">
						<!-- Address Section -->
						<div class="accordion-item">
							<h2 class="accordion-header">
								<button class="accordion-button collapsed text-uppercase fw-semibold" type="button" data-bs-toggle="collapse"
									data-bs-target="##flush-collapseOne" aria-expanded="false" aria-controls="flush-collapseOne"> Delivery Address
								</button>
							</h2>
							<div id="flush-collapseOne" class="accordion-collapse collapse show" data-bs-parent="##orderSummary">
								<div class="accordion-body pb-0">
									<cf_addresslist addresses="#variables.addresses.data#" currentPage="checkout">
								</div>
								<div class="d-flex align-items-center text-danger p-3 pt-0 checkoutError" id="addressAccordionError"></div>
								<div class="d-flex justify-content-between p-3 pt-0">
									<cf_addaddressbtn>
									<button type="button" data-bs-toggle="collapse" data-bs-target="##flush-collapseTwo"
										aria-expanded="false" aria-controls="flush-collapseTwo"class="btn btn-success" #variables.addressEmpty#>
										Next
									</button>
								</div>
							</div>
						</div>

						<!--- Products Section --->
						<div class="accordion-item">
							<h2 class="accordion-header">
								<button class="accordion-button collapsed text-uppercase fw-semibold" type="button" data-bs-toggle="collapse"
									data-bs-target="##flush-collapseTwo" aria-expanded="false" aria-controls="flush-collapseTwo" #variables.addressEmpty#>
									Product Details
								</button>
							</h2>
							<div id="flush-collapseTwo" class="accordion-collapse collapse" data-bs-parent="##orderSummary">
								<div class="accordion-body" id="accordionBody">
									<cf_cartproductlist products="#session.checkout.items#">
								</div>
								<div class="d-flex justify-content-end p-3">
									<button type="button" data-bs-toggle="collapse" data-bs-target="##flush-collapseThree"
										aria-expanded="false" aria-controls="flush-collapseThree"class="btn btn-success"
										id="productsNextBtn">
										Next
									</button>
								</div>
							</div>
						</div>

						<!--- Payment Options --->
						<div class="accordion-item">
							<h2 class="accordion-header">
								<button class="accordion-button collapsed text-uppercase fw-semibold" type="button" data-bs-toggle="collapse"
									data-bs-target="##flush-collapseThree" aria-expanded="false" aria-controls="flush-collapseThree"
									id="paymentSectionAccordionBtn" #variables.addressEmpty#>
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
												oninput="this.value = this.value.replace(/^-/g, '').replace(/[^0-9-]/g, '').replace(/(\d{4})(?=\d)/g, '$1-');"
												maxlength="19"
												placeholder="XXXX XXXX XXXX XXXX"
												autocomplete="cc-number">
											<div id="cardNumberError" class="form-text text-danger checkoutError"></div>
										</div>
										<div class="col-sm-4 mb-3">
											<label for="cvv" class="form-label">CVV</label>
											<input type="text"
												class="form-control cardInput"
												id="cvv"
												inputmode="numeric"
												oninput="this.value = this.value.replace(/[^0-9-]/g, '').replace(/(\d{4})(?=\d)/g, '$1-');"
												maxlength="3"
												placeholder="XXX"
												autocomplete="cc-csc">
											<div id="cvvError" class="form-text text-danger checkoutError"></div>
										</div>
									</div>
								</div>
								<div class="d-flex justify-content-end p-3">
									<div id="checkoutError" class="d-flex align-items-center justify-content-center text-danger me-4 checkoutError"></div>
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
						<cf_totalprice totalPrice="#variables.totalPrice#" totalActualPrice="#variables.totalActualPrice#" totalTax="#variables.totalTax#">
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Order Result Modal -->
	<div class="modal fade" id="orderResult" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1">
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
						<img src="#application.imageDirectory#order-success.jpg" width="200px" alt="Order Success Image">
						<div class="text-success fs-5">
							Order Placed Successfully
							<i class="fa-regular fa-circle-check"></i>
						</div>
						<a class="btn btn-primary" href="/orders.cfm">Go to Orders</a>
					</div>
					<div name="error" class="d-none d-flex flex-column align-items-center justify-content-center gap-3 py-3">
						<img src="#application.imageDirectory#order-failed.jpg" width="200px" alt="Order Failed Image">
						<div class="text-danger fs-5 d-flex align-items-center gap-2">
							<div id="orderResultError">Sorry! There was an error.</div>
							<i class="fa-solid fa-circle-exclamation"></i>
						</div>
						<a id="orderResultErrorBtn" class="btn btn-primary" href="/">Go to Home</a>
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>
