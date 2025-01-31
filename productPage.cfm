<!--- URL params --->
<cfparam name="url.productId" default="">

<!--- Decrypt URL Params --->
<cfset variables.productId = application.shoppingCart.decryptUrlParam(url.productId)>

<!--- Check URL params --->
<cfif variables.productId EQ -1>
	<cflocation url="/" addToken="false">
</cfif>

<!--- Get Data if productId is given --->
<cfset variables.qryProductInfo = application.shoppingCart.getProducts(productId = variables.productId)>
<cfset variables.qryProductImages = application.shoppingCart.getProductImages(productId = variables.productId)>

<!--- Handle Add to Cart --->
<cfif structKeyExists(form, "addToCart")>
	<cfif structKeyExists(session, "userId")>
		<cfset application.shoppingCart.addToCart(
			productId = application.shoppingCart.decryptUrlParam(url.productId)
		)>
		<cflocation url="#cgi.HTTP_URL#" addToken="no">
	<cfelse>
		<cflocation url="/login.cfm?productId=#url.productId#" addToken="no">
	</cfif>
</cfif>

<cfoutput>
	<div class="container mt-5">
		<div class="row d-flex justify-content-center">
			<!-- Product Image -->
			<div class="col-md-4" data-bs-theme="dark">
				<div id="productImages" class="carousel slide border border-secondary d-flex align-items-center rounded-2 p-5 h-100 shadow">
					<div class="carousel-inner">
						<cfloop array="#variables.qryProductImages#" item="local.imageItem">
							<div class="carousel-item #(local.imageItem.defaultImage EQ 1 ? "active" : "")#">
								<div class="d-flex justify-content-center">
									<img src="#application.productImageDirectory&local.imageItem.imageFileName#" class="img-fluid" alt="Product Image">
								</div>
							</div>
						</cfloop>
					</div>
					<button class="carousel-control-prev" type="button" data-bs-target="##productImages" data-bs-slide="prev">
						<span class="carousel-control-prev-icon" aria-hidden="true"></span>
						<span class="visually-hidden">Previous</span>
					</button>
					<button class="carousel-control-next" type="button" data-bs-target="##productImages" data-bs-slide="next">
						<span class="carousel-control-next-icon" aria-hidden="true"></span>
						<span class="visually-hidden">Next</span>
					</button>
				</div>
			</div>

			<!-- Product Details -->
			<div class="col-md-6">
				<h1 class="display-4">#variables.qryProductInfo.fldProductName#</h1>
				<p class="lead">#variables.qryProductInfo.fldBrandName#</p>
				<p class="h4 text-success">Rs. #variables.qryProductInfo.fldPrice#</p>
				<p class="h6 text-secondary">Tax: #variables.qryProductInfo.fldTax#%</p>
				<p class="mt-4">#variables.qryProductInfo.fldDescription#</p>

				<!-- Action Buttons -->
				<div class="mt-4">
					<form method="post">
						<cfif structKeyExists(session, "cart") AND structKeyExists(session.cart, variables.productId)>
							<!--- Show go to cart button if product is present in cart --->
							<a class="btn btn-warning btn-lg" href="cart.cfm">Go to Cart</a>
						<cfelse>
							<!--- Show add to cart button if product not in cart --->
							<button type="submit" name="addToCart" class="btn btn-primary btn-lg mr-3">Add to Cart</button>
						</cfif>
						<button type="submit" name="buyNow" class="btn btn-danger btn-lg">Buy Now</button>
					</form>
				</div>
			</div>
		</div>
	</div>
</cfoutput>
