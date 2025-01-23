<!--- URL params --->
<cfparam name="url.productId" default="0">

<!--- Check URL params --->
<cfif url.productId NEQ 0>
	<!--- Get Data if productId is given --->
	<cfset variables.qryProductInfo = application.shoppingCart.getProducts(productId = url.productId)>
	<cfset variables.qryProductImages = application.shoppingCart.getProductImages(productId = url.productId)>
<cfelse>
	<!--- Exit if Required URL Params are not passed --->
	<cflocation url="/" addToken="false">
</cfif>

<!--- Handle Add to Cart --->
<cfif structKeyExists(form, "addToCart")>
	<cfif structKeyExists(session, "userId")>
		<cfset application.shoppingCart.addToCart(
			productId = url.productId
		)>
		<cflocation url="/productPage.cfm?productId=#url.productId#" addToken="no">
	<cfelse>
		<cflocation url="/login.cfm?productId=#url.productId#" addToken="no">
	</cfif>
</cfif>

<cfoutput>
	<div class="container mt-5">
		<div class="row">
			<!-- Product Image -->
			<div class="col-md-6" data-bs-theme="dark">
				<div id="carouselExample" class="carousel slide">
					<div class="carousel-inner d-flex justify-content-around">
						<cfloop array="#variables.qryProductImages#" item="local.imageItem">
							<div class="carousel-item #(local.imageItem.defaultImage EQ 1 ? "active" : "")#">
								<img src="#application.productImageDirectory&local.imageItem.imageFileName#" class="img-fluid" alt="Product Image">
							</div>
						</cfloop>
					</div>
					<button class="carousel-control-prev" type="button" data-bs-target="##carouselExample" data-bs-slide="prev">
						<span class="carousel-control-prev-icon" aria-hidden="true"></span>
						<span class="visually-hidden">Previous</span>
					</button>
					<button class="carousel-control-next" type="button" data-bs-target="##carouselExample" data-bs-slide="next">
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
						<button type="submit" name="addToCart" class="btn btn-primary btn-lg mr-3">Add to Cart</button>
						<button type="submit" name="buyNow" class="btn btn-danger btn-lg">Buy Now</button>
					</form>
				</div>
			</div>
		</div>
	</div>
</cfoutput>