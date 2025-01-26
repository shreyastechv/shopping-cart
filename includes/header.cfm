<!DOCTYPE html>
<html lang="en">
	<cfoutput>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>#application.pageTitle# - Shopping Cart</title>
			<link rel="icon" href="favicon.ico">
			<link href="/assets/css/bootstrap.min.css" rel="stylesheet">
			<link href="/assets/css/header.css" rel="stylesheet">
			<link href="#application.cssPath#" rel="stylesheet">
			<script src="/assets/js/header.js"></script>
		</head>

		<!--- Variables --->
		<cfset variables.qryCategories = application.shoppingCart.getCategories()>

		<body>
			<header class="header d-flex align-items-center justify-content-between sticky-top bg-success shadow px-2">
				<a class="d-flex align-items-center text-decoration-none" href="/">
					<img class="p-2 me-2" src="assets/images/shopping-cart-logo.png" height="45" alt="Logo Image">
					<div class="text-white fw-semibold">SHOPPING CART</div>
				</a>
				<cfif structKeyExists(session, "roleId") AND session.roleId EQ 1>
					<a class="text-white text-decoration-none fs-4" href="/adminDashboard.cfm">
						ADMIN DASHBOARD
					</a>
				<cfelse>
					<form class="d-flex p-1 w-50" method="get" action="/products.cfm">
						<input class="form-control me-2" type="search" name="search" placeholder="Search">
						<button class="btn btn-outline-light" type="submit">Search</button>
					</form>
				</cfif>
				<nav class="d-flex align-items-center justify-content-between gap-4">
					<!--- Cart Button --->
					<button type="button" class="btn btn-outline-light btn-sm position-relative" onclick="location.href='/cart.cfm'">
						<i class="fa-solid fa-cart-shopping"></i>
						Cart
						<cfif structKeyExists(session, "userId")>
							<span class="position-absolute top-0 start-100 translate-middle badge rounded-pill text-bg-light">
								#structCount(session.cart)#
							<span class="visually-hidden">products in cart</span></span>
						</cfif>
					</button>

					<cfif structKeyExists(session, "userId")>
						<button class="btn text-white text-decoration-none" onclick="logOut()">
							<i class="fa-solid fa-right-from-bracket"></i>
							Logout
						</button>
					<cfelse>
						<cfif cgi.SCRIPT_NAME EQ "/login.cfm">
							<a class="text-white text-decoration-none" href="/signup.cfm">
								<i class="fa-solid fa-user"></i>
								Sign Up
							</a>
						<cfelse>
							<a class="text-white text-decoration-none" href="/login.cfm">
								<i class="fa-solid fa-right-from-bracket"></i>
								Log In
							</a>
						</cfif>
					</cfif>
				</nav>
			</header>

			<!--- Category - SubCategory Dropdown --->
			<div class="border-bottom border-success-subtle shadow-sm">
				<cfif (structKeyExists(session, "roleId") EQ false) OR (session.roleId EQ 2)>
					<cfif NOT arrayContainsNoCase(["/login.cfm", "/signup.cfm"], cgi.SCRIPT_NAME)>
						<nav class="navbar navbar-expand-lg bg-body-tertiary">
							<div class="container-fluid">
								<ul class="navbar-nav w-100 d-flex justify-content-evenly">
									<cfloop query="variables.qryCategories">
										<!--- Encrypt Category ID URL param --->
										<cfset variables.encryptedCategoryId = application.shoppingCart.encryptUrlParam(variables.qryCategories.fldCategory_Id)>

										<li class="nav-item dropdown">
											<a class="nav-link" href="/products.cfm?categoryId=#variables.encryptedCategoryId#">
												#variables.qryCategories.fldCategoryName#
											</a>
											<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories(
												categoryId = variables.qryCategories.fldCategory_Id
											)>
											<cfif variables.qrySubCategories.recordCount>
												<ul class="dropdown-menu">
													<cfloop query="variables.qrySubCategories">
														<!--- Encrypt SubCategory ID URL param --->
														<cfset variables.encryptedSubCategoryId = application.shoppingCart.encryptUrlParam(variables.qrySubCategories.fldSubCategory_Id)>

														<li><a class="dropdown-item" href="/products.cfm?subCategoryId=#variables.encryptedSubCategoryId#">#variables.qrySubCategories.fldSubCategoryName#</a></li>
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
