<!--- Attribute Params --->
<cfparam name="attributes.qryProducts" default="">

<cfoutput>
	<div class="row px-3 py-1">
		<cfloop query="attributes.qryProducts">
			<!--- Encrypt Product ID since it is passed to URL param --->
			<cfset variables.encryptedProductId = application.shoppingCart.encryptUrlParam(attributes.qryProducts.fldProduct_Id)>

			<div class="col-sm-2 mb-4">
				<div class="card rounded-3 h-100 shadow" onclick="location.href='/productPage.cfm?productId=#variables.encryptedProductId#'" role="button">
					<img src="#application.productImageDirectory&attributes.qryProducts.fldProductImage#" class="p-1 rounded-3" alt="Random Product Image">
					<div class="card-body">
						<div class="card-text fw-semibold mb-1">#attributes.qryProducts.fldProductName#</div>
						<div class="card-text text-secondary text-truncate mb-1">#attributes.qryProducts.fldDescription#</div>
						<div class="card-text fw-bold mb-1">Rs. #attributes.qryProducts.fldPrice#</div>
					</div>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>