<!--- Redirect to login page if user is not logged in --->
<cfif NOT structKeyExists(session, "userId")>
	<cflocation url="/login.cfm" addToken="no">
</cfif>

<!--- Get Data --->
<cfset variables.addresses = application.shoppingCart.getAddress()>

<!--- Variables to store total price and total actual price --->
<cfset variables.totalPrice = 0>
<cfset variables.totalActualPrice = 0>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column align-items-center m-3">
		<h1 class="h3 p-2">Order Summary</h1>

		<div class="row w-100 my-2">
			<div class="col-md-8">
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
													<p class="mb-1">Price: <span class="fw-bold">Rs. <span name="price">#local.price#</span></span></p>
													<p class="mb-1">Actual Price: <span class="fw-bold">Rs. <span name="actualPrice">#local.actualPrice#</span></span></p>
													<p class="mb-1">Tax: <span class="fw-bold"><span name="tax">#local.qryProductInfo.fldTax#</span> %</span></p>
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
										<input id="ccn" type="tel" inputmode="numeric" pattern="[0-9\s]{13,19}"
											class="form-control" id="cardNumber"
											autocomplete="cc-number" maxlength="19"
											placeholder="XXXX XXXX XXXX XXXX" required>
										<div id="cardNumberError" class="form-text text-danger"></div>
									</div>
									<div class="col-sm-4 mb-3">
										<label for="cvv" class="form-label">CVV</label>
										<input id="cvv" type="number" max="999" pattern="([0-9]|[0-9]|[0-9])"
										class="form-control" placeholder="XXX">
										<div id="cvvError" class="form-text text-danger"></div>
									</div>
								</div>
							</div>
							<div class="d-flex justify-content-end p-3">
								<button type="button" class="btn btn-success" onclick="handleOrderCheckout()">
									Continue
								</button>
							</div>
						</div>
					</div>
				</div>
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
</cfoutput>