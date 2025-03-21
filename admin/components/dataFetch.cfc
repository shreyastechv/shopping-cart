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
		<cfargument name="categoryId" type="string" required=false default="">
		<cfargument name="subCategoryId" type="string" required=false default="">
		<cfargument name="productId" type="string" required=false default="">
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
			<!--- Decrypt ids--->
			<cfset local.categoryId = application.commonFunctions.decryptText(arguments.categoryId)>
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

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

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
						<cfif local.categoryId NEQ -1>
							AND C.fldCategory_Id = <cfqueryparam value = "#val(local.categoryId)#" cfsqltype = "integer">
						<cfelseif local.subCategoryId NEQ -1>
							AND P.fldSubCategoryId = <cfqueryparam value = "#val(local.subCategoryId)#" cfsqltype = "integer">
						<cfelseif local.productId NEQ -1>
							AND P.fldProduct_Id = <cfqueryparam value = "#val(local.productId)#" cfsqltype = "integer">
						<cfelseif len(trim(arguments.productIdList))>
							AND P.fldProduct_Id IN (<cfqueryparam value = "#local.productIdList#" cfsqltype = "varchar" list = "yes">)
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

						<!--- Sorting --->
						<cfif arguments.random EQ 1>
							ORDER BY
								RAND()
						<cfelseif len(trim(arguments.sort))>
							ORDER BY
								P.fldPrice #arguments.sort#
						</cfif>

						<!--- Limit the number of products returned --->
						<!--- Don't use this limiting method if category id is used to fetch products --->
						<!--- Because another technique is used to limit in that case --->
						<cfif (val(arguments.limit) NEQ 0) AND (local.categoryId EQ -1)>
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
				<cfif (val(local.categoryId) NEQ -1) AND val(arguments.limit)>
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
</cfcomponent>