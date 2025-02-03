<!--- Get Data --->
<cfset variables.orders = application.shoppingCart.getOrders()>

<cfoutput>
	<div class="container py-4">
		<h2 class="text-center mb-4">Your Orders</h2>
		<input type="text" id="searchOrders" class="form-control mb-3 shadow" placeholder="Search orders using order id...">

		<div id="ordersContainer">
			<cfloop array="#variables.orders.data#" item="local.order">
				<div class="card shadow p-3 mb-4" data-order-id="#local.order.orderId#">
					<div class="d-flex flex-xl-row flex-column justify-content-between">
						<h2 class="h6 mb-3"><strong>Order ID:</strong> #local.order.orderId#</h5>
						<p><strong>Order Date:</strong> #local.order.orderDate#</p>
						<p><strong>Total Price:</strong> Rs. #local.order.totalPrice#</p>
					</div>
					<div class="table-responsive">
						<table class="table table-striped table-bordered">
							<tbody>
								<tr>
									<td rowspan="3" class="text-center align-middle">
										<img src="https://placehold.co/80" class="img-fluid rounded" alt="Product">
									</td>
									<td><strong>Product:</strong> Smartphone X</td>
									<td><strong>Price:</strong> $999.99</td>
								</tr>
								<tr>
									<td><strong>Brand:</strong> TechCorp</td>
									<td><strong>Tax:</strong> $99.99</td>
								<tr>
									<td><strong>Quantity:</strong> 1</td>
									<td><strong>Total:</strong> $1099.98</td>
								</tr>
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
