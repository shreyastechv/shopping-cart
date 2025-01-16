<!--- Login Logic --->
<cfif structKeyExists(form, "signupBtn")>
	<cfset variables.signupResult = application.shoppingCart.signup(
		firstName = form.firstName,
		lastName = form.lastName,
		email = form.email,
		phone = form.phone,
		password = form.password,
		confirmPassword = form.confirmPassword
	)>
	<cfif variables.signupResult.message EQ "Account Created Successfully">
		<cflocation url="adminDashboard.cfm" addToken="false">
	</cfif>
</cfif>

<!--- Main Content --->
<div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
	<div id="submitMsgSection" class="text-danger p-2">
		<cfif isDefined("variables.signupResult.message")>
			<cfoutput>#variables.signupResult.message#</cfoutput>
		</cfif>
	</div>
	<div class="row shadow-lg border-0 rounded-4 w-50 text-center">
		<div class="form-control flex-nowrap bg-white col-md-8 p-4 rounded-end-4">
			<div class="text-center mb-4">
				<h3 class="fw-semibold mt-3">SIGN UP</h3>
			</div>
			<form id="signupForm" name="loginForm" method="post" onsubmit="validateForm()">
				<div class="mb-3">
					<input type="text" class="form-control" id="firstName" name="firstName" placeholder="First name" autocomplete="given-name">
					<div id="firstNameError" class="error text-danger"></div>
				</div>
				<div class="mb-3">
					<input type="text" class="form-control" id="lastName" name="lastName" placeholder="Last name" autocomplete="family-name">
					<div id="lastNameError" class="error text-danger"></div>
				</div>
				<div class="mb-3">
					<input type="text" class="form-control" id="email" name="email" placeholder="Email" autocomplete="email">
					<div id="emailError" class="error text-danger"></div>
				</div>
				<div class="mb-3">
					<input type="text" class="form-control" id="phone" name="phone" placeholder="Phone" autocomplete="tel">
					<div id="phoneError" class="error text-danger"></div>
				</div>
				<div class="mb-3">
					<input type="password" class="form-control" id="password" name="password" placeholder="Password" autocomplete="new-password">
					<div id="passwordError" class="error text-danger"></div>
				</div>
				<div class="mb-3">
					<input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Confirm Password" autocomplete="new-password">
					<div id="confirmPasswordError" class="error text-danger"></div>
				</div>
				<button type="submit" id="signupBtn" name="loginBtn" class="btn btn-success w-100 rounded-pill">SIGN UP</button>
			</form>
			<div class="text-center mt-3">
				Already have an account? <a class="text-success text-decoration-none" href="signup.cfm">Login Here</a>
			</div>
		</div>
	</div>
</div>