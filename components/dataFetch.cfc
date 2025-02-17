<cfcomponent displayname="Data Fetching" hint="Includes functions that help in fetching data from db">
	<cffunction name="getCategories" access="public" returnType="struct">
		<!--- Create response struct --->
		<cfset local.response = {
			"data" = []
		}>

		<cfquery name="local.qryGetCategories">
			SELECT DISTINCT
				C.fldCategory_Id,
				C.fldCategoryName
			FROM
				tblCategory C
			LEFT JOIN
				tblSubCategory SC ON SC.fldCategoryId = C.fldCategory_Id
				AND SC.fldActive = 1
			WHERE
				C.fldActive = 1
				<cfif NOT structKeyExists(session, "roleId") OR session.roleId EQ 2>
					AND SC.fldCategoryId IS NOT NULL
				</cfif>
		</cfquery>

		<!--- Fill up the array with category information --->
		<cfloop query="local.qryGetCategories">
			<cfset local.categoryStruct = {
				"categoryId": application.commonFunctions.encryptText(local.qryGetCategories.fldCategory_Id),
				"categoryName": local.qryGetCategories.fldCategoryName
			}>

			<cfset arrayAppend(local.response.data, local.categoryStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getSubCategories" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="categoryId" type="string" required=false default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
		}>

		<!--- Decrypt ids--->
		<cfset local.categoryId = application.commonFunctions.decryptText(arguments.categoryId)>

		<!--- Category Id Validation --->
		<cfif len(trim(arguments.categoryId)) AND (local.categoryId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Category Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetSubCategories">
			SELECT
				SC.fldSubCategory_Id,
				SC.fldSubCategoryName,
				SC.fldCategoryId,
				C.fldCategoryName
			FROM
				tblSubCategory SC
				INNER JOIN tblCategory C ON C.fldCategory_Id = SC.fldCategoryId
			WHERE
				SC.fldActive = 1
				<cfif local.categoryId NEQ -1>
					AND SC.fldCategoryId = <cfqueryparam value = "#val(local.categoryId)#" cfsqltype = "integer">
				</cfif>
		</cfquery>

		<!--- Fill up the array with sub category information --->
		<cfloop query="local.qryGetSubCategories">
			<cfset local.subCategoryStruct = {
				"subCategoryId": application.commonFunctions.encryptText(local.qryGetSubCategories.fldSubCategory_Id),
				"subCategoryName": local.qryGetSubCategories.fldSubCategoryName,
				"categoryId": application.commonFunctions.encryptText(local.qryGetSubCategories.fldCategoryId),
				"categoryName": local.qryGetSubCategories.fldCategoryName
			}>

			<cfset arrayAppend(local.response.data, local.subCategoryStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getProducts" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="subCategoryId" type="string" required=false default="">
		<cfargument name="productId" type="string" required=false default="">
		<cfargument name="productIdList" type="string" required=false default="">
		<cfargument name="random" type="integer" required=false default="0">
		<cfargument name="limit" type="integer" required="false" default=6>
		<cfargument name="offset" type="integer" required="false" default=0>
		<cfargument name="sort" type="string" required="false" default="">
		<cfargument name="min" type="float" required="false" default=0>
		<cfargument name="max" type="float" required="false" default=0>
		<cfargument name="searchTerm" type="string" required="false" default="">

		<cfset local.response = {
			"message" = "",
			"data" = [],
			"hasMoreRows" = false
		}>

		<!--- Decrypt ids--->
		<cfset local.subCategoryId = application.commonFunctions.decryptText(arguments.subCategoryId)>
		<cfset local.productId = application.commonFunctions.decryptText(arguments.productId)>
		<cfset local.productIdList = listMap(arguments.productIdList, function(item) {
			return application.commonFunctions.decryptText(item);
		})>

		<!--- Sub Category Id Validation --->
		<cfif len(trim(arguments.subCategoryId)) AND (local.subCategoryId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Sub Category Id is invalid. ">
		</cfif>

		<!--- Product Id Validation --->
		<cfif len(trim(arguments.productId)) AND (local.productId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Product Id is invalid. ">
		</cfif>

		<!--- Orderby Validation --->
		<cfif NOT arrayContainsNoCase(["asc",  "desc", ""], arguments.sort)>
			<cfset local.response["message"] &= "Sort value should either be asc or desc">
		</cfif>

		<!--- Min Max Validation --->
		<cfif len(trim(arguments.max)) AND (arguments.max LT arguments.min)>
			<cfset local.response["message"] &= "Max should be greater than or equal to Min">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetProducts">
			SELECT
				P.fldProduct_Id,
				P.fldProductName,
				P.fldBrandId,
				P.fldDescription,
				P.fldPrice,
				P.fldTax,
				B.fldBrandName,
				PI.fldImageFileName AS fldProductImage,
				C.fldCategory_Id,
				SC.fldSubCategoryName
			FROM
				tblProduct P
				INNER JOIN tblBrands B ON P.fldBrandId = B.fldBrand_Id
				INNER JOIN tblSubCategory SC ON P.fldSubCategoryId = SC.fldSubCategory_Id
				INNER JOIN tblCategory C ON SC.fldCategoryId = C.fldCategory_Id
				INNER JOIN tblProductImages PI ON P.fldProduct_Id = PI.fldProductId
					AND PI.fldActive = 1
					AND PI.fldDefaultImage = 1
			WHERE
				P.fldActive = 1
				<cfif local.subCategoryId NEQ -1>
					AND P.fldSubCategoryId = <cfqueryparam value = "#val(local.subCategoryId)#" cfsqltype = "integer">
				<cfelseif local.productId NEQ -1>
					AND P.fldProduct_Id = <cfqueryparam value = "#val(local.productId)#" cfsqltype = "integer">
				<cfelseif len(trim(arguments.productIdList))>
					AND P.fldProduct_Id IN (<cfqueryparam value = "#local.productIdList#" cfsqltype = "varchar" list = "yes">)
				</cfif>

				<!--- 0 is the default value of arguments.max hence it should not be used --->
				<cfif val(arguments.max) NEQ 0>
					AND P.fldPrice BETWEEN <cfqueryparam value = "#arguments.min#" cfsqltype = "integer">
						AND <cfqueryparam value = "#arguments.max#" cfsqltype = "integer">
				</cfif>

				<cfif len(trim(arguments.searchTerm))>
					AND (P.fldProductName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
						OR P.fldDescription LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
						OR C.fldCategoryName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
						OR SC.fldSubCategoryName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
						OR B.fldBrandName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">)
				</cfif>

				<!--- Sorting --->
				<cfif arguments.random EQ 1>
					ORDER BY
						RAND()
				<cfelseif len(trim(arguments.sort))>
					ORDER BY
						P.fldPrice #arguments.sort#
				</cfif>

				<!--- Limit the number of products returned --->
				<cfif len(trim(arguments.limit))>
					<!--- Querying one extra product to check whether there are more products --->
					LIMIT <cfqueryparam value = "#arguments.limit + 1#" cfsqltype = "integer">
					<cfif len(trim(arguments.offset))>
						OFFSET <cfqueryparam value = "#arguments.offset#" cfsqltype = "integer">
					</cfif>
				</cfif>
		</cfquery>

		<!--- Check whether there are more products --->
		<cfif local.qryGetProducts.recordCount GT arguments.limit>
			<cfset local.response.hasMoreRows = true>

			<!--- Remove the extra row --->
			<cfset local.qryGetProducts = queryDeleteRow(local.qryGetProducts, local.qryGetProducts.recordCount)>
		</cfif>

		<!--- Loop through the query results and populate the array --->
		<cfloop query="local.qryGetProducts">
			<cfset local.productStruct = {
				"productId": application.commonFunctions.encryptText(local.qryGetProducts.fldProduct_Id),
				"productName": local.qryGetProducts.fldProductName,
				"brandId": application.commonFunctions.encryptText(local.qryGetProducts.fldBrandId),
				"brandName": local.qryGetProducts.fldBrandName,
				"description": local.qryGetProducts.fldDescription,
				"price": local.qryGetProducts.fldPrice,
				"tax": local.qryGetProducts.fldTax,
				"productImage": local.qryGetProducts.fldProductImage,
				"categoryId": application.commonFunctions.encryptText(local.qryGetProducts.fldCategory_Id),
				"subCategoryName": local.qryGetProducts.fldSubCategoryName
			}>

			<!--- Append each product struct to the response array --->
			<cfset arrayAppend(local.response.data, local.productStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getBrands" access="public" returnType="struct">
		<cfset local.response = {
			"data" = []
		}>

		<cfquery name="local.qryGetBrands">
			SELECT
				fldBrand_Id,
				fldBrandName
			FROM
				tblBrands
			ORDER BY
				fldBrandName
		</cfquery>

		<!--- Fill up the array with brand information --->
		<cfloop query="local.qryGetBrands">
			<cfset local.brandStruct = {
				"brandId": application.commonFunctions.encryptText(local.qryGetBrands.fldBrand_Id),
				"brandName": local.qryGetBrands.fldBrandName
			}>

			<cfset arrayAppend(local.response.data, local.brandStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getProductImages" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
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

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetImages">
			SELECT
				fldProductImage_Id,
				fldImageFileName,
				fldDefaultImage
			FROM
				tblProductImages
			WHERE
				fldProductId = <cfqueryparam value = "#val(local.productId)#" cfsqltype = "integer">
				AND fldActive = 1
			ORDER BY
				fldDefaultImage DESC <!--- This is to make sure default image comes first --->
		</cfquery>

		<cfloop query="local.qryGetImages">
			<cfset local.imageStruct = {
				"imageId" = application.commonFunctions.encryptText(local.qryGetImages.fldProductImage_Id),
				"imageFileName" = local.qryGetImages.fldImageFileName,
				"defaultImage" = local.qryGetImages.fldDefaultImage
			}>
			<cfset arrayAppend(local.response.data, local.imageStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getCart" access="public" returnType="struct">
		<cfset local.cartItems = {}>

		<!--- UserId Validation --->
		<cfif NOT structKeyExists(session, "userId")>
			<cfreturn local.cartItems>
		</cfif>

		<cfquery name="local.qryGetCart">
			SELECT
				C.fldCart_Id,
				C.fldProductId,
				C.fldQuantity,
				P.fldPrice,
				P.fldTax
			FROM
				tblCart C
				INNER JOIN tblProduct P ON C.fldProductId = P.fldProduct_Id
					AND P.fldActive = 1 <!--- Only take active products --->
			WHERE
				C.fldUserId = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
		</cfquery>

		<cfloop query="local.qryGetCart">
			<cfset local.cartItems[application.commonFunctions.encryptText(local.qryGetCart.fldProductId)] = {
				"quantity" = local.qryGetCart.fldQuantity
			}>
		</cfloop>

		<cfreturn local.cartItems>
	</cffunction>

	<cffunction name="getAddress" access="public" returnType="struct">
		<cfargument name="addressId" type="string" required=false default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
		}>

		<!--- Decrypt ids--->
		<cfset local.addressId = application.commonFunctions.decryptText(arguments.addressId)>

		<!--- Address Id Validation --->
		<cfif len(arguments.addressId) AND (local.addressId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] = "Address Id is invalid.">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetAddress">
			SELECT
				fldAddress_Id,
				fldFirstName,
				fldLastName,
				fldAddressLine1,
				fldAddressLine2,
				fldCity,
				fldState,
				fldPincode,
				fldPhone
			FROM
				tblAddress
			WHERE
				fldActive = 1
				<cfif local.addressId NEQ -1>
					AND fldAddress_Id = <cfqueryparam value = "#val(local.addressId)#" cfsqltype = "integer">
				<cfelse>
					AND fldUserId = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
				</cfif>
		</cfquery>

		<cfloop query="local.qryGetAddress">
			<cfset arrayAppend(local.response.data, {
				"addressId" = application.commonFunctions.encryptText(local.qryGetAddress.fldAddress_Id),
				"fullName" = local.qryGetAddress.fldFirstName & " " & local.qryGetAddress.fldLastName,
				"addressLine1" = local.qryGetAddress.fldAddressLine1,
				"addressLine2" = local.qryGetAddress.fldAddressLine2,
				"city" = local.qryGetAddress.fldCity,
				"state" = local.qryGetAddress.fldState,
				"pincode" = local.qryGetAddress.fldPincode,
				"phone" = local.qryGetAddress.fldPhone
			})>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getOrders" access="public" returnType="struct">
		<cfargument name="searchTerm" type="string" required=false default="">
		<cfargument name="orderId" type="string" required=false default="">
		<cfargument name="pageNumber" type="integer" required=false default=1>
		<cfargument name="pageSize" type="integer" required=false default=4>

		<cfset local.response = {
			"message" = "",
			"data" = [],
			"hasMoreRows" = false
		}>

		<!--- Validate login --->
		<cfif NOT structKeyExists(session, "userId")>
			<cfset local.response["message"] = "User not authenticated">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetOrders">
			SELECT
				O.fldOrder_Id,
				O.fldOrderDate,
				O.fldTotalPrice,
				O.fldTotalTax,
				A.fldAddressLine1,
				A.fldAddressLine2,
				A.fldCity,
				A.fldState,
				A.fldPincode,
				A.fldFirstName,
				A.fldLastName,
				A.fldPhone,
				GROUP_CONCAT(OI.fldProductId SEPARATOR ',') AS productIds,
				GROUP_CONCAT(OI.fldQuantity SEPARATOR ',') AS quantities,
				GROUP_CONCAT(OI.fldUnitPrice SEPARATOR ',') AS unitPrices,
				GROUP_CONCAT(OI.fldUnitTax SEPARATOR ',') AS unitTaxes,
				GROUP_CONCAT(P.fldProductName SEPARATOR ',') AS productNames,
				GROUP_CONCAT(PI.fldImageFileName SEPARATOR ',') AS productImages,
				GROUP_CONCAT(B.fldBrandName SEPARATOR ',') AS brandNames
			FROM
				tblOrder O
				INNER JOIN tblAddress A ON A.fldAddress_Id = O.fldAddressId
				INNER JOIN tblOrderItems OI ON OI.fldOrderId = O.fldOrder_Id
				INNER JOIN tblProduct P ON P.fldProduct_Id = OI.fldProductId
				INNER JOIN tblProductImages PI ON PI.fldProductId = P.fldProduct_Id
					AND PI.fldDefaultImage = 1
				INNER JOIN tblBrands B ON B.fldBrand_Id = P.fldBrandId
			WHERE
				O.fldUserId = <cfqueryparam value = "#session.userId#" cfsqltype = "varchar">
				<cfif len(trim(arguments.orderId))>
					<!--- For printing pdf for each order --->
					AND O.fldOrder_Id = <cfqueryparam value = "#arguments.orderId#" cfsqltype = "varchar">
				<cfelse>
					<!--- When searching for orders --->
					AND O.fldOrder_Id LIKE <cfqueryparam value = "%#trim(arguments.searchTerm)#%" cfsqltype = "varchar">
				</cfif>
			GROUP BY
				O.fldOrder_Id
			ORDER BY
				O.fldOrderDate DESC

			<!--- Only apply limit and offset if order id is not specified --->
			<!--- Otherwise no order will be returned --->
			<cfif NOT len(trim(arguments.orderId)) AND val(arguments.pageNumber)>
				<!--- Querying one extra order to check whether its the end of orders --->
				LIMIT <cfqueryparam value = "#arguments.pageSize + 1#" cfsqltype = "integer">
				OFFSET <cfqueryparam value = "#(arguments.pageNumber - 1) * arguments.pageSize#" cfsqltype = "integer">
			</cfif>
		</cfquery>

		<!--- Check whether there are more orders --->
		<cfif local.qryGetOrders.recordCount GT arguments.pageSize>
			<cfset local.response.hasMoreRows = true>

			<!--- Remove the extra row --->
			<cfset local.qryGetOrders = queryDeleteRow(local.qryGetOrders, local.qryGetOrders.recordCount)>
		</cfif>

		<cfloop query="local.qryGetOrders">
			<cfset arrayAppend(local.response["data"], {
				"orderId" = local.qryGetOrders.fldOrder_Id,
				"orderDate" = local.qryGetOrders.fldOrderDate,
				"totalPrice" = local.qryGetOrders.fldTotalPrice,
				"totalTax" = local.qryGetOrders.fldTotalTax,
				"addressLine1" = local.qryGetOrders.fldAddressLine1,
				"addressLine2" = local.qryGetOrders.fldAddressLine2,
				"city" = local.qryGetOrders.fldCity,
				"state" = local.qryGetOrders.fldState,
				"pincode" = local.qryGetOrders.fldPincode,
				"firstName" = local.qryGetOrders.fldFirstName,
				"lastName" = local.qryGetOrders.fldLastName,
				"phone" = local.qryGetOrders.fldPhone,
				"productIds" = listMap(local.qryGetOrders.productIds, function(item) {
					return application.commonFunctions.encryptText(item);
				}),
				"quantities" = local.qryGetOrders.quantities,
				"unitPrices" = local.qryGetOrders.unitPrices,
				"unitTaxes" = local.qryGetOrders.unitTaxes,
				"productNames" = local.qryGetOrders.productNames,
				"productImages" = local.qryGetOrders.productImages,
				"brandNames" = local.qryGetOrders.brandNames
			})>
		</cfloop>

		<cfreturn local.response>
	</cffunction>
</cfcomponent>