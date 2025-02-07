<!--- Attribute Params --->
<cfparam name="attributes.products" type="struct" default={}>

<!--- Get Product Details --->
<cfset local.qryProductInfo = application.shoppingCart.getProducts(productIdList = structKeyList(attributes.products))>

<cfoutput>
	<cfloop query="#local.qryProductInfo#">
		<!--- Encrypt Product ID since it is passed to URL param --->
		<cfset variables.encryptedProductId = application.shoppingCart.encryptUrlParam(local.qryProductInfo.fldProduct_Id)>

		<!--- Calculate price and actual price --->
		<cfset local.quantity = attributes.products[local.qryProductInfo.fldProduct_Id].quantity>
		<cfset local.actualPrice = local.qryProductInfo.fldPrice * local.quantity>
		<cfset local.price = local.qryProductInfo.fldPrice * (1 + (local.qryProductInfo.fldTax / 100)) * local.quantity>

		<!--- Sum up total price and total actual price --->
		<cfset caller.totalPrice += local.price>
		<cfset caller.totalActualPrice += local.actualPrice>

		<div class="card mb-3 shadow" id="productContainer_#local.qryProductInfo.fldProduct_Id#">
			<div class="row g-0">
				<div class="col-md-4 p-3">
					<a href="/productPage.cfm?productId=#variables.encryptedProductId#">
						<img src="#application.productImageDirectory&local.qryProductInfo.fldProductImage#" class="img-fluid rounded-start" alt="Product">
					</a>
				</div>
				<div class="col-md-8">
					<div class="card-body">
						<h5 class="card-title">#local.qryProductInfo.fldProductName#</h5>
						<p class="mb-1">Price: <span class="fw-bold">Rs. <span name="price">#local.price#</span></span></p>
						<p class="mb-1">Actual Price: <span class="fw-bold">Rs. <span name="actualPrice">#local.actualPrice#</span></span></p>
						<p class="mb-1">Tax: <span class="fw-bold"><span name="tax">#local.qryProductInfo.fldTax#</span> %</span></p>
						<div class="d-flex align-items-center">
							<button type="button" class="btn btn-outline-primary btn-sm me-2" name="decBtn" onclick="editCartItem('productContainer_#local.qryProductInfo.fldProduct_Id#', #local.qryProductInfo.fldProduct_Id#, 'decrement')"
							<cfif attributes.products[local.qryProductInfo.fldProduct_Id].quantity EQ 1>
								disabled
							</cfif>
							>-</button>

							<input type="text" name="quantity" class="form-control text-center w-25" value="#attributes.products[local.qryProductInfo.fldProduct_Id].quantity#" onchange="handleQuantityChange('productContainer_#local.qryProductInfo.fldProduct_Id#')" readonly>
							<button type="button" class="btn btn-outline-primary btn-sm ms-2" name="incBtn" onclick="editCartItem('productContainer_#local.qryProductInfo.fldProduct_Id#', #local.qryProductInfo.fldProduct_Id#, 'increment')">+</button>
						</div>
						<button type="button" class="btn btn-danger btn-sm mt-3" onclick="editCartItem('productContainer_#local.qryProductInfo.fldProduct_Id#', #local.qryProductInfo.fldProduct_Id#, 'delete')">Remove</button>
					</div>
				</div>
			</div>
		</div>
	</cfloop>
</cfoutput>
