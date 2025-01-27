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
						<p class="card-text">#attributes.qryProducts.fldProductName#</p>
						<p class="card-text text-truncate">#attributes.qryProducts.fldDescription#</p>
						<p class="card-text">Rs. #attributes.qryProducts.fldPrice#</p>
					</div>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>