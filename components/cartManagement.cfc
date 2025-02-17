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
		<cfif arguments.action EQ "increment">

			<!--- Check whether the item is present in cart --->
			<cfif structKeyExists(session.cart, arguments.productId)>
				<!--- Increment quantity of product in session variable --->
				<cfset session.cart[arguments.productId].quantity += 1>

				<!--- Set response message --->
				<cfset local.response["message"] = "Product Quantity Incremented">

			<cfelse>
				<!--- Get Product Into --->
				<cfset local.productInfo = application.dataFetch.getProducts(
					productId = arguments.productId
				)>

				<!--- Add product to session variable --->
				<cfset session.cart[arguments.productId] = {
					"quantity" = 1,
					"unitPrice" = local.productInfo.data[1].price,
					"unitTax" = local.productInfo.data[1].tax
				}>

				<!--- Set response message --->
				<cfset local.response["message"] = "Product Added">

			</cfif>

		<cfelseif arguments.action EQ "decrement" AND session.cart[arguments.productId].quantity GT 1>

			<!--- Decrement quantity of product in session variable --->
			<cfset session.cart[arguments.productId].quantity -= 1>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Quantity Decremented">

		<cfelse>

			<!--- Delete product from session variable --->
			<cfset structDelete(session.cart, arguments.productId)>

			<!--- Set response message --->
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

	<cffunction name="updateCartBatch" access="public" returnType="struct" returnFormat="json">
		<cfargument name="userId" type="integer" required=true>
		<cfargument name="cartData" type="struct" required=false>

		<cfset local.response = {
			success = false,
			message = ""
		}>

		<cftry>
			<cftransaction>
				<!--- Get all products currently in the cart --->
				<cfquery name="local.qryCartProducts">
					SELECT fldProductId FROM tblCart WHERE fldUserId = <cfqueryparam value="#arguments.userId#" cfsqltype="integer">
				</cfquery>

				<!--- Get product Ids from cart table --->
				<cfset local.cartProductIdList = valueList(local.qryCartProducts.fldProductId)>

				<!--- Encrypt product ids from cart --->
				<cfset local.cartProductIdList = listMap(local.cartProductIdList, function(item) {
					return application.commonFunctions.encryptText(item);
				})>

				<!--- Get product Ids from session variable --->
				<cfset local.productIdList = structKeyList(arguments.cartData)>

				<!--- Separate product ids into groups --->
				<cfset local.updatedIdList = listFilter(local.productIdList,function(id){
					return listContainsNoCase(cartProductIdList, id);
				})>
				<cfset local.deleteIdList = listFilter(local.cartProductIdList,function(id){
					return NOT listContainsNoCase(productIdList, id);
				})>
				<cfset local.insertIdList = listFilter(local.productIdList, function(id) {
					return NOT listContainsNoCase(cartProductIdList, id);
				})>

				<!--- Decrypt some ids --->
				<cfset local.updatedIdList = listMap(local.updatedIdList, function(item) {
					return application.commonFunctions.decryptText(item);
				})>
				<cfset local.deleteIdList = listMap(local.deleteIdList, function(item) {
					return application.commonFunctions.decryptText(item);
				})>

				<!--- Insert new products to cart --->
				<cfif listLen(local.insertIdList)>
					<cfquery>
						INSERT INTO
							tblCart (
								fldUserId,
								fldProductId,
								fldQuantity
							)
						VALUES
							<cfloop list="#local.insertIdList#" item="id" index="i">
								(
									<cfqueryparam value="#arguments.userId#" cfsqltype="integer">,
									<cfqueryparam value="#application.commonFunctions.decryptText(id)#" cfsqltype="integer">,
									<cfqueryparam value="#arguments.cartData[id].quantity#" cfsqltype="integer">
								)
								<cfif i NEQ listLen(local.insertIdList)>,</cfif>
							</cfloop>
					</cfquery>
				</cfif>

				<!--- Update products in cart --->
				<cfif listLen(local.updatedIdList)>
					<cfquery>
						UPDATE
							tblCart
						SET
							fldQuantity = CASE fldProductId
								<cfloop list="#local.updatedIdList#" item="id" index="i">
									WHEN <cfqueryparam value="#id#" cfsqltype="integer">
									THEN <cfqueryparam value="#arguments.cartData[application.commonFunctions.encryptText(id)].quantity#" cfsqltype="integer">
								</cfloop>
							END
						WHERE
							fldProductId IN (<cfqueryparam value = "#local.updatedIdList#" cfsqltype = "varchar" list = "yes">)
					</cfquery>
				</cfif>

				<!--- Delete products from cart --->
				<cfquery>
					DELETE FROM
						tblCart
					WHERE
						fldUserId = <cfqueryparam value="#arguments.userId#" cfsqltype="integer">
						AND fldProductId IN (<cfqueryparam value = "#local.deleteIdList#" cfsqltype = "varchar" list = "yes">)
				</cfquery>
			</cftransaction>

			<cfset local.response.success = true>

			<!--- Catch error --->
			<cfcatch>
				<!--- Rollback cart update if some queries fail --->
				<cftransaction action="rollback">
				<cfset local.response.message="Error: #cfcatch.message#">
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

			<!--- Fetch address details --->
			<cfset local.address = application.dataFetch.getAddress(
				addressId = arguments.addressId
			)>

			<!--- Send email to user --->
			<cfmail to="#session.email#" from="no-reply@shoppingcart.local" subject="Your order has been successfully placed">
				Hi #session.firstName# #session.lastName#,

				Your order was placed successfully.

				Delivery Address:
				#local.address.data[1].fullName#,
				#local.address.data[1].addressLine1#,
				#local.address.data[1].addressLine2#,
				#local.address.data[1].city#, #local.address.data[1].state# - #local.address.data[1].pincode#,
				#local.address.data[1].phone#

				Order Id: #local.orderId#
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