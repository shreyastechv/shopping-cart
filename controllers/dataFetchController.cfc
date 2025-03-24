<cfcomponent displayname="Data Fetching Controller" hint="Includes controller functions that help in fetching data from db">
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
			"message" = ""
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
			<cfif NOT arrayContainsNoCase(["asc",  "desc", "newest", ""], arguments.sort)>
				<cfset local.response["message"] &= "Sort value should either be asc or desc">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<cfset local.response = application.dataFetch.getProducts(
				categoryId = local.categoryId,
				subCategoryId = local.subCategoryId,
				productId = local.productId,
				productIdList = local.productIdList,
				random = arguments.random,
				limit = arguments.limit,
				offset = arguments.offset,
				sort = arguments.sort,
				min = arguments.min,
				max = arguments.max,
				searchTerm = arguments.searchTerm
			)>

			<cfcatch type="any">
				<cfset local.response.success = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>
</cfcomponent>