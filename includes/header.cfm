<!--- Variables used in this page --->
<cfparam name="application.cssDirectory" type="string" default="">
<cfparam name="application.scriptDirectory" type="string" default="">
<cfparam name="url.search" default="">
<cfparam name="url.productId" default="">

<!DOCTYPE html>
<html lang="en">
	<cfoutput>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>#request.pageTitle# - Shopping Cart</title>
			<link rel="icon" href="favicon.ico">
			<link href="#application.cssDirectory#bootstrap.min.css" rel="stylesheet">
			<link href="#application.cssDirectory#sweetalert2.min.css" rel="stylesheet">
			<link href="#application.cssDirectory#header.css" rel="stylesheet">
			<cfif len(trim(request.cssPath))>
				<link href="#application.cssDirectory&request.cssPath#" rel="stylesheet">
			</cfif>
			<script src="#application.scriptDirectory#jquery-3.7.1.min.js"></script>
			<script src="#application.scriptDirectory#sweetalert2.all.min.js"></script>
			<script src="#application.scriptDirectory#header.js"></script>
		</head>

		<!--- Variables --->
		<cfset variables.categories = application.dataFetch.getCategories()>
		<cfset variables.subCategories = application.dataFetch.getSubCategories()>
		<cfset variables.catToSubcatMapping = {}>

		<!--- Loop through sub categories --->
		<cfloop array="#variables.subCategories.data#" item="item">
			<!--- If category id does not exist in mapping, create it --->
			<cfif NOT structKeyExists(variables.catToSubcatMapping, item.categoryId)>
				<cfset variables.catToSubcatMapping[item.categoryId] = []>
			</cfif>

			<!--- Map sub category info to category id --->
			<cfset arrayAppend(variables.catToSubcatMapping[item.categoryId], {
				"subCategoryId" = item.subCategoryId,
				"subCategoryName" = item.subCategoryName
			})>
		</cfloop>

		<body class="overflow-x-hidden overflow-y-scroll">
			<header class="header d-flex align-items-center justify-content-between sticky-top bg-success shadow px-2 py-1">
				<button class="navbar-toggler d-flex fs-5 p-2 d-lg-none" type="button" data-bs-toggle="collapse" data-bs-target="##navbarContent">
					<i class="fa-solid fa-bars"></i>
				</button>
				<a class="d-flex align-items-center text-decoration-none" href="/">
					<img class="p-1 me-2" src="#application.imageDirectory#shopping-cart-logo.png" height="35" alt="Logo Image">
					<div class="text-white fw-semibold">SHOPPING CART</div>
				</a>
				<form class="d-flex p-0 w-50" method="get" action="/products.cfm">
					<input class="form-control form-control-sm me-2" type="search" id="search" name="search" value="#url.search#" placeholder="Search for products, categories, sub categories, brands ..." onblur="this.value = this.value.trim()">
					<button class="btn btn-sm btn-outline-light" type="submit">Search</button>
				</form>
				<nav class="d-flex align-items-center justify-content-between gap-4 px-2">
					<!--- Profile Button --->
					<button type="button" class="btn btn-sm btn-outline-light" onclick="location.href='/profile.cfm'">
						<i class="fa-regular fa-circle-user"></i>
						Profile
					</button>

					<!--- Cart Button --->
					<button type="button" class="btn btn-sm btn-outline-light position-relative px-2" onclick="location.href='/cart.cfm'">
						<i class="fa-solid fa-cart-shopping"></i>
						Cart
						<!--- Hide cart count for non-logged in users --->
						<cfif structKeyExists(session, "cart")>
							<span class="position-absolute top-0 start-100 translate-middle badge rounded-pill text-bg-light mt-1">
								<span id="cartCount">#structCount(session.cart.items)#</span>
							</span>
						</cfif>
					</button>

					<cfif structKeyExists(session, "userId")>
						<button class="btn btn-sm text-white text-decoration-none" onclick="logOut()">
							<i class="fa-solid fa-right-from-bracket"></i>
							Logout
						</button>
					<cfelse>
						<cfif cgi.SCRIPT_NAME EQ "/login.cfm">
							<a class="text-white text-decoration-none" href="/signup.cfm?productId=#urlEncodedFormat(url.productId)#">
								<i class="fa-solid fa-user"></i>
								Sign Up
							</a>
						<cfelse>
							<a class="text-white text-decoration-none" href="/login.cfm?productId=#urlEncodedFormat(url.productId)#">
								<i class="fa-solid fa-right-from-bracket"></i>
								Log In
							</a>
						</cfif>
					</cfif>
				</nav>
			</header>

			<!--- Category - SubCategory Dropdown --->
			<div class="border-bottom border-success-subtle shadow-sm">
				<nav class="navbar navbar-expand-lg navbar-light bg-light py-0">
					<div class="container-fluid">
						<div class="collapse navbar-collapse" id="navbarContent">
							<ul class="navbar-nav w-100 d-flex justify-content-evenly flex-wrap">
								<cfloop array="#variables.categories.data#" item="categoryItem" index="i">
									<cfset variables.encodedCategoryId = urlEncodedFormat(categoryItem.categoryId)>
									<cfif i LT 8>
										<li class="nav-item dropdown categoryDropdown">
											<a class="nav-link dropdown-toggle" href="/products.cfm?categoryId=#variables.encodedCategoryId#">
												#categoryItem.categoryName#
											</a>
											<cfif structKeyExists(variables.catToSubcatMapping, categoryItem.categoryId)>
												<ul class="dropdown-menu subCategoryDropdown mt-0">
													<cfloop array="#variables.catToSubcatMapping[categoryItem.categoryId]#" item="subCategoryItem">
														<cfset variables.encodedSubCategoryId = urlEncodedFormat(subCategoryItem.subCategoryId)>
														<li><a class="dropdown-item" href="/products.cfm?subCategoryId=#variables.encodedSubCategoryId#">#subCategoryItem.subCategoryName#</a></li>
													</cfloop>
												</ul>
											</cfif>
										</li>
									<cfelse>
										<cfif i EQ 8>
											<li class="nav-item dropdown categoryDropdown">
												<button class="nav-link dropdown-toggle" data-bs-toggle="dropdown">
													More
												</button>
												<ul class="dropdown-menu dropdown-menu-end subCategoryDropdown">
										</cfif>
												<li class="dropdown-submenu">
													<a class="dropdown-item" href="/products.cfm?categoryId=#variables.encodedCategoryId#">
														<i class="fa-solid fa-caret-left"></i>
														#categoryItem.categoryName#
													</a>
													<cfif structKeyExists(variables.catToSubcatMapping, categoryItem.categoryId)>
														<ul class="dropdown-menu">
															<cfloop array="#variables.catToSubcatMapping[categoryItem.categoryId]#" item="subCategoryItem">
																<cfset variables.encodedSubCategoryId = urlEncodedFormat(subCategoryItem.subCategoryId)>
																<li><a class="dropdown-item" href="/products.cfm?subCategoryId=#variables.encodedSubCategoryId#">#subCategoryItem.subCategoryName#</a></li>
															</cfloop>
														</ul>
													</cfif>
												</li>
										<cfif i EQ arrayLen(variables.categories.data)>
												</ul>
											</li>
										</cfif>
									</cfif>
								</cfloop>
							</ul>
						</div>
					</div>
				</nav>
			</div>
		<!--- Body tag is not closed since this is header file --->
	</cfoutput>
