<cfcomponent displayname="Cart Management" hint="Includes functions that are used to manage user cart">
	<cffunction name="modifyCart" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">
		<cfargument name="action" type="string" required=true default="">

		<cfset local.response = {
			"message" = "",
			"success" = false,
			"data" = {}
		}>

		<cftry>
			<!--- Decrypt ids--->
			<cfset local.productId = application.commonFunctions.decryptText(arguments.productId)>

			<!--- Product Id Validation --->
			<cfif len(arguments.productId) EQ 0>
				<cfset local.response["message"] &= "Product Id should not be empty. ">
			<cfelseif local.productId EQ -1>
				<!--- Value equals -1 means decryption failed --->
				<cfset local.response["message"] &= "Product Id is invalid. ">
			</cfif>

			<!--- Validate Action --->
			<cfif NOT len(trim(arguments.action))>
				<cfset local.response["message"] &= "Action should not be empty. ">
			<cfelseif NOT arrayContainsNoCase(["increment", "decrement", "delete"], arguments.action)>
				<cfset local.response["message"] &= "Specified action is not valid. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- Continue with code execution if validation succeeds --->
			<cfstoredproc procedure="spModifyCart">
				<cfprocparam type="in" cfsqltype="integer" value="#val(local.productId)#">
				<cfprocparam type="in" cfsqltype="varchar" value="#arguments.action#">
				<cfprocparam type="in" cfsqltype="integer" value="#session.userId#">
				<cfprocparam type="out" cfsqltype="bit" variable="local.success">
				<cfprocparam type="out" cfsqltype="integer" variable="local.newQuantity">
				<cfprocparam type="out" cfsqltype="decimal" variable="local.productActualPrice">
				<cfprocparam type="out" cfsqltype="decimal" variable="local.productTax">
				<cfprocparam type="out" cfsqltype="decimal" variable="local.totalActualPrice">
				<cfprocparam type="out" cfsqltype="decimal" variable="local.totalTax">
			</cfstoredproc>

			<!--- Throw error if the stored procedure errored out --->
			<cfif NOT local.success>
				<cfthrow message = "Error while modifying cart.">
			</cfif>

			<!--- Add data to return struct --->
			<cfset local.response["data"] = {
				"quantity" = local.newQuantity,
				"actualPrice" = local.productActualPrice,
				"tax" = local.productTax,
				"totalActualPrice" = local.totalActualPrice,
				"totalTax" = local.totalTax
			}>

			<!--- Update the session variable --->
			<cfif arguments.action EQ "increment">
				<cfif structKeyExists(session.cart.items, arguments.productId)>
					<cfset local.response["message"] = "Product Quantity Incremented">
				<cfelse>
					<cfset local.response["message"] = "Product Added">
				</cfif>
			<cfelseif arguments.action EQ "decrement">
				<cfset local.response["message"] = "Product Quantity Decremented">
			<cfelse>
				<cfset local.response["message"] = "Product Deleted">
			</cfif>

			<cfset local.response.success = true>

			<cfcatch type="any">
				<cfset local.response.message = "Error while modifying cart!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="validateCard" access="remote" returnType="struct" returnformat="json">
		<cfargument name="cardNumber" type="string" required=true>
		<cfargument name="cvv" type="string" required=true>

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>
		<cfset local.validCardNumber = "1111111111111111">
		<cfset local.validCvv = "111">

		<cftry>
			<!--- Trim and remove dashes from card number --->
			<cfset arguments.cardNumber = replace(trim(arguments.cardNumber), "-", "", "all")>

			<!--- Validate card number --->
			<cfif NOT len(arguments.cardNumber)>
				<cfset local.response["message"] &= "Card number is required. ">
			<cfelseif (len(arguments.cardNumber) NEQ 16) OR (NOT isValid("numeric", arguments.cardNumber))>
				<cfset local.response["message"] &= "Not a valid card number. ">
			</cfif>

			<!--- Validate CVV --->
			<cfif NOT len(trim(arguments.cvv))>
				<cfset local.response["message"] &= "CVV number is required. ">
			<cfelseif (len(trim(arguments.cvv)) NEQ 3) OR (NOT isValid("numeric", arguments.cvv))>
				<cfset local.response["message"] &= "CVV is not valid. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<cfif (arguments.cardNumber EQ local.validCardNumber) AND (arguments.cvv EQ local.validcvv)>
				<cfset local.response["message"] = "Validation successful">
				<cfset local.response["success"] = true>
			<cfelse>
				<cfset local.response["message"] = "Wrong Card number or CVV">
			</cfif>

			<cfcatch type="any">
				<cfset local.response.message = "Error while validating card!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="modifyCheckout" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">
		<cfargument name="action" type="string" required=true default="">

		<cfset local.response = {
			"success" = false,
			"message" = "",
			"data" = {}
		}>

		<cftry>
			<!--- Decrypt ids--->
			<cfset local.productId = application.commonFunctions.decryptText(arguments.productId)>

			<!--- Product Id Validation --->
			<cfif len(arguments.productId) EQ 0>
				<cfset local.response["message"] &= "Product Id should not be empty. ">
			<cfelseif local.productId EQ -1>
				<!--- Value equals -1 means decryption failed --->
				<cfset local.response["message"] &= "Product Id is invalid. ">
			</cfif>

			<!--- Validate Action --->
			<cfif NOT len(trim(arguments.action))>
				<cfset local.response["message"] &= "Action should not be empty. ">
			<cfelseif NOT arrayContainsNoCase(["increment", "decrement", "delete"], arguments.action)>
				<cfset local.response["message"] &= "Specified action is not valid. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- Continue with code execution if validation succeeds --->
			<cfif arguments.action EQ "increment">
				<cfset session.checkout.items[arguments.productId].quantity += 1>
				<cfset session.checkout.totalPrice += session.checkout.items[arguments.productId].unitPrice>
				<cfset session.checkout.totalTax += session.checkout.items[arguments.productId].unitPrice * session.checkout.items[arguments.productId].unitTax / 100>
				<cfset local.response["message"] = "Product Quantity Incremented">
			<cfelseif arguments.action EQ "decrement" AND session.checkout.items[arguments.productId].quantity GT 1>
				<cfset session.checkout.items[arguments.productId].quantity -= 1>
				<cfset session.checkout.totalPrice -= session.checkout.items[arguments.productId].unitPrice>
				<cfset session.checkout.totalTax -= session.checkout.items[arguments.productId].unitPrice * session.checkout.items[arguments.productId].unitTax / 100>
				<cfset local.response["message"] = "Product Quantity Decremented">
			<cfelse>
				<cfset session.checkout.totalPrice -= session.checkout.items[arguments.productId].unitPrice * session.checkout.items[arguments.productId].quantity>
				<cfset session.checkout.totalTax -= session.checkout.items[arguments.productId].unitPrice * session.checkout.items[arguments.productId].quantity * session.checkout.items[arguments.productId].unitTax / 100>
				<cfset structDelete(session.checkout.items, arguments.productId)>
				<cfset local.response["message"] = "Product Deleted">

			</cfif>

			<!--- Do the math --->
			<cfif structKeyExists(session.checkout.items, arguments.productId)>
				<cfset local.unitPrice = session.checkout.items[arguments.productId].unitPrice>
				<cfset local.unitTax = session.checkout.items[arguments.productId].unitTax>
				<cfset local.quantity = session.checkout.items[arguments.productId].quantity>
				<cfset local.actualPrice = local.unitPrice * local.quantity>
				<cfset local.price = local.actualPrice + (local.unitPrice * (local.unitTax / 100) * local.quantity)>

				<!--- Package data into struct --->
				<cfset local.response["data"] = {
					"price" = local.price,
					"actualPrice" = local.actualPrice,
					"quantity" = session.checkout.items[arguments.productId].quantity
				}>
			</cfif>

			<!--- Append total price and tax to data struct --->
			<cfset structAppend(local.response["data"], {
				"totalActualPrice" = session.checkout.totalPrice,
				"totalTax" = session.checkout.totalTax,
				"totalPrice" = session.checkout.totalPrice + session.checkout.totalTax
			})>

			<cfset local.response["success"] = true>

			<cfcatch type="any">
				<cfset local.response.message = "Error while modifying checkout!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="createOrder" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="addressId" type="string" required=true default="">

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>

		<cftry>
			<!--- Decrypt ids--->
			<cfset local.addressId = application.commonFunctions.decryptText(arguments.addressId)>

			<!--- Check whether session variable is empty or not --->
			<cfif (NOT structKeyExists(session, "checkout")) OR (structCount(session.checkout.items) EQ 0)>
				<cfset local.response["message"] = "No product in checkout!">
				<cfreturn local.response>
			</cfif>

			<!--- Address Id Validation --->
			<cfif NOT len(trim(arguments.addressId))>
				<cfset local.response["message"] = "Address Id is required.">
			<cfelseif local.addressId EQ -1>
				<!--- Value equals -1 means decryption failed --->
				<cfset local.response["message"] = "Address Id is invalid.">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- json array to pass to stored procedure --->
			<cfset local.productList = []>

			<!--- Loop through checkout items --->
			<cfloop collection="#session.checkout.items#" item="item">
				<!--- build json array --->
				<cfset arrayAppend(local.productList, {
					"productId": application.commonFunctions.decryptText(trim(item)),
					"quantity": val(session.checkout.items[item].quantity)
				})>
			</cfloop>

			<!--- Convert array to JSON --->
			<cfset local.productJSON = serializeJSON(local.productList)>

			<cfstoredproc procedure="spCreateOrderItems">
				<cfprocparam type="in" cfsqltype="integer" value="#session.userId#">
				<cfprocparam type="in" cfsqltype="integer" value="#val(local.addressId)#">
				<cfprocparam type="in" cfsqltype="longvarchar" value="#local.productJSON#">
				<cfprocparam type="out" cfsqltype="varchar" variable="local.orderId">
				<cfprocparam type="out" cfsqltype="bit" variable="local.success">
			</cfstoredproc>

			<!--- Throw error if the stored procedure errored out --->
			<cfif NOT local.success>
				<cfthrow message = "Creating order was unsuccessful.">
			</cfif>

			<!--- Empty cart structure in session --->
			<cfset structEach(session.checkout.items, function(key) {
				structDelete(session.cart.items, key);
			})>

			<!--- Fetch order details --->
			<cfset local.orders = application.dataFetch.getOrders(orderId = local.orderId)>
			<cfset local.order = arrayLen(local.orders.data) ? local.orders.data[1] : []>

			<!--- Send email to user --->
			<cfmail to="#session.email#" from="no-reply@shoppingcart.local" subject="Your order has been successfully placed">
				Hi #session.firstName# #session.lastName#,

				Your order was placed successfully.

				Product Details:
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
						<cfloop array="#local.order.products#" item="item">
							<cfset local.price = (item.unitPrice + item.unitTax) * item.quantity>

							<tr>
								<td>#item.productName#</td>
								<td>#item.brandName#</td>
								<td>#item.unitPrice#</td>
								<td>#item.unitTax#</td>
								<td>#item.quantity#</td>
								<td>#local.price#</td>
							</tr>
						</cfloop>
					</tbody>
				</table>

				Delivery Address:
				#local.order.address.firstName# #local.order.address.lastName#,
				#local.order.address.addressLine1#,
				#local.order.address.addressLine2#,
				#local.order.address.city#, #local.order.address.state# - #local.order.address.pincode#,
				#local.order.address.phone#

				Order Id: #local.order.orderId#
				Order Date: #local.order.orderDate#
				Total Price: #local.order.totalPrice#
			</cfmail>

			<!--- Clear session variable --->
			<cfset structDelete(session, "checkout")>

			<!--- Set success status --->
			<cfset local.response["success"] = true>

			<cfcatch type="any">
				<cfset local.response.message = "Error while processing order">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>
</cfcomponent>
