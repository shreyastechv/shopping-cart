<!--- URL params --->
<cfparam name="url.productId" default="">

<!--- Check URL params --->
<cfif len(trim(url.productId)) EQ 0>
	<cflocation url="/" addToken="false">
</cfif>

<!--- Get Data if productId is given --->
<cfset variables.productInfo = application.shoppingCart.getProducts(productId = url.productId)>
<cfset variables.qryProductImages = application.shoppingCart.getProductImages(productId = url.productId)>

<!--- Handle add to cart button --->
<cfif structKeyExists(form, "addToCart")>
	<cfif structKeyExists(session, "userId")>
		<cfset application.shoppingCart.modifyCart(
			productId = url.productId,
			action = "increment"
		)>
		<!--- Go to cart page if user is logged in --->
		<cflocation url="/cart.cfm" addToken="no">
	<cfelse>
		<!--- Go to login page if user is not logged in --->
		<cflocation url="/login.cfm?productId=#urlEncodedFormat(url.productId)#&redirect=cart.cfm" addToken="no">
	</cfif>
</cfif>

<!--- Handle buy now button --->
<cfif structKeyExists(form, "buyNow")>
	<cfif structKeyExists(session, "userId")>
		<cfset application.shoppingCart.modifyCart(
			productId = url.productId,
			action = "increment"
		)>
		<!--- Go to checkout page if user is logged in --->
		<cflocation url="/checkout.cfm?productId=#urlEncodedFormat(url.productId)#" addToken="no">
	<cfelse>
		<!--- Go to login page if user is not logged in --->
		<cflocation url="/login.cfm?productId=#urlEncodedFormat(url.productId)#&redirect=checkout.cfm" addToken="no">
	</cfif>
</cfif>

<cfoutput>
	<div class="container mt-5">
		<div class="row d-flex justify-content-center">
			<!-- Product Image -->
			<div class="col-md-4" data-bs-theme="dark">
				<div id="productImages" class="carousel slide border border-secondary d-flex align-items-center rounded-2 p-5 h-100 shadow">
					<div class="carousel-inner">
						<cfloop array="#variables.qryProductImages.data#" item="variables.imageItem">
							<div class="carousel-item #(variables.imageItem.defaultImage EQ 1 ? "active" : "")#">
								<div class="d-flex justify-content-center">
									<img src="#application.productImageDirectory&variables.imageItem.imageFileName#" class="img-fluid" alt="Product Image">
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
				<h1 class="display-4">#variables.productInfo.data[1].productName#</h1>
				<p class="lead">#variables.productInfo.data[1].brandName#</p>
				<p class="h4 text-success">Rs. #variables.productInfo.data[1].price#</p>
				<p class="h6 text-secondary">Tax: #variables.productInfo.data[1].tax#%</p>
				<p class="mt-4">#variables.productInfo.data[1].description#</p>

				<!-- Action Buttons -->
				<div class="mt-4">
					<form method="post">
						<!--- Add to cart button --->
						<button type="submit" name="addToCart" class="btn btn-primary btn-lg mr-3">Add to Cart</button>

						<!---Buy now button --->
						<button type="submit" name="buyNow" class="btn btn-danger btn-lg">Buy Now</button>
					</form>
				</div>
			</div>
		</div>
	</div>
</cfoutput>
