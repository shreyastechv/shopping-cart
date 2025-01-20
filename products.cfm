<!--- Clear variables scope to prevent issues --->
<cfset structClear(variables)>

<!--- URL params --->
<cfparam name="url.categoryId" default="0">
<cfparam name="url.subCategoryId" default="0">
<cfparam name="url.sort" default="">

<!--- Check url params --->
<cfif url.categoryId EQ 0 AND url.subCategoryId EQ 0>
	<!--- Exit if categoryId and subCategoryId are not given --->
	<cflocation  url="/" addToken="false">
<cfelseif url.categoryId NEQ 0>
	<!--- Get Data if categoryId is given --->
	<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories(categoryId = url.categoryId)>
<cfelse>
	<!--- Get Data if subCategoryId is given --->
	<cfset variables.qryProducts = application.shoppingCart.getProducts(
		subCategoryId = url.subCategoryId,
		limit = 8,
		sort = url.sort
	)>
</cfif>

<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column">
		<cfif structKeyExists(variables, "qrySubCategories")>
			<!--- Category Listing --->
			<cfloop query="variables.qrySubCategories">
				<a href="/products.cfm?subCategoryId=#variables.qrySubCategories.fldSubCategory_Id#" class="h4 text-decoration-none">#variables.qrySubCategories.fldSubCategoryName#</a>
				<cfset local.qryProducts = application.shoppingCart.getProducts(
					subCategoryId = variables.qrySubCategories.fldSubCategory_Id,
					random = 1,
					limit = 4
				)>
				<cf_productlist qryProducts="#local.qryProducts#">
			</cfloop>
		<cfelse>
			<!--- Sorting --->
			<div class="d-flex gap-2 px-3 py-2">
				<a class="text-decoration-none" href="/products.cfm?subCategoryId=#url.subCategoryId#&sort=asc">Price: Low to High</a>
				<a class="text-decoration-none" href="/products.cfm?subCategoryId=#url.subCategoryId#&sort=desc">Price: High to Low</a>
			</div>

			<!--- Sub Category Listing --->
			<cf_productlist qryProducts="#variables.qryProducts#">
		</cfif>
	</div>
</cfoutput>