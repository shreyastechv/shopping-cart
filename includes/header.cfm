<!DOCTYPE html>
<html lang="en">
	<cfoutput>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>#application.pageTitle# - Shopping Cart</title>
			<link rel="icon" href="favicon.ico">
			<link href="assets/css/bootstrap.min.css" rel="stylesheet">
			<link href="assets/css/header.css" rel="stylesheet">
			<link href="#application.cssPath#" rel="stylesheet">
			<script src="assets/js/header.js"></script>
		</head>

		<cfset variables.qryCategories = application.shoppingCart.getCategories()>

		<body>
			<header class="header d-flex align-items-center justify-content-between sticky-top bg-success ps-2 pe-3">
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
						<button class="btn text-white text-decoration-none" onclick="logOut()">
							<i class="fa-solid fa-right-from-bracket"></i>
							Logout
						</button>
					<cfelse>
						<cfif cgi.SCRIPT_NAME EQ "/login.cfm">
							<a class="text-white text-decoration-none" href="signup.cfm">
								<i class="fa-solid fa-user"></i>
								Sign Up
							</a>
						<cfelse>
							<a class="text-white text-decoration-none" href="login.cfm">
								<i class="fa-solid fa-right-from-bracket"></i>
								Log In
							</a>
						</cfif>
					</cfif>
				</nav>
			</header>

			<div>
				<cfif (structKeyExists(session, "roleId") EQ false) OR structKeyExists(session, "roleId") AND session.roleId NEQ 1>
					<cfif NOT arrayContainsNoCase(["/login.cfm", "/signup.cfm"], cgi.SCRIPT_NAME)>
						<nav class="navbar navbar-expand-lg bg-body-tertiary">
							<div class="container-fluid">
								<ul class="navbar-nav w-100 d-flex justify-content-between">
									<cfloop query="variables.qryCategories">
										<li class="nav-item dropdown">
											<a class="nav-link" href="##" role="button" data-bs-toggle="dropdown"
												aria-expanded="false">
												#variables.qryCategories.fldCategoryName#
											</a>
											<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories(
												categoryId = variables.qryCategories.fldCategory_Id
											)>
											<cfif variables.qrySubCategories.recordCount>
												<ul class="dropdown-menu">
													<cfloop query="variables.qrySubCategories">
														<li><a class="dropdown-item" href="##">#variables.qrySubCategories.fldSubCategoryName#</a></li>
													</cfloop>
												</ul>
											</cfif>
										</li>
									</cfloop>
								</ul>
							</div>
						</nav>
					</cfif>
				</cfif>
			</div>
	</cfoutput>
