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
<cfset variables.order = application.shoppingCart.getOrders(
	orderId = url.orderId
).data[1]>

<!--- Set header and content-type so that pdf gets downloaded correctly --->
<cfheader name="Content-Disposition" value="attachment;filename=invoice.pdf">
<cfcontent type="application/pdf">

<!--- Create pdf --->
<cfdocument format="pdf" overwrite="true">
	<cfoutput>
		<div>
			<div>
				<div><strong>Order ID:</strong> #variables.order.orderId#</div>
				<div><strong>Order Date:</strong> #dateTimeFormat(variables.order.orderDate, "mmm d YYYY h:n tt")#</div>
				<div><strong>Total Price:</strong> Rs. #variables.order.totalPrice#</div>
			</div>
			<div>
				<table>
					<tbody>
						<cfloop list="#variables.order.productNames#" item="variables.item" index="variables.i">
							<cfset variables.unitPrice = listGetAt(variables.order.unitPrices, variables.i)>
							<cfset variables.unitTax = listGetAt(variables.order.unitTaxes, variables.i)>
							<cfset variables.price = variables.unitPrice + variables.unitTax>
							<cfset variables.quantity = listGetAt(variables.order.quantities, variables.i)>
							<cfset variables.productName = listGetAt(variables.order.productNames, variables.i)>
							<cfset variables.brandName = listGetAt(variables.order.brandNames, variables.i)>
							<cfset variables.productImage = listGetAt(variables.order.productImages, variables.i)>

							<tr>
								<td rowspan="3">
									<img src="#application.productImageDirectory&variables.productImage#" class="img-fluid rounded" width="100" alt="Product">
								</td>
								<td><strong>Product:</strong> #variables.productName#</td>
								<td><strong>Price:</strong> Rs. #variables.unitPrice#</td>
							</tr>
							<tr>
								<td><strong>Brand:</strong> #variables.brandName#</td>
								<td><strong>Tax:</strong> Rs. #variables.unitTax#</td>
							</tr>
							<tr>
								<td><strong>Quantity:</strong> #variables.quantity#</td>
								<td><strong>Total:</strong> Rs. #variables.price#</td>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</div>
			<div>
				<p>
					<strong>Delivery Address:</strong>
					#variables.order.addressLine1#,
					#variables.order.addressLine2#,
					#variables.order.city#, #variables.order.state# - #variables.order.pincode#
				</p>
				<p><strong>Contact:</strong> #variables.order.firstName# #variables.order.lastName# - #variables.order.phone#</p>
			</div>
		</div>
	</cfoutput>
</cfdocument>