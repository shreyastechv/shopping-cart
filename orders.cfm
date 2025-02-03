<!--- Get Data --->
<cfset variables.orders = application.shoppingCart.getOrders()>

<cfoutput>
	<div class="container py-4">
		<h2 class="text-center mb-4">Your Orders</h2>
		<input type="text" id="searchOrders" class="form-control mb-3 shadow" placeholder="Search orders using order id...">

		<div id="ordersContainer">
			<cfloop array="#variables.orders.data#" item="local.order">
				<div class="card order-card shadow p-3 mb-4" data-order-id="#local.order.orderId#">
					<div class="d-flex flex-xl-row flex-column justify-content-between">
						<h2 class="h6 mb-3"><strong>Order ID:</strong> #local.order.orderId#</h5>
						<p><strong>Order Date:</strong> #dateTimeFormat(local.order.orderDate, "mmm d YYYY h:n tt")#</p>
						<p><strong>Total Price:</strong> Rs. #local.order.totalPrice#</p>
					</div>
					<div class="table-responsive">
						<table class="table table-striped table-bordered">
							<tbody>
								<cfloop list="#local.order.productNames#" item="local.item" index="local.i">
									<cfset local.unitPrice = listGetAt(local.order.unitPrices, local.i)>
									<cfset local.unitTax = listGetAt(local.order.unitTaxes, local.i)>
									<cfset local.price = local.unitPrice + local.unitTax>
									<cfset local.quantity = listGetAt(local.order.quantities, local.i)>
									<cfset local.productName = listGetAt(local.order.productNames, local.i)>
									<cfset local.brandName = listGetAt(local.order.brandNames, local.i)>
									<cfset local.productImage = listGetAt(local.order.productImages, local.i)>

									<tr>
										<td rowspan="3" class="text-center align-middle">
											<img src="#application.productImageDirectory&local.productImage#" class="img-fluid rounded" width="100" alt="Product">
										</td>
										<td><strong>Product:</strong> #local.productName#</td>
										<td><strong>Price:</strong> Rs. #local.unitPrice#</td>
									</tr>
									<tr>
										<td><strong>Brand:</strong> #local.brandName#</td>
										<td><strong>Tax:</strong> Rs. #local.unitTax#</td>
									<tr>
										<td><strong>Quantity:</strong> #local.quantity#</td>
										<td><strong>Total:</strong> Rs. #local.price#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					</div>
					<div class="d-flex flex-md-row flex-column justify-content-between">
						<p><strong>Delivery Address:</strong> 123 Main Street, City, Country</p>
						<p><strong>Contact:</strong> John Doe, +1234567890</p>
					</div>
					<button class="btn btn-primary">Download Invoice</button>
				</div>
			</cfloop>
		</div>
	</div>
</cfoutput>
