<cfcomponent displayname="Cart Management" hint="Includes functions that are used to manage user cart">
	<cffunction name="modifyCart" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">
		<cfargument name="action" type="string" required=true default="">

		<cfset local.response = {
			"message" = "",
			"success" = false,
			"data" = {}
		}>

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
			<cfprocparam type="in" cfsqltype="integer" variable="productId" value="#val(local.productId)#">
			<cfprocparam type="in" cfsqltype="varchar" variable="action" value="#arguments.action#">
			<cfprocparam type="in" cfsqltype="integer" variable="userId" value="#session.userId#">
		</cfstoredproc>

		<!--- Update the session variable --->
		<cfif arguments.action EQ "increment">
			<cfif structKeyExists(session.cart, arguments.productId)>
				<cfset session.cart[arguments.productId].quantity += 1>
				<cfset local.response["message"] = "Product Quantity Incremented">
			<cfelse>
				<cfset session.cart[arguments.productId] = application.dataFetch.getCart(
					productId = local.productId
				)[arguments.productId]>
				<cfset local.response["message"] = "Product Added">

			</cfif>
		<cfelseif arguments.action EQ "decrement" AND session.cart[arguments.productId].quantity GT 1>
			<cfset session.cart[arguments.productId].quantity -= 1>
			<cfset local.response["message"] = "Product Quantity Decremented">
		<cfelse>
			<cfset structDelete(session.cart, arguments.productId)>
			<cfset local.response["message"] = "Product Deleted">
		</cfif>

		<!--- Do the math --->
		<cfif structKeyExists(session.cart, arguments.productId)>
			<cfset local.unitPrice = session.cart[arguments.productId].unitPrice>
			<cfset local.unitTax = session.cart[arguments.productId].unitTax>
			<cfset local.quantity = session.cart[arguments.productId].quantity>
			<cfset local.actualPrice = local.unitPrice * local.quantity>
			<cfset local.price = local.actualPrice + (local.unitPrice * (local.unitTax / 100) * local.quantity)>

			<!--- Package data into struct --->
			<cfset local.response["data"] = {
				"price" = local.price,
				"actualPrice" = local.actualPrice,
				"quantity" = session.cart[arguments.productId].quantity
			}>
		</cfif>

		<!--- Do the math on total price and tax in cart --->
		<cfset local.priceDetails = session.cart.reduce(function(result,key,value){
			result.totalActualPrice += value.unitPrice * value.quantity;
			result.totalPrice += value.unitPrice * ( 1 + (value.unitTax/100)) * value.quantity;
			result.totalTax += value.unitPrice * value.unitTax / 100 * value.quantity;
			return result;
		},{totalActualPrice = 0, totalPrice = 0, totalTax = 0})>
		<cfset local.totalPrice = local.priceDetails.totalPrice>
		<cfset local.totalActualPrice = local.priceDetails.totalActualPrice>
		<cfset local.totalTax = local.priceDetails.totalTax>

		<!--- Append total price and tax to data struct --->
		<cfset structAppend(local.response["data"], {
			"totalPrice" = local.totalPrice,
			"totalActualPrice" = local.totalActualPrice,
			"totalTax" = local.totalTax
		})>

		<cfset local.response["success"] = true>

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

			<!--- Delete productId key from struct in session variable --->
			<cfset session.checkout[arguments.productId].quantity += 1>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Quantity Incremented">

		<cfelseif arguments.action EQ "decrement" AND session.checkout[arguments.productId].quantity GT 1>

			<!--- Delete productId key from struct in session variable --->
			<cfset session.checkout[arguments.productId].quantity -= 1>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Quantity Decremented">

		<cfelse>

			<!--- Delete productId key from struct in session variable --->
			<cfset structDelete(session.checkout, arguments.productId)>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Deleted">

		</cfif>

		<!--- Do the math --->
		<cfif structKeyExists(session.checkout, arguments.productId)>
			<cfset local.unitPrice = session.checkout[arguments.productId].unitPrice>
			<cfset local.unitTax = session.checkout[arguments.productId].unitTax>
			<cfset local.quantity = session.checkout[arguments.productId].quantity>
			<cfset local.actualPrice = local.unitPrice * local.quantity>
			<cfset local.price = local.actualPrice + (local.unitPrice * (local.unitTax / 100) * local.quantity)>

			<!--- Package data into struct --->
			<cfset local.response["data"] = {
				"price" = local.price,
				"actualPrice" = local.actualPrice,
				"quantity" = session.checkout[arguments.productId].quantity
			}>
		</cfif>

		<!--- Do the math on total price and tax --->
		<cfset local.priceDetails = session.checkout.reduce(function(result,key,value){
			result.totalActualPrice += value.unitPrice * value.quantity;
			result.totalPrice += value.unitPrice * ( 1 + (value.unitTax/100)) * value.quantity;
			result.totalTax += value.unitPrice * value.unitTax / 100 * value.quantity;
			return result;
		},{totalActualPrice = 0, totalPrice = 0, totalTax = 0})>
		<cfset local.totalPrice = local.priceDetails.totalPrice>
		<cfset local.totalActualPrice = local.priceDetails.totalActualPrice>
		<cfset local.totalTax = local.priceDetails.totalTax>

		<!--- Append total price and tax data into struct --->
		<cfset structAppend(local.response["data"], {
			"totalPrice" = local.totalPrice,
			"totalActualPrice" = local.totalActualPrice,
			"totalTax" = local.totalTax
		})>

		<cfset local.response["success"] = true>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="orderIdIsUnique" access="private" returnType="boolean">
		<cfargument name="orderId" type="string" required=true>
		<cfset local.result = false>

		<cfquery name="local.qryCheckOrderId">
			SELECT
				fldOrder_Id
			FROM
				tblOrder
			WHERE
				fldOrder_Id  = <cfqueryparam value = "#trim(arguments.orderId)#" cfsqltype = "varchar">
		</cfquery>

		<cfset local.result = (local.qryCheckOrderId.recordCount EQ 0)>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="createOrder" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="addressId" type="string" required=true default="">

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.addressId = application.commonFunctions.decryptText(arguments.addressId)>

		<!--- Check whether user is logged in --->
		<cfif NOT structKeyExists(session, "userId")>
			<cfset local.response["message"] &= "User not logged in. ">
		</cfif>

		<!--- Check whether session variable is empty or not --->
		<cfif (NOT structKeyExists(session, "checkout")) OR (structCount(session.checkout) EQ 0)>
			<cfset local.response["message"] &= "Checkout section is empty. ">
		</cfif>

		<!--- Address Id Validation --->
		<cfif NOT len(trim(arguments.addressId))>
			<cfset local.response["message"] &= "Address Id is required. ">
		<cfelseif local.addressId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] = "Address Id is invalid.">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Create Order Id --->
		<cfset local.orderId = createUUID()>
		<cfloop condition="NOT orderIdIsUnique(orderId = local.orderId)">
			<cfset local.orderId = createUUID()>
		</cfloop>

		<!--- Variables to store total price and total tax --->
		<cfset local.totalPrice = 0>
		<cfset local.totalTax = 0>

		<!--- json array to pass to stored procedure --->
		<cfset local.productList = []>

		<!--- Loop through checkout items --->
		<cfloop collection="#session.checkout#" item="item">
			<!--- Calculate total price and tax --->
			<cfset local.totalPrice += session.checkout[item].unitPrice * ( 1 + (session.checkout[item].unitTax / 100)) * session.checkout[item].quantity>
			<cfset local.totalTax += session.checkout[item].unitPrice * (session.checkout[item].unitTax / 100) * session.checkout[item].quantity>

			<!--- build json array --->
			<cfset arrayAppend(local.productList, {
				"productId": application.commonFunctions.decryptText(trim(item)),
				"quantity": trim(session.checkout[item].quantity)
			})>
		</cfloop>

		<!--- Convert array to JSON --->
		<cfset local.productJSON = serializeJSON(local.productList)>

		<cftry>
			<cfstoredproc procedure="spCreateOrderItems">
				<cfprocparam type="in" cfsqltype="varchar" variable="p_orderId" value="#local.orderId#">
				<cfprocparam type="in" cfsqltype="integer" variable="p_userId" value="#session.userId#">
				<cfprocparam type="in" cfsqltype="integer" variable="p_addressId" value="#val(local.addressId)#">
				<cfprocparam type="in" cfsqltype="decimal" variable="p_totalPrice" value="#local.totalPrice#">
				<cfprocparam type="in" cfsqltype="decimal" variable="p_totalTax" value="#local.totalTax#">
				<cfprocparam type="in" cfsqltype="longvarchar" variable="p_jsonProducts" value="#local.productJSON#">
			</cfstoredproc>

			<!--- Empty cart structure in session --->
			<cfset structEach(session.checkout, function(key) {
				structDelete(session.cart, key);
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
						<cfloop list="#local.order.productIds#" item="item" index="i">
							<cfset local.unitPrice = listGetAt(local.order.unitPrices, i)>
							<cfset local.unitTax = listGetAt(local.order.unitTaxes, i)>
							<cfset local.quantity = listGetAt(local.order.quantities, i)>
							<cfset local.price = (local.unitPrice + local.unitTax) * local.quantity>
							<cfset local.productName = listGetAt(local.order.productNames, i)>
							<cfset local.brandName = listGetAt(local.order.brandNames, i)>

							<tr>
								<td>#local.productName#</td>
								<td>#local.brandName#</td>
								<td>#local.unitPrice#</td>
								<td>#local.unitTax#</td>
								<td>#local.quantity#</td>
								<td>#local.price#</td>
							</tr>
						</cfloop>
					</tbody>
				</table>

				Delivery Address:
				#local.order.firstName# #local.order.lastName#,
				#local.order.addressLine1#,
				#local.order.addressLine2#,
				#local.order.city#, #local.order.state# - #local.order.pincode#,
				#local.order.phone#

				Order Id: #local.order.orderId#
				Order Date: #local.order.orderDate#
				Total Price: #local.order.totalPrice#
			</cfmail>

			<!--- Clear session variable --->
			<cfset structDelete(session, "checkout")>

			<!--- Set success status --->
			<cfset local.response["success"] = true>

			<cfcatch type="any">
				<cfset local.response["success"] = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>
</cfcomponent>