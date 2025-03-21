		<footer class="bg-dark text-light py-4 mt-auto">
			<div class="container">
				<div class="row">
					<!-- About Section -->
					<div class="col-md-4">
						<h5>About Us</h5>
						<p>We provide the best shopping experience with a wide range of products at the best prices.</p>
					</div>

					<!-- Quick Links -->
					<div class="col-md-4">
						<h5>Quick Links</h5>
						<ul class="list-unstyled">
							<li><a href="/" class="text-light text-decoration-none">Home</a></li>
							<li><a href="##" class="text-light text-decoration-none">Contact Us</a></li>
							<li><a href="/admin" class="text-light text-decoration-none">Admin Dashboard</a></li>
						</ul>
					</div>

					<!-- Contact Info -->
					<div class="col-md-4">
						<h5>Contact Us</h5>
						<a class="mb-0 text-light text-decoration-none" href="mailto:support@shoppingcart.com">Email: support@shoppingcart.com</a>
						<br>
						<a class="mb-0 text-light text-decoration-none" href="tel:9876543210">Phone: +91 9876543210</a>
						<div>
							<a href="##" class="text-light me-2"><i class="fab fa-facebook"></i></a>
							<a href="##" class="text-light me-2"><i class="fab fa-twitter"></i></a>
							<a href="##" class="text-light"><i class="fab fa-instagram"></i></a>
						</div>
					</div>
				</div>

				<!-- Copyright -->
				<div class="text-center mt-3">
					<p class="mb-0">&copy; <span id="year"></span> Shopping Cart. All rights reserved.</p>
				</div>
			</div>
		</footer>

		<cfoutput>
			<!--- Variables used in this page --->
			<cfparam name="application.productImageDirectory" type="string" default="./">
			<cfparam name="application.scriptDirectory" type="string" default="">
			<cfparam name="application.scriptPath" default="#arrayNew(1)#">

			<!--- Load common scripts --->
			<script src="#application.scriptDirectory#bootstrap.bundle.min.js"></script>
			<script src="#application.scriptDirectory#footer.js"></script>
			<script src="#application.scriptDirectory#validations.js"></script>

			<!--- Set js variables --->
			<script>
				var productImageDirectory = "#application.productImageDirectory#";
			</script>

			<!--- Load individual page-specific scripts --->
			<cfloop array="#request.scriptPath#" index="variables.script">
				<script src="#application.scriptDirectory&variables.script#"></script>
			</cfloop>
		</cfoutput>
	</body>
</html>
