<!--- Get Data --->
<cfset variables.orders = application.shoppingCart.getOrders()>

<cfoutput>
	<div class="container py-4">
		<h2 class="text-center mb-4">Your Orders</h2>
		<input type="text" id="searchOrders" class="form-control mb-3 shadow" placeholder="Search orders using order id...">

		<div id="ordersContainer">
			<cfloop array="#variables.orders.data#" item="local.order">
				<div class="card order-card shadow p-3 mb-4" data-order-id="#local.order.orderId#">
					<div class="d-flex flex-lg-row flex-column align-items-center justify-content-between mb-2 px-1">
						<div class="mb-0"><strong>Order ID:</strong> #local.order.orderId#</div>
						<div class="mb-0"><strong>Order Date:</strong> #dateTimeFormat(local.order.orderDate, "mmm d YYYY h:n tt")#</div>
						<div class="mb-0"><strong>Total Price:</strong> Rs. #local.order.totalPrice#</div>
						<a class="btn btn-sm btn-success" href="http://shoppingcart.local/download.cfm?orderId=#local.order.orderId#">
							<i class="fa-solid fa-file-arrow-down pe-none"></i>
						</a>
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
										<td rowspan="3" class="text-center align-middle border-top border-bottom border-dark-subtle">
											<img src="#application.productImageDirectory&local.productImage#" class="img-fluid rounded" width="100" alt="Product">
										</td>
										<td class="border-0 border-top border-dark-subtle"><strong>Product:</strong> #local.productName#</td>
										<td class="border-0 border-top border-end border-dark-subtle"><strong>Price:</strong> Rs. #local.unitPrice#</td>
									</tr>
									<tr>
										<td><strong>Brand:</strong> #local.brandName#</td>
										<td class="border-end border-dark-subtle"><strong>Tax:</strong> Rs. #local.unitTax#</td>
									</tr>
									<tr class="border-0 border-bottom border-dark-subtle">
										<td class="border-0"><strong>Quantity:</strong> #local.quantity#</td>
										<td class="border-0 border-end border-dark-subtle"><strong>Total:</strong> Rs. #local.price#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					</div>
					<div class="d-flex flex-md-row flex-column justify-content-between">
						<p>
							<strong>Delivery Address:</strong>
							#local.order.addressLine1#,
							#local.order.addressLine2#,
							#local.order.city#, #local.order.state# - #local.order.pincode#
						</p>
						<p><strong>Contact:</strong> #local.order.firstName# #local.order.lastName# - #local.order.phone#</p>
					</div>
				</div>
			</cfloop>
		</div>
	</div>
</cfoutput>
