<cfcomponent>
	<cfset this.name = "Shopping Cart Admin Section">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
	<cfset this.dataSource = "shoppingCart">
	<cfset this.customTagPaths = expandPath("/customTags")>

	<cffunction name="onApplicationStart" returnType="boolean">
		<cfset application.cssDirectory = "/assets/css/">
		<cfset application.scriptDirectory = "/assets/js/">
		<cfset application.imageDirectory = "/assets/images/">
		<cfset application.productImageDirectory = "/assets/images/productImages/">
		<cfset application.secretKey = "xpzpO2awP8KM+/nk1vmmFA==">

		<!--- Create component objects --->
		<cfset application.userManagement = createObject("component", "admin.components.userManagement")>
		<cfset application.dataFetch = createObject("component", "admin.components.dataFetch")>
		<cfset application.productManagement = createObject("component", "admin.components.productManagement")>
		<cfset application.commonFunctions = createObject("component", "admin.components.commonFunctions")>

		<cfset application.pageDetailsMapping = {
			"/index.cfm": {
				"pageTitle": "Home Page",
				"cssPath": "index.css",
				"scriptPath": []
			},
			"/profile.cfm": {
				"pageTitle": "User Profile",
				"cssPath": "",
				"scriptPath": ["profile.js", "addAddressBtn.js"]
			},
			"/products.cfm": {
				"pageTitle": "Product Listing",
				"cssPath": "products.css",
				"scriptPath": ["products.js"]
			},
			"/productPage.cfm": {
				"pageTitle": "Product Page",
				"cssPath": "",
				"scriptPath": []
			},
			"/cart.cfm": {
				"pageTitle": "Cart Page",
				"cssPath": "",
				"scriptPath": ["cartProductList.js"]
			},
			"/checkout.cfm": {
				"pageTitle": "Order Summary",
				"cssPath": "",
				"scriptPath": ["checkout.js", "cartProductList.js", "addAddressBtn.js"]
			},
			"/orders.cfm": {
				"pageTitle": "Orders",
				"cssPath": "",
				"scriptPath": ["orders.js"]
			},
			"/login.cfm": {
				"pageTitle": "Log In",
				"cssPath": "",
				"scriptPath": ["login.js"]
			},
			"/signup.cfm": {
				"pageTitle": "Sign Up",
				"cssPath": "",
				"scriptPath": ["signup.js"]
			},
			"/admin/adminDashboard.cfm": {
				"pageTitle": "Admin Dashboard",
				"cssPath": "",
				"scriptPath": ["adminDashboard.js"]
			},
			"/admin/subCategory.cfm": {
				"pageTitle": "Sub Category",
				"cssPath": "",
				"scriptPath": ["subCategory.js"]
			},
			"/admin/productEdit.cfm": {
				"pageTitle": "Product Edit",
				"cssPath": "",
				"scriptPath": ["productEdit.js"]
			}
		}>

		<cfreturn true>
	</cffunction>

	<cffunction name="onRequestStart" returnType="boolean">
		<cfargument name="targetPage" type="string" required=true>

		<!--- Hot reloading application if required --->
		<cfif structKeyExists(url, "reload") AND url.reload EQ 1>
			<cfset onApplicationStart()>
		</cfif>

		<cfreturn true>
	</cffunction>

	<cffunction name="onRequest" returnType="void">
		<cfargument name="targetPage" type="string" required=true>

		<!--- Set page title and script tag path dynamically --->
		<cfif StructKeyExists(application.pageDetailsMapping, arguments.targetPage)>
			<cfset request.pageTitle = application.pageDetailsMapping[arguments.targetPage]["pageTitle"]>
			<cfset request.scriptPath = application.pageDetailsMapping[arguments.targetPage]["scriptPath"]>
			<cfset request.cssPath = application.pageDetailsMapping[arguments.targetPage]["cssPath"]>
		<cfelse>
			<cfset request.pageTitle = "Title">
			<cfset request.scriptPath = []>
			<cfset request.cssPath = "">
		</cfif>

		<!--- Common Header file --->
		<cfinclude template="/includes/header.cfm">

		<!--- Requested page content --->
		<cfinclude template="#arguments.targetPage#">

		<!--- Common Footer file --->
		<cfinclude template="/includes/footer.cfm">
	</cffunction>
</cfcomponent>