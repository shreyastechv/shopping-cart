<!--- Variables used in this page --->
<cfparam name="application.cssDirectory" type="string" default="">
<cfparam name="application.scriptDirectory" type="string" default="">
<cfparam name="url.search" default="">

<!DOCTYPE html>
<html lang="en">
	<cfoutput>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>#request.pageTitle# - Shopping Cart</title>
			<link rel="icon" href="favicon.ico">
			<link href="#application.cssDirectory#bootstrap.min.css" rel="stylesheet">
			<link href="#application.cssDirectory#header.css" rel="stylesheet">
			<cfif len(trim(request.cssPath))>
				<link href="#application.cssDirectory&request.cssPath#" rel="stylesheet">
			</cfif>
			<script src="#application.scriptDirectory#header.js"></script>
		</head>

		<!--- Variables --->
		<cfset variables.categories = application.shoppingCart.getCategories()>
		<cfset variables.qrySubCategories = application.shoppingCart.getSubCategories()>
		<cfset variables.catToSubcatMapping = {}>

		<!--- Loop through sub categories --->
		<cfloop query="variables.qrySubCategories">
			<!--- If category id does not exist in mapping, create it --->
			<cfif NOT structKeyExists(variables.catToSubcatMapping, variables.qrySubCategories.fldCategoryId)>
				<cfset variables.catToSubcatMapping[variables.qrySubCategories.fldCategoryId] = []>
			</cfif>

			<!--- Map sub category info to category id --->
			<cfset arrayAppend(variables.catToSubcatMapping[variables.qrySubCategories.fldCategoryId], {
				"subCategoryId" = variables.qrySubCategories.fldSubCategory_Id,
				"subCategoryName" = variables.qrySubCategories.fldSubCategoryName
			})>
		</cfloop>

		<body>
			<header class="header d-flex align-items-center justify-content-between sticky-top bg-success shadow px-2 py-1">
				<a class="d-flex align-items-center text-decoration-none" href="/">
					<img class="p-2 me-2" src="#application.imageDirectory#shopping-cart-logo.png" height="45" alt="Logo Image">
					<div class="text-white fw-semibold">SHOPPING CART</div>
				</a>
				<cfif structKeyExists(session, "roleId") AND session.roleId EQ 1>
					<a class="text-white text-decoration-none fs-4" href="/adminDashboard.cfm">
						ADMIN DASHBOARD
					</a>
				<cfelse>
					<form class="d-flex p-1 w-50" method="get" action="/products.cfm">
						<input class="form-control me-2" type="search" name="search" value="#url.search#" placeholder="Search" onblur="this.value = this.value.trim()">
						<button class="btn btn-outline-light" type="submit">Search</button>
					</form>
				</cfif>
				<nav class="d-flex align-items-center justify-content-between gap-4">
					<!--- Profile Button --->
					<button type="button" class="btn btn-outline-light" onclick="location.href='/profile.cfm'">
						<i class="fa-regular fa-circle-user"></i>
						Profile
					</button>

					<!--- Cart Button --->
					<button type="button" class="btn btn-outline-light position-relative" onclick="location.href='/cart.cfm'">
						<i class="fa-solid fa-cart-shopping"></i>
						Cart
						<!--- Hide cart count for non-logged in users --->
						<cfif structKeyExists(session, "cart")>
							<span class="position-absolute top-0 start-100 translate-middle badge rounded-pill text-bg-light">
								<span id="cartCount">#structCount(session.cart)#</span>
							</span>
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
				<nav class="navbar navbar-expand-lg bg-body-tertiary">
					<div class="container-fluid">
						<ul class="navbar-nav w-100 d-flex justify-content-evenly">
							<cfloop array="#variables.categories.data#" item="item">
								<!--- Encrypt Category ID URL param --->
								<cfset variables.encryptedCategoryId = application.shoppingCart.encryptUrlParam(item.categoryId)>
								<cfset variables.encodedCategoryId  = urlEncodedFormat(variables.encryptedCategoryId)>

								<li class="nav-item dropdown">
									<a class="nav-link" href="/products.cfm?categoryId=#variables.encodedCategoryId#">
										#item.categoryName#
									</a>
									<cfif structKeyExists(variables.catToSubcatMapping, item.categoryId)>
										<ul class="dropdown-menu">
											<cfloop array="#variables.catToSubcatMapping[item.categoryId]#" item="variables.subCategory">
												<!--- Encrypt SubCategory ID URL param --->
												<cfset variables.encryptedSubCategoryId = application.shoppingCart.encryptUrlParam(variables.subCategory.subCategoryId)>
												<cfset variables.encodedSubCategoryId  = urlEncodedFormat(variables.encryptedSubCategoryId)>

												<li><a class="dropdown-item" href="/products.cfm?subCategoryId=#variables.encodedSubCategoryId#">#variables.subCategory.subCategoryName#</a></li>
											</cfloop>
										</ul>
									</cfif>
								</li>
							</cfloop>
						</ul>
					</div>
				</nav>
			</div>
		<!--- Body tag is not closed since this is header file --->
	</cfoutput>
