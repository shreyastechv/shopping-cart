<!--- URL params --->
<cfparam name="url.productId" default="">

<!--- Check URL params --->
<cfif len(trim(url.productId)) EQ 0>
	<cflocation url="/" addToken="false">
</cfif>

<!--- Get Data if productId is given --->
<cfset variables.productInfo = application.dataFetchController.getProducts(productId = url.productId)>

<!--- Prevent entering the page if product data is empty --->
<!--- This usually happends if the product id in url is invalid --->
<cfif arrayLen(variables.productInfo.data) EQ 0>
	<cfinclude template="/404.cfm">
</cfif>

<!--- Handle add to cart button --->
<cfif structKeyExists(form, "addToCart")>
	<cfif structKeyExists(session, "userId")>
		<cfset variables.result = application.cartManagement.modifyCart(
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
		<cfset application.cartManagement.modifyCart(
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
	<cfif arrayLen(variables.productInfo.data)>
		<div class="container-fluid p-5">
			<div class="row d-flex justify-content-center">
				<!-- Product Image -->
				<div class="col-md-4" data-bs-theme="dark">
					<div id="productImages" class="carousel slide border border-secondary d-flex align-items-center rounded-2 p-5 shadow">
						<div class="carousel-inner">
							<!--- Loop images when there are images in db --->
							<cfif arrayLen(variables.productInfo.data[1].productImages)>
								<cfloop array="#variables.productInfo.data[1].productImages#" item="item" index="i">
									<div class="carousel-item #(i EQ 1 ? "active" : "")#">
										<div class="d-flex justify-content-center">
											<img src="#application.productImageDirectory&item#" class="img-fluid rounded-2" alt="Product Image">
										</div>
									</div>
								</cfloop>
							<cfelse>
								<!--- Handle case where there are no images to the product in db --->
								<div class="carousel-item active">
									<div class="d-flex justify-content-center">
										<img src="#application.imageDirectory#no-image.png" class="img-fluid rounded-2" alt="Product Image">
									</div>
								</div>
							</cfif>

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
					<nav class="p-md-1 py-3" style="--bs-breadcrumb-divider: url(&##34;data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpath d='M2.5 0L1 1.5 3.5 4 1 6.5 2.5 8l4-4-4-4z' fill='%236c757d'/%3E%3C/svg%3E&##34;);" aria-label="breadcrumb">
						<ol class="breadcrumb m-0">
							<li class="breadcrumb-item">
								<a href="/products.cfm?categoryId=#urlEncodedFormat(variables.productInfo.data[1].categoryId)#" class="text-decoration-none">#variables.productInfo.data[1].categoryName#</a>
							</li>
							<li class="breadcrumb-item">
								<a href="/products.cfm?subCategoryId=#urlEncodedFormat(variables.productInfo.data[1].subCategoryId)#" class="text-decoration-none">#variables.productInfo.data[1].subCategoryName#</a>
							</li>
							<li class="breadcrumb-item active">
								#variables.productInfo.data[1].productName#
							</li>
						</ol>
					</nav>
					<h1 class="display-6">#variables.productInfo.data[1].productName#</h1>
					<p class="lead">#variables.productInfo.data[1].brandName#</p>
					<p class="h4 text-success">Rs. #variables.productInfo.data[1].price#</p>
					<p class="h6 text-secondary">Tax: #variables.productInfo.data[1].tax#%</p>
					<p class="mt-4">#variables.productInfo.data[1].description#</p>

					<!-- Action Buttons -->
					<div class="mt-4">
						<form method="post">
							<!--- Add to cart button --->
							<button type="submit" name="addToCart" class="btn btn-primary btn mr-3">
								<i class="fa-solid fa-cart-plus"></i>
								Add to Cart
							</button>

							<!---Buy now button --->
							<button type="submit" name="buyNow" class="btn btn-danger btn">
								<i class="fa-solid fa-bolt-lightning"></i>
								Buy Now
							</button>
						</form>
					</div>
				</div>
			</div>
		</div>
	</cfif>
</cfoutput>
