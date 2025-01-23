<!--- Attribute Params --->
<cfparam name="attributes.qryProducts" default="">

<cfoutput>
	<div class="d-flex flex-wrap px-3 py-1">
		<cfloop query="attributes.qryProducts">
			<!--- Encrypt Product ID since it is passed to URL param --->
			<cfset variables.encryptedProductId = application.shoppingCart.encryptUrlParam(attributes.qryProducts.fldProduct_Id)>

			<div onclick="location.href='/productPage.cfm?productId=#variables.encryptedProductId#'" role="button" class="pe-auto w-16 d-flex flex-column align-items-center border rounded border-dark mb-3">
				<img src="#application.productImageDirectory&attributes.qryProducts.fldProductImage#" class="productThumbnail" alt="Random Product Image">
				<div>
					<p class="fs-3 text-dark fw-semibold">#attributes.qryProducts.fldProductName#</p>
					<p class="fs-6 text-dark text-truncate" style="max-width: 190px;">#attributes.qryProducts.fldDescription#</p>
					<p class="fs-5 text-success fw-semibold">Rs. #attributes.qryProducts.fldPrice#</p>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>
