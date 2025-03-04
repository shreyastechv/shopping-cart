<!--- Url Params --->
<cfparam name="url.orderId" type="string" default="">

<!--- Order id Validation --->
<cfif (len(url.orderId) EQ 0)
	OR ( NOT reFindNoCase( "([0-9A-Z]{8})+\-([0-9A-Z]{4})+\-([0-9A-Z]{4})+\-([0-9A-Z]{16})", url.orderId )
	OR (len(trim(url.orderId)) NEQ 35) )
>
	<cflocation  url="/" addToken="no">
</cfif>

<!--- Get order details --->
<cfset variables.orders = application.dataFetch.getOrders(
	orderId = url.orderId
).data>

<!--- Get order details only if the returned array is not empty --->
<cfif arrayLen(variables.orders)>
	<cfset variables.order = variables.orders[1]>
<cfelse>
	<cfoutput>
		<div class="d-flex flex-column align-items-center justify-content-center gap-4 fs-4 p-5">
			<img src="#application.imageDirectory#not-found.svg" width="340" alt="Order Not Found Image">
			Order with that order id is not found
			<a href="/orders.cfm" class="btn btn-primary">Go to Order History</a>
		</div>
	</cfoutput>
	<cfabort>
</cfif>

<!--- Set header and content-type so that pdf gets downloaded correctly --->
<cfheader name="Content-Disposition" value="inline;filename=invoice.pdf">
<cfcontent type="application/pdf">

<!--- Create pdf --->
<cfdocument format="pdf">
	<cfoutput>
		<div>
			<div style="font-size: larger; font-weight: 500; margin-bottom: 10px;">
				Order Invoice
			</div>
			<div>
				<div style="margin-bottom: 5px;"><strong>Order ID:</strong> #variables.order.orderId#</div>
				<div style="margin-bottom: 5px;"><strong>Order Date:</strong> #dateTimeFormat(variables.order.orderDate, "mmm d YYYY h:nn tt")#</div>
				<div style="margin-bottom: 5px;"><strong>Total Price:</strong> Rs. #variables.order.totalPrice#</div>
			</div>
			<div>
				<table border="1" cellpadding="4" cellspacing="0">
					<thead>
						<tr>
							<th>Product</th>
							<th>Brand</th>
							<th>Unit Price</th>
							<th>Unit Tax</th>
							<th>Quantity</th>
							<th>Total Price</th>
						</tr>
					</thead>
					<tbody>
						<cfloop array="#variables.order.products#" item="variables.item">
							<cfset variables.price = (variables..item.unitPrice + variables.item.unitTax) * variables.item.quantity>

							<tr>
								<td>#variables.item.productName#</td>
								<td>#variables.item.brandName#</td>
								<td>#variables.item.unitPrice#</td>
								<td>#variables.item.unitTax#</td>
								<td>#variables.item.quantity#</td>
								<td>#variables.price#</td>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</div>
			<div>
				<p>
					<strong>Delivery Address:</strong>
					#variables.order.address.addressLine1#,
					#variables.order.address.addressLine2#,
					#variables.order.address.city#, #variables.order.address.state# - #variables.order.address.pincode#
				</p>
				<p><strong>Contact:</strong> #variables.order.address.firstName# #variables.order.address.lastName# - #variables.order.address.phone#</p>
			</div>
		</div>
	</cfoutput>
</cfdocument>
