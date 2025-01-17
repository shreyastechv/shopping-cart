<!DOCTYPE html>
<html lang="en">
	<cfoutput>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>#application.pageTitle# - Shopping Cart</title>
			<link rel="icon" href="favicon.ico">
			<link href="assets/css/bootstrap.min.css" rel="stylesheet">
		</head>

		<body>
			<header class="header d-flex align-items-center justify-content-between fixed-top bg-success ps-2 pe-3">
				<a class="d-flex align-items-center text-decoration-none" href="/">
					<img class="p-2 me-2" src="assets/images/shopping-cart-logo.png" height="45" alt="Logo Image">
					<div class="text-white fw-semibold">SHOPPING CART</div>
				</a>
				<cfif structKeyExists(session, "roleId") AND session.roleId EQ 1>
					<a class="text-white text-decoration-none fs-4" href="adminDashboard.cfm">
						ADMIN DASHBOARD
					</a>
				</cfif>
				<nav class="d-flex align-items-center justify-content-between gap-4">
					<cfif structKeyExists(session, "userId")>
						<a class="text-white text-decoration-none" href="components/shoppingCart.cfc?method=logOut">
							<i class="fa-solid fa-right-from-bracket"></i>
							Logout
						</a>
					<cfelse>
						<cfif cgi.SCRIPT_NAME EQ "/signup.cfm">
							<a class="text-white text-decoration-none" href="login.cfm">
								<i class="fa-solid fa-right-from-bracket"></i>
								Log In
							</a>
						<cfelse>
							<a class="text-white text-decoration-none" href="signup.cfm">
								<i class="fa-solid fa-user"></i>
								Sign Up
							</a>
						</cfif>
					</cfif>
				</nav>
			</header>
	</cfoutput>
