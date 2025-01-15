<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Log In - Shopping Cart</title>
		<link rel="icon" href="favicon.ico">
		<link href="assets/css/bootstrap.min.css" rel="stylesheet">
    </head>

    <body>
		<!--- Login Logic --->
		<cfif structKeyExists(form, "loginBtn")>
			<cfinvoke
				component = "components.shoppingCart"
				method = "login"
				returnVariable = "loginResult"
				argumentCollection = "#form#"
			/>
			<cfif loginResult.message EQ "Login successfull">
				<cflocation url="adminDashboard.cfm" addToken="false">
			</cfif>
		</cfif>

		<!--- Header --->
		<cfinclude template = "includes/header.cfm">

		<!--- Main Content --->
        <div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
            <div id="submitMsgSection" class="text-danger p-2">
				<cfif isDefined("loginResult.message")>
					<cfoutput>#loginResult.message#</cfoutput>
				</cfif>
			</div>
            <div class="row shadow-lg border-0 rounded-4 w-50 text-center">
				<div class="form-control flex-nowrap bg-white col-md-8 p-4 rounded-end-4">
					<div class="text-center mb-4">
						<h3 class="fw-semibold mt-3">LOGIN</h3>
					</div>
					<form id="loginForm" name="loginForm" method="post" onsubmit="return validateForm()">
						<div class="mb-3">
							<input type="text" class="form-control" id="userInput" name="userInput" placeholder="Email or Phone Number" autocomplete="username">
							<div id="userInputError" class="error text-danger"></div>
						</div>
						<div class="mb-3">
							<input type="password" class="form-control" id="password" name="password" placeholder="Password">
							<div id="passwordError" class="error text-danger"></div>
						</div>
						<button type="submit" id="loginBtn" name="loginBtn" class="btn btn-success w-100 rounded-pill">LOGIN</button>
					</form>
					<div class="text-center mt-3">
						Don't have an account? <a class="text-success text-decoration-none" href="signup.cfm">Register Here</a>
					</div>
				</div>
            </div>
        </div>
		<cfinclude template="includes/scripts.cfm">
		<script src="assets/js/login.js"></script>
    </body>
</html>
