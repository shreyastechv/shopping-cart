<cfset variables.randomProducts = application.shoppingCart.getProducts(
	random = 1,
	limit = 12
)>

<cfoutput>
	<!--- Main Content --->
	<div id="homePageCarousel" class="carousel slide" data-bs-ride="carousel" data-bs-interval="1700">
		<div class="carousel-indicators">
			<button type="button" data-bs-target="##homePageCarousel" data-bs-slide-to="0" class="active"
				aria-current="true" aria-label="Slide 1"></button>
			<button type="button" data-bs-target="##homePageCarousel" data-bs-slide-to="1"
				aria-label="Slide 2"></button>
			<button type="button" data-bs-target="##homePageCarousel" data-bs-slide-to="2"
				aria-label="Slide 3"></button>
			<button type="button" data-bs-target="##homePageCarousel" data-bs-slide-to="3"
				aria-label="Slide 3"></button>
			<button type="button" data-bs-target="##homePageCarousel" data-bs-slide-to="4"
				aria-label="Slide 3"></button>
		</div>
		<div class="carousel-inner">
			<!--- First Slide --->
			<div class="carousel-item active">
				<img src="#application.imageDirectory#homepage-slider-1.jpg" class="d-block w-100" alt="Slider Image 1">
			</div>

			<!--- Second Slide --->
			<div class="carousel-item">
				<img src="#application.imageDirectory#homepage-slider-2.jpg" class="d-block w-100" alt="Slider Image 2">
			</div>

			<!--- Third Slide --->
			<div class="carousel-item">
				<img src="#application.imageDirectory#homepage-slider-3.jpg" class="d-block w-100" alt="Slider Image 3">
			</div>

			<!--- Fourth Slide --->
			<div class="carousel-item">
				<img src="#application.imageDirectory#homepage-slider-4.jpg" class="d-block w-100" alt="Slider Image 4">
			</div>

			<!--- Fifth Slide --->
			<div class="carousel-item">
				<img src="#application.imageDirectory#homepage-slider-5.jpg" class="d-block w-100" alt="Slider Image 5">
			</div>
		</div>
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

	<!--- Random Products --->
	<div class="h2 px-2 pt-3 pb-1">Random Products</div>
	<cf_productlist products="#variables.randomProducts.data#">
</cfoutput>
