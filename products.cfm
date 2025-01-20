<!--- Clear variables scope to prevent issues --->
<cfset structClear(variables)>

<!--- URL params --->
<cfparam name="url.categoryId" default="0">
<cfparam name="url.subCategoryId" default="0">

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
		random = 1,
		limit = 8
	)>
</cfif>


<cfoutput>
	<!--- Main Content --->
	<div class="d-flex flex-column">
		<cfif structKeyExists(variables, "qrySubCategories")>
			<cfloop query="variables.qrySubCategories">
				<div class="h4">#variables.qrySubCategories.fldSubCategoryName#</div>
				<cfset variables.qryProducts = application.shoppingCart.getProducts(
					subCategoryId = variables.qrySubCategories.fldSubCategory_Id,
					random = 1,
					limit = 4
				)>
				<div class="d-flex flex-wrap px-3 py-1">
					<cfloop query="variables.qryProducts">
						<div class="w-16 d-flex flex-column align-items-center border rounded border-dark mb-3">
							<img src="#application.productImageDirectory&variables.qryProducts.fldProductImage#" class="productThumbnail" alt="Random Product Image">
							<div>
								<p class="fs-3 text-dark fw-semibold">#variables.qryProducts.fldProductName#</p>
							</div>
						</div>
					</cfloop>
				</div>
			</cfloop>
		<cfelse>
			<div class="d-flex flex-wrap px-3 py-1">
				<cfloop query="variables.qryProducts">
					<div class="w-16 d-flex flex-column align-items-center border rounded border-dark mb-3">
						<img src="#application.productImageDirectory&variables.qryProducts.fldProductImage#" class="productThumbnail" alt="Random Product Image">
						<div>
							<p class="fs-3 text-dark fw-semibold">#variables.qryProducts.fldProductName#</p>
						</div>
					</div>
				</cfloop>
			</div>
		</cfif>
	</div>
</cfoutput>