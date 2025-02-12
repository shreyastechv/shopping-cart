<!--- Variables to store total price and total actual price --->
<cfset variables.totalPrice = 0>
<cfset variables.totalActualPrice = 0>

<cfoutput>
	<div class="container my-5">
		<cfif structKeyExists(session, "cart") AND structCount(session.cart)>
			<div class="row">
				<!-- Products Section -->
				<div class="col-md-8">
					<cf_cartproductlist products="#session.cart#">
				</div>

				<!--- Calculate Total Tax amount --->
				<cfset variables.totalTax = variables.totalPrice - variables.totalActualPrice>

				<!-- Price Details Section -->
				<div class="col-md-4">
					<div class="card shadow">
						<div class="card-body">
							<h4 class="card-title">Price Details</h4>
							<hr>
							<cf_totalprice totalPrice="#variables.totalPrice#" totalActualPrice="#variables.totalActualPrice#" totalTax="#variables.totalTax#">
							<button class="btn btn-success w-100" onclick="location.href='checkout.cfm'">Checkout</button>
						</div>
					</div>
				</div>
			</div>
		<cfelse>
			<div class="d-flex flex-column align-items-center justify-content-center">
				<img src="#application.imageDirectory#empty-cart.svg" width="300" alt="Shopping Cart Empty">
				<div class="fs-5 mb-3">Shopping Cart is Empty</div>
				<a class="btn btn-primary" href="/">Shop Now</a>
			</div>
		</cfif>
	</div>
</cfoutput>
