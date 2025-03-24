<cfcomponent displayname="Data Fetching" hint="Includes functions that help in fetching data from db">
	<cffunction name="getCategories" access="public" returnType="struct">
		<cfargument name="categoryId" type="string" required=false default="">

		<!--- Create response struct --->
		<cfset local.response = {
			"success" = true,
			"data" = []
		}>

		<cftry>
			<!--- Decrypt ids--->
			<cfset local.categoryId = application.commonFunctions.decryptText(arguments.categoryId)>

			<cfquery name="local.qryGetCategories"
				cachedWithin = "#(structKeyExists(session, "roleId") && session.roleId == 1 ? createTimespan(0, 0, 0, 0) : createTimespan(0, 1, 0, 0))#"
			>
				SELECT
					fldCategory_Id,
					fldCategoryName
				FROM
					tblCategory
				WHERE
					fldActive = 1
					<cfif val(local.categoryId) NEQ -1>
						AND fldCategory_Id = <cfqueryparam value = "#val(local.categoryId)#" cfsqltype = "integer">
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

			<cfcatch type="any">
				<cfset local.response.success = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getSubCategories" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="categoryId" type="string" required=false default="">
		<cfargument name="subCategoryId" type="string" required=false default="">

		<cfset local.response = {
			"success" = true,
			"message" = "",
			"data" = []
		}>

		<cftry>
			<!--- Decrypt ids--->
			<cfset local.categoryId = application.commonFunctions.decryptText(arguments.categoryId)>
			<cfset local.subCategoryId = application.commonFunctions.decryptText(arguments.subCategoryId)>

			<!--- Category Id Validation --->
			<cfif len(trim(arguments.categoryId)) AND (local.categoryId EQ -1)>
				<!--- Value equals -1 means decryption failed --->
				<cfset local.response["message"] &= "Category Id is invalid. ">
			</cfif>

			<!--- Sub Category Id Validation --->
			<cfif len(trim(arguments.subCategoryId)) AND (local.subCategoryId EQ -1)>
				<!--- Value equals -1 means decryption failed --->
				<cfset local.response["message"] &= "Sub category Id is invalid. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- Continue with code execution if validation succeeds --->
			<cfquery name="local.qryGetSubCategories"
				cachedWithin = "#(structKeyExists(session, "roleId") && session.roleId == 1 ? createTimespan(0, 0, 0, 0) : createTimespan(0, 1, 0, 0))#"
			>
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
					<cfelseif local.subCategoryId NEQ -1>
						AND SC.fldSubCategory_Id = <cfqueryparam value = "#val(local.subCategoryId)#" cfsqltype = "integer">
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

			<cfcatch type="any">
				<cfset local.response.success = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getProducts" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="categoryId" type="integer" required=false default=-1>
		<cfargument name="subCategoryId" type="integer" required=false default=-1>
		<cfargument name="productId" type="integer" required=false default=-1>
		<cfargument name="productIdList" type="string" required=false default="">
		<cfargument name="random" type="integer" required=false default=0>
		<cfargument name="limit" type="integer" required="false" default=0>
		<cfargument name="offset" type="integer" required="false" default=0>
		<cfargument name="sort" type="string" required="false" default="">
		<cfargument name="min" type="float" required="false" default=0>
		<cfargument name="max" type="float" required="false" default=0>
		<cfargument name="searchTerm" type="string" required="false" default="">

		<cfset local.response = {
			"success" = true,
			"message" = "",
			"data" = [],
			"hasMoreRows" = false
		}>

		<cftry>
			<!--- Continue with code execution if validation succeeds --->
			<cfquery name="local.qryGetProducts">
				WITH productQuery AS (
					SELECT
						P.fldProduct_Id,
						P.fldProductName,
						P.fldBrandId,
						P.fldDescription,
						P.fldPrice,
						P.fldTax,
						B.fldBrandName,
						GROUP_CONCAT(PI.fldImageFileName ORDER BY PI.fldDefaultImage DESC SEPARATOR ',') AS fldProductImages,
						GROUP_CONCAT(PI.fldProductImage_Id ORDER BY PI.fldDefaultImage DESC SEPARATOR ',') AS fldProductImageIds,
						C.fldCategory_Id,
						C.fldCategoryName,
						SC.fldSubCategory_Id,
						SC.fldSubCategoryName,
						COUNT(*) OVER() AS totalRows,
						ROW_NUMBER() OVER (PARTITION BY P.fldSubCategoryId ORDER BY P.fldProduct_Id) AS rn
					FROM
						tblProduct P
						INNER JOIN tblBrands B ON P.fldBrandId = B.fldBrand_Id
						INNER JOIN tblSubCategory SC ON P.fldSubCategoryId = SC.fldSubCategory_Id
						INNER JOIN tblCategory C ON SC.fldCategoryId = C.fldCategory_Id
						INNER JOIN tblProductImages PI ON P.fldProduct_Id = PI.fldProductId
							AND PI.fldActive = 1
					WHERE
						P.fldActive = 1
						<cfif arguments.categoryId NEQ -1>
							AND C.fldCategory_Id = <cfqueryparam value = "#val(arguments.categoryId)#" cfsqltype = "integer">
						<cfelseif arguments.subCategoryId NEQ -1>
							AND P.fldSubCategoryId = <cfqueryparam value = "#val(arguments.subCategoryId)#" cfsqltype = "integer">
						<cfelseif arguments.productId NEQ -1>
							AND P.fldProduct_Id = <cfqueryparam value = "#val(arguments.productId)#" cfsqltype = "integer">
						<cfelseif len(trim(arguments.productIdList))>
							AND P.fldProduct_Id IN (<cfqueryparam value = "#arguments.productIdList#" cfsqltype = "varchar" list = "yes">)
						<cfelseif NOT val(arguments.limit)>
							<!--- This is to prevent retrieving all product data if limit is not specified --->
							AND 1 = 0
						</cfif>

						<!--- Minimum price --->
						<cfif val(arguments.min)>
							AND P.fldPrice >= <cfqueryparam value = "#arguments.min#" cfsqltype = "decimal">
						</cfif>

						<!--- Maximum price --->
						<!--- 0 is the default value of arguments.max hence it should not be used --->
						<cfif val(arguments.max) NEQ 0>
							AND P.fldPrice <= <cfqueryparam value = "#arguments.max#" cfsqltype = "decimal">
						</cfif>

						<!--- Searching --->
						<cfif len(trim(arguments.searchTerm))>
							AND (P.fldProductName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
								OR P.fldDescription LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
								OR C.fldCategoryName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
								OR SC.fldSubCategoryName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
								OR B.fldBrandName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">)
						</cfif>

					GROUP BY
						P.fldProduct_Id

					ORDER BY
						<!--- Sorting --->
						<cfif arguments.random EQ 1>
							RAND()
						<cfelseif arrayContainsNoCase(["asc",  "desc"], trim(arguments.sort))>
							P.fldPrice #arguments.sort#
						<cfelseif trim(arguments.sort) EQ "newest">
							P.fldCreatedDate DESC
						<cfelse>
							P.fldProductName ASC
						</cfif>

						<!--- Limit the number of products returned --->
						<!--- Don't use this limiting method if category id is used to fetch products --->
						<!--- Because another technique is used to limit in that case --->
						<cfif (val(arguments.limit) NEQ 0) AND (arguments.categoryId EQ -1)>
							<!--- Querying one extra product to check whether there are more products --->
							LIMIT <cfqueryparam value = "#val(arguments.limit)#" cfsqltype = "integer">
							<cfif val(arguments.offset)>
								OFFSET <cfqueryparam value = "#val(arguments.offset)#" cfsqltype = "integer">
							</cfif>
						</cfif>
				)
				SELECT
					*
				FROM
					productQuery
				<!--- Limit is calculated differently when it comes to category product listing --->
				<cfif (val(arguments.categoryId) NEQ -1) AND val(arguments.limit)>
					WHERE
						rn <= <cfqueryparam value = "#val(arguments.limit)#" cfsqltype = "integer">
				</cfif>
			</cfquery>

			<!--- Check whether there are more products --->
			<cfset local.response.hasMoreRows = (val(local.qryGetProducts.totalRows) - val(arguments.limit) - val(arguments.offset)) GT 0>

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
					"productImages": listToArray(local.qryGetProducts.fldProductImages),
					"productImageIds": listToArray(
						listMap(local.qryGetProducts.fldProductImageIds, function(item) {
							return application.commonFunctions.encryptText(item);
						})
					),
					"categoryId": application.commonFunctions.encryptText(local.qryGetProducts.fldCategory_Id),
					"categoryName": local.qryGetProducts.fldCategoryName,
					"subCategoryId": application.commonFunctions.encryptText(local.qryGetProducts.fldSubCategory_Id),
					"subCategoryName": local.qryGetProducts.fldSubCategoryName
				}>

				<!--- Append each product struct to the response array --->
				<cfset arrayAppend(local.response.data, local.productStruct)>
			</cfloop>

			<cfcatch type="any">
				<cfset local.response.success = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getBrands" access="public" returnType="struct">
		<cfset local.response = {
			"success" = true,
			"data" = []
		}>

		<cftry>
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

			<cfcatch type="any">
				<cfset local.response.success = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getCart" access="public" returnType="struct">
		<cfargument name="productId" type="string" required=false default="">

		<cfset local.response = {
			"success" = true,
			"items" = {},
			"totalPrice" = 0,
			"totalTax" = 0
		}>

		<cftry>
			<!--- Decrypt product id --->
			<cfset local.productId = application.commonFunctions.decryptText(arguments.productId)>

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
					<cfif val(local.productId) NEQ -1>
						AND C.fldProductId = <cfqueryparam value = "#local.productId#" cfsqltype = "integer">
					</cfif>
			</cfquery>

			<cfloop query="local.qryGetCart">
				<cfset local.response.items[application.commonFunctions.encryptText(local.qryGetCart.fldProductId)] = {
					"quantity" = local.qryGetCart.fldQuantity,
					"unitPrice" = local.qryGetCart.fldPrice,
					"unitTax" = local.qryGetCart.fldTax
				}>
				<cfset local.response.totalPrice += local.qryGetCart.fldQuantity * local.qryGetCart.fldPrice>
				<cfset local.response.totalTax += local.qryGetCart.fldQuantity * local.qryGetCart.fldPrice * local.qryGetCart.fldTax / 100>
			</cfloop>

			<cfcatch type="any">
				<cfset local.response.success = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getAddress" access="public" returnType="struct">
		<cfargument name="addressId" type="string" required=false default="">

		<cfset local.response = {
			"success" = true,
			"message" = "",
			"data" = []
		}>

		<cftry>
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

			<cfcatch type="any">
				<cfset local.response.success = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getOrders" access="public" returnType="struct">
		<cfargument name="searchTerm" type="string" required=false default="">
		<cfargument name="orderId" type="string" required=false default="">
		<cfargument name="pageNumber" type="integer" required=false default=1>
		<cfargument name="pageSize" type="integer" required=false default=4>

		<cfset local.response = {
			"success" = true,
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

		<cftry>
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
					GROUP_CONCAT(B.fldBrandName SEPARATOR ',') AS brandNames,
					COUNT(*) OVER(ORDER BY O.fldOrderDate) AS totalRows
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
					<cfelseif len(trim(arguments.searchTerm))>
						<!--- When searching for orders --->
						AND O.fldOrder_Id IN (
							SELECT
								O.fldOrder_Id
							FROM
								tblOrder O
								INNER JOIN tblAddress A ON A.fldAddress_Id = O.fldAddressId
								INNER JOIN tblOrderItems OI ON OI.fldOrderId = O.fldOrder_Id
								INNER JOIN tblProduct P ON P.fldProduct_Id = OI.fldProductId
								INNER JOIN tblProductImages PI ON PI.fldProductId = P.fldProduct_Id
									AND PI.fldDefaultImage = 1
								INNER JOIN tblBrands B ON B.fldBrand_Id = P.fldBrandId
							WHERE
								O.fldOrder_Id LIKE <cfqueryparam value = "%#trim(arguments.searchTerm)#%" cfsqltype = "varchar">
								OR P.fldProductName LIKE <cfqueryparam value = "%#trim(arguments.searchTerm)#%" cfsqltype = "varchar">
								OR B.fldBrandName LIKE <cfqueryparam value = "%#trim(arguments.searchTerm)#%" cfsqltype = "varchar">
						)
					</cfif>
				GROUP BY
					O.fldOrder_Id
				ORDER BY
					O.fldOrderDate DESC

				<!--- Only apply limit and offset if order id is not specified --->
				<!--- Otherwise no order will be returned --->
				<cfif NOT len(trim(arguments.orderId)) AND val(arguments.pageNumber)>
					<!--- Querying one extra order to check whether its the end of orders --->
					LIMIT <cfqueryparam value = "#arguments.pageSize#" cfsqltype = "integer">
					OFFSET <cfqueryparam value = "#(arguments.pageNumber - 1) * arguments.pageSize#" cfsqltype = "integer">
				</cfif>
			</cfquery>

			<cfset local.response.hasMoreRows = (val(local.qryGetOrders.totalRows) - val(arguments.pageSize) - (val(arguments.pageNumber - 1) * val(arguments.pageSize))) GT 0>

			<cfloop query="local.qryGetOrders">
				<cfset arrayAppend(local.response["data"], {
					"orderId" = local.qryGetOrders.fldOrder_Id,
					"orderDate" = local.qryGetOrders.fldOrderDate,
					"totalPrice" = local.qryGetOrders.fldTotalPrice,
					"totalTax" = local.qryGetOrders.fldTotalTax,
					"address" = {
						"addressLine1" = local.qryGetOrders.fldAddressLine1,
						"addressLine2" = local.qryGetOrders.fldAddressLine2,
						"city" = local.qryGetOrders.fldCity,
						"state" = local.qryGetOrders.fldState,
						"pincode" = local.qryGetOrders.fldPincode,
						"firstName" = local.qryGetOrders.fldFirstName,
						"lastName" = local.qryGetOrders.fldLastName,
						"phone" = local.qryGetOrders.fldPhone
					},
					"products" = []
				})>

				<cfloop list="#local.qryGetOrders.productNames#" item="item" index="i">
					<cfset arrayAppend(local.response.data[arrayLen(local.response.data)].products, {
						"productName" = listGetAt(local.qryGetOrders.productNames, i),
						"productId" = application.commonFunctions.encryptText(listGetAt(local.qryGetOrders.productIds, i)),
						"unitPrice" = listGetAt(local.qryGetOrders.unitPrices, i),
						"unitTax" = listGetAt(local.qryGetOrders.unitTaxes, i),
						"quantity" = listGetAt(local.qryGetOrders.quantities, i),
						"brandName" = listGetAt(local.qryGetOrders.brandNames, i),
						"productImage" = listGetAt(local.qryGetOrders.productImages, i)
					})>
				</cfloop>
			</cfloop>

			<cfcatch type="any">
				<cfset local.response.success = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getSliderImages" access="public" returnType="struct">
		<cfargument name="pageName" type="string" required=false default="">

		<!--- Create response struct --->
		<cfset local.response = {
			"data" = []
		}>

		<cftry>
			<!--- Fetch Data --->
			<cfquery name="local.qryGetSliderImages"
				cachedWithin = "#(structKeyExists(session, "roleId") && session.roleId == 1 ? createTimespan(0, 0, 0, 0) : createTimespan(0, 1, 0, 0))#"
			>
				SELECT
					fldImageFileName
				FROM
					tblSliderImages
				WHERE
					fldActive = 1
					<cfif len(trim(arguments.pageName))>
						AND fldPageName = <cfqueryparam value = "#trim(arguments.pageName)#" cfsqltype = "varchar">
					<cfelse>
						1 = 0
					</cfif>
			</cfquery>

			<!--- Fill up the array with information --->
			<cfloop query="local.qryGetSliderImages">
				<cfset local.imageStruct = {
					"imageFile": local.qryGetSliderImages.fldImageFileName
				}>

				<cfset arrayAppend(local.response.data, local.imageStruct)>
			</cfloop>

			<cfcatch type="any">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>
</cfcomponent>
