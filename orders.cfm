<!--- Variables --->
<cfparam name="url.s" default="">
<cfparam name="url.pageNumber" default=1>
<cfset variables.pageSize = 4>

<!--- Validate page number --->
<cfif NOT isValid("integer", url.pageNumber) OR url.pageNumber LT 1>
	<cfset url.pageNumber EQ 1>
</cfif>

<!--- Get Data --->
<cfset variables.orders = application.shoppingCart.getOrders(
	searchTerm = url.s,
	pageNumber = url.pageNumber,
	pageSize = variables.pageSize
)>

<cfoutput>
	<div class="container py-4">
		<h2 class="text-center mb-4">Your Orders</h2>
		<form method="get" class="d-flex gap-2 mb-5">
			<input type="text" name="s" class="form-control shadow" value="#url.s#"
				placeholder="Search orders using order id..."
				oninput="this.value = this.value.trim();"
			>
			<button class="btn btn-primary shadow" type="submit">
				<i class="pe-none fa-solid fa-magnifying-glass"></i>
			</button>
		</form>

		<div id="ordersContainer">
			<!--- Show message if order list in empty --->
			<cfif NOT arrayLen(variables.orders.data)>
				<div class="d-flex flex-column align-items-center justify-content-center">
					<img src="#application.imageDirectory#empty-cart.svg" width="300" alt="Shopping Cart Empty">
					<div class="fs-5 mb-3">Order List is Empty</div>
				</div>
			</cfif>

			<!--- Show orders data if there are previous orders --->
			<cfloop array="#variables.orders.data#" item="variables.order">
				<div class="card order-card shadow p-3 mb-4" data-order-id="#variables.order.orderId#">
					<div class="d-flex flex-lg-row flex-column align-items-center justify-content-between mb-2">
						<div class="mb-0"><strong>Order ID:</strong> #variables.order.orderId#</div>
						<div class="mb-0"><strong>Order Date:</strong> #dateTimeFormat(variables.order.orderDate, "mmm d YYYY h:nn tt")#</div>
						<div class="mb-0"><strong>Total Price:</strong> Rs. #variables.order.totalPrice#</div>
						<a class="btn btn-sm btn-success" target="_blank" href="/download.cfm?orderId=#variables.order.orderId#">
							<i class="fa-solid fa-file-arrow-down pe-none"></i>
						</a>
					</div>
					<div class="table-responsive">
						<table class="table table-striped table-bordered">
							<tbody>
								<cfloop list="#variables.order.productNames#" item="variables.item" index="variables.i">
									<cfset variables.productId = listGetAt(variables.order.productIds, variables.i)>
									<cfset variables.encodedProductId = urlEncodedFormat(variables.productId)>
									<cfset variables.unitPrice = listGetAt(variables.order.unitPrices, variables.i)>
									<cfset variables.unitTax = listGetAt(variables.order.unitTaxes, variables.i)>
									<cfset variables.price = variables.unitPrice + variables.unitTax>
									<cfset variables.quantity = listGetAt(variables.order.quantities, variables.i)>
									<cfset variables.productName = listGetAt(variables.order.productNames, variables.i)>
									<cfset variables.brandName = listGetAt(variables.order.brandNames, variables.i)>
									<cfset variables.productImage = listGetAt(variables.order.productImages, variables.i)>

									<tr>
										<td rowspan="3" class="text-center align-middle border-top border-bottom border-dark-subtle">
											<a href="/productPage.cfm?productId=#variables.encodedProductId#">
												<img src="#application.productImageDirectory&variables.productImage#" class="img-fluid rounded" width="100" alt="Product">
											</a>
										</td>
										<td class="border-0 border-top border-dark-subtle"><strong>Product:</strong> #variables.productName#</td>
										<td class="border-0 border-top border-end border-dark-subtle"><strong>Price:</strong> Rs. #variables.unitPrice#</td>
									</tr>
									<tr>
										<td><strong>Brand:</strong> #variables.brandName#</td>
										<td class="border-end border-dark-subtle"><strong>Tax:</strong> Rs. #variables.unitTax#</td>
									</tr>
									<tr class="border-0 border-bottom border-dark-subtle">
										<td class="border-0"><strong>Quantity:</strong> #variables.quantity#</td>
										<td class="border-0 border-end border-dark-subtle"><strong>Total:</strong> Rs. #variables.price#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					</div>
					<div class="d-flex flex-md-row flex-column justify-content-between">
						<div>
							<strong>Delivery Address:</strong>
							#variables.order.addressLine1#,
							#variables.order.addressLine2#,
							#variables.order.city#, #variables.order.state# - #variables.order.pincode#
						</div>
						<div><strong>Contact:</strong> #variables.order.firstName# #variables.order.lastName# - #variables.order.phone#</div>
					</div>
				</div>
			</cfloop>
		</div>

		<nav aria-label="Order Page Navigation" class="pt-3">
			<ul class="pagination justify-content-center">
				<li class="page-item #(url.pageNumber EQ 1 ? "disabled" : "")#">
					<a href="javascript:void(0)" onclick="goToPage(#url.pageNumber - 1#)" class="page-link">Previous</a>
				</li>
				<cfset variables.start = url.pageNumber GTE 2 ? url.pageNumber - 1 : url.pageNumber>
				<cfset variables.end = arrayLen(variables.orders.data) LT variables.pageSize ? url.pageNumber : url.pageNumber + 1>
				<cfloop index="i" from="#variables.start#" to="#variables.end#">
					<li class="page-item #(url.pageNumber EQ i ? "active" : "")#"><a class="page-link" href="javascript:void(0)" onclick="goToPage(#i#)">#i#</a></li>
				</cfloop>
				<li class="page-item">
					<a class="page-link #(arrayLen(variables.orders.data) LT variables.pageSize ? "disabled" : "")#" href="javascript:void(0)" onclick="goToPage(#url.pageNumber + 1#)">Next</a>
				</li>
			</ul>
		</nav>
	</div>
</cfoutput>
