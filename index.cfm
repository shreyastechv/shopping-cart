<cfoutput>
	<!--- Define variables --->
	<cfparam name="variables.sliderImages.data" default="#arrayNew(1)#">
	<cfparam name="variables.randomProducts.data" default="#arrayNew(1)#">

	<!--- Get Data --->
	<cfset variables.sliderImages =  application.dataFetch.getSliderImages(pageName = "home")>
	<cfset variables.randomProducts = application.dataFetch.getProducts(
		random = 1,
		limit = 12
	)>

	<cfif arrayLen(variables.sliderImages.data)>
		<div id="homePageCarousel" class="carousel slide" data-bs-ride="carousel" data-bs-interval="1700">
			<!--- Carousel indicators --->
			<div class="carousel-indicators">
				<cfloop array="#variables.sliderImages.data#" item="item" index="index">
					<button type="button" data-bs-target="##homePageCarousel" data-bs-slide-to="#index-1#" class="#(index EQ 1 ? 'active' : '')#"
						aria-current="true" aria-label="Slide 1"></button>
				</cfloop>
			</div>

			<!--- Carousel images --->
			<div class="carousel-inner">
				<cfloop array="#variables.sliderImages.data#" item="item" index="index">
					<div class="carousel-item #(index EQ 1 ? 'active' : '')#">
						<img src="#application.imageDirectory & item.imageFile#" class="d-block w-100" alt="Home page slider image - #index#">
					</div>
				</cfloop>
			</div>

			<!--- Next Previous controls --->
			<button class="carousel-control-prev" type="button" data-bs-target="##homePageCarousel"
				data-bs-slide="prev">
				<span class="carousel-control-prev-icon" aria-hidden="true"></span>
				<span class="visually-hidden">Previous</span>
			</button>
			<button class="carousel-control-next" type="button" data-bs-target="##homePageCarousel"
				data-bs-slide="next">
				<span class="carousel-control-next-icon" aria-hidden="true"></span>
				<span class="visually-hidden">Next</span>
			</button>
		</div>
	</cfif>

	<!--- Random Products --->
	<cfif arrayLen(variables.randomProducts.data)>
		<div class="h5 px-3 pt-3 pb-1">Exciting New Products</div>
		<cf_productlist products="#variables.randomProducts.data#">
	</cfif>
</cfoutput>
