<!--- Variables --->
<cfparam name="url.orderSearch" default="">
<cfparam name="url.pageNumber" default=1>
<cfset variables.pageSize = 4>

<!--- Validate page number --->
<cfif NOT isValid("integer", url.pageNumber) OR url.pageNumber LT 1>
	<cfset url.pageNumber EQ 1>
</cfif>

<!--- Get Data --->
<cfset variables.orders = application.dataFetch.getOrders(
	searchTerm = url.orderSearch,
	pageNumber = url.pageNumber,
	pageSize = variables.pageSize
)>

<cfoutput>
	<div class="container py-4">
		<div class="d-flex justify-content-center">
			<a class="h2 text-decoration-none m-4" href="/orders.cfm">Your Orders</a>
		</div>
		<div class="row my-2">
			<!--- Order search bar --->
			<div class="col-md-8 ">
				<form method="get" class="d-flex gap-2">
					<input type="text" name="orderSearch" class="form-control shadow" value="#url.orderSearch#"
						placeholder="Search orders using order id, product name, brand ..."
						oninput="this.value = this.value.trim();"
					>
					<button class="btn btn-primary shadow" type="submit">
						<i class="pe-none fa-solid fa-magnifying-glass"></i>
					</button>
				</form>
			</div>

			<!--- Pagination --->
			<nav aria-label="Order Page Navigation" class="col-md-4">
				<ul class="pagination justify-content-end">
					<li class="page-item #(url.pageNumber EQ 1 ? "disabled" : "")#">
						<a href="javascript:void(0)" onclick="goToPage(#url.pageNumber - 1#)" class="page-link">Previous</a>
					</li>
					<cfset variables.start = url.pageNumber GT 1 ? url.pageNumber - 1 : url.pageNumber>
					<cfset variables.end = variables.orders.hasMoreRows ? url.pageNumber + 1 : url.pageNumber>
					<cfloop index="i" from="#variables.start#" to="#variables.end#">
						<li class="page-item #(url.pageNumber EQ i ? "active" : "")#"><a class="page-link" href="javascript:void(0)" onclick="goToPage(#i#)">#i#</a></li>
					</cfloop>
					<li class="page-item">
						<a class="page-link #(variables.orders.hasMoreRows ? "" : "disabled")#" href="javascript:void(0)" onclick="goToPage(#url.pageNumber + 1#)">Next</a>
					</li>
				</ul>
			</nav>
		</div>

		<div id="ordersContainer">
			<cfif len(trim(url.orderSearch))>
				<div class="fs-5 mb-2">
					Showing results for <span class="fw-semibold">'#url.orderSearch#'</span>
				</div>
			</cfif>

			<!--- Show message if order list in empty --->
			<cfif NOT arrayLen(variables.orders.data)>
				<div class="d-flex flex-column align-items-center justify-content-center">
					<img src="#application.imageDirectory#empty-cart.svg" width="300" alt="Empty Order List">
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
						<a class="btn btn-sm btn-success" target="_blank" href="/download.cfm?orderId=#urlEncodedFormat(variables.order.orderId)#">
							<i class="fa-solid fa-file-arrow-down pe-none"></i>
						</a>
					</div>
					<div class="table-responsive">
						<table class="table table-striped table-bordered">
							<tbody>
								<cfloop array="#variables.order.products#" item="variables.item">
									<cfset variables.price = (variables.item.unitPrice + variables.item.unitTax) * variables.item.quantity>

									<tr>
										<td rowspan="3" class="text-center align-middle border-top border-bottom border-dark-subtle">
											<a href="/productPage.cfm?productId=#urlEncodedFormat(variables.item.productId)#">
												<img src="#application.productImageDirectory&variables.item.productImage#" class="img-fluid rounded" width="100" alt="Product">
											</a>
										</td>
										<td class="border-0 border-top border-dark-subtle"><strong>Product:</strong> #variables.item.productName#</td>
										<td class="border-0 border-top border-end border-dark-subtle"><strong>Price:</strong> Rs. #variables.item.unitPrice#</td>
									</tr>
									<tr>
										<td><strong>Brand:</strong> #variables.item.brandName#</td>
										<td class="border-end border-dark-subtle"><strong>Tax:</strong> Rs. #variables.item.unitTax#</td>
									</tr>
									<tr class="border-0 border-bottom border-dark-subtle">
										<td class="border-0"><strong>Quantity:</strong> #variables.item.quantity#</td>
										<td class="border-0 border-end border-dark-subtle"><strong>Total:</strong> Rs. #variables.price#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					</div>
					<div class="d-flex flex-md-row flex-column justify-content-between">
						<div>
							<strong>Delivery Address:</strong>
							#variables.order.address.addressLine1#,
							#variables.order.address.addressLine2#,
							#variables.order.address.city#, #variables.order.address.state# - #variables.order.address.pincode#
						</div>
						<div><strong>Contact:</strong> #variables.order.address.firstName# #variables.order.address.lastName# - #variables.order.address.phone#</div>
					</div>
				</div>
			</cfloop>
		</div>
	</div>
</cfoutput>
