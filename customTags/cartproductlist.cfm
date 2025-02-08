<!--- Attribute Params --->
<cfparam name="attributes.products" type="struct" default={}>

<!--- Get Product Details --->
<cfset variables.qryProductInfo = application.shoppingCart.getProducts(productIdList = structKeyList(attributes.products))>

<cfoutput>
	<cfloop query="#variables.qryProductInfo#">
		<!--- Encrypt Product ID since it is passed to URL param --->
		<cfset variables.encryptedProductId = application.shoppingCart.encryptUrlParam(variables.qryProductInfo.fldProduct_Id)>
		<cfset variables.encodedProductId = urlEncodedFormat(variables.encryptedProductId)>

		<!--- Calculate price and actual price --->
		<cfset variables.quantity = attributes.products[variables.qryProductInfo.fldProduct_Id].quantity>
		<cfset variables.actualPrice = variables.qryProductInfo.fldPrice * variables.quantity>
		<cfset variables.price = variables.qryProductInfo.fldPrice * (1 + (variables.qryProductInfo.fldTax / 100)) * variables.quantity>

		<!--- Sum up total price and total actual price --->
		<cfset caller.totalPrice += variables.price>
		<cfset caller.totalActualPrice += variables.actualPrice>

		<div class="card mb-3 shadow" id="productContainer_#variables.qryProductInfo.fldProduct_Id#">
			<div class="row g-0">
				<div class="col-md-4 p-3">
					<a href="/productPage.cfm?productId=#variables.encodedProductId#">
						<img src="#application.productImageDirectory&variables.qryProductInfo.fldProductImage#" class="img-fluid rounded-start" alt="Product">
					</a>
				</div>
				<div class="col-md-8">
					<div class="card-body">
						<h5 class="card-title">#variables.qryProductInfo.fldProductName#</h5>
						<p class="mb-1">Price: <span class="fw-bold">Rs. <span name="price">#variables.price#</span></span></p>
						<p class="mb-1">Actual Price: <span class="fw-bold">Rs. <span name="actualPrice">#variables.actualPrice#</span></span></p>
						<p class="mb-1">Tax: <span class="fw-bold"><span name="tax">#variables.qryProductInfo.fldTax#</span> %</span></p>
						<div class="d-flex align-items-center">
							<button type="button" class="btn btn-outline-primary btn-sm me-2" name="decBtn" onclick="editCartItem('productContainer_#variables.qryProductInfo.fldProduct_Id#', #variables.qryProductInfo.fldProduct_Id#, 'decrement')"
							<cfif attributes.products[variables.qryProductInfo.fldProduct_Id].quantity EQ 1>
								disabled
							</cfif>
							>-</button>

							<input type="text" name="quantity" class="form-control text-center w-25" value="#attributes.products[variables.qryProductInfo.fldProduct_Id].quantity#" onchange="handleQuantityChange('productContainer_#variables.qryProductInfo.fldProduct_Id#')" readonly>
							<button type="button" class="btn btn-outline-primary btn-sm ms-2" name="incBtn" onclick="editCartItem('productContainer_#variables.qryProductInfo.fldProduct_Id#', #variables.qryProductInfo.fldProduct_Id#, 'increment')">+</button>
						</div>
						<button type="button" class="btn btn-danger btn-sm mt-3" onclick="editCartItem('productContainer_#variables.qryProductInfo.fldProduct_Id#', #variables.qryProductInfo.fldProduct_Id#, 'delete')">Remove</button>
					</div>
				</div>
			</div>
		</div>
	</cfloop>
</cfoutput>
