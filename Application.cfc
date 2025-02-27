<cfcomponent>
	<cfset this.name = "Shopping Cart">
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
		<cfset application.cartManagement = createObject("component", "components.cartManagement")>
		<cfset application.commonFunctions = createObject("component", "components.commonFunctions")>
		<cfset application.dataFetch = createObject("component", "components.dataFetch")>
		<cfset application.productManagement = createObject("component", "components.productManagement")>
		<cfset application.userManagement = createObject("component", "components.userManagement")>

		<!--- Map pages to title, css and script path --->
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
			"/adminDashboard.cfm": {
				"pageTitle": "Admin Dashboard",
				"cssPath": "",
				"scriptPath": ["adminDashboard.js"]
			},
			"/subCategory.cfm": {
				"pageTitle": "Sub Category",
				"cssPath": "",
				"scriptPath": ["subCategory.js"]
			},
			"/productEdit.cfm": {
				"pageTitle": "Product Edit",
				"cssPath": "",
				"scriptPath": ["productEdit.js"]
			}
		}>

		<cfreturn true>
	</cffunction>

	<cffunction name="onMissingTemplate" returnType="void">
		<cfargument name="targetPage" type="string" required=true>

		<cflog type="error" text="Missing template: #arguments.targetPage#">
		<cflocation url="/404.cfm" addToken="false">
	</cffunction>

	<cffunction name="onError" returnType="void">
		<cfargument name="exception" required=true>
		<cfargument name="eventName" type="string" required=true>

		<!--- Display an error message if there is a page context --->
		<cfif NOT (arguments.eventName IS "onSessionEnd") OR
			(arguments.eventName IS "onApplicationEnd")>

			<cflocation url="/error.cfm?eventName=#arguments.eventName#" addToken="false">
		</cfif>
	</cffunction>

	<cffunction name="onRequestStart" returnType="boolean">
		<cfargument name="targetPage" type="string" required=true>

		<!--- Hot reloading application if required --->
		<cfif structKeyExists(url, "reload") AND url.reload EQ 1>
			<cfset onApplicationStart()>
		</cfif>

		<!--- Define page types --->
		<cfset local.initialPages = ["/login.cfm", "/signup.cfm"]>
		<cfset local.loginUserPages = ["/profile.cfm", "/cart.cfm", "/checkout.cfm", "/orders.cfm"]>
		<cfset local.adminPages = ["/adminDashboard.cfm", "/subCategory.cfm", "/productEdit.cfm"]>

		<!--- Handle page restrictions --->
		<cfif arrayFindNoCase(local.initialPages, arguments.targetPage)>
			<cfif structKeyExists(session, "roleId")>
				<cfif session.roleId EQ 1>
					<cflocation url="/adminDashboard.cfm" addToken="false">
				<cfelse>
					<cflocation url="/" addToken="false">
				</cfif>
			</cfif>
		<cfelseif arrayFindNoCase(local.adminPages, arguments.targetPage)>
			<cfif structKeyExists(session, "roleId") AND session.roleId EQ 1>
				<cfreturn true>
			<cfelse>
				<cflocation url="/login.cfm?redirect=#arguments.targetPage#" addToken="false">
			</cfif>
		<cfelseif arrayFindNoCase(local.loginUserPages, arguments.targetPage)>
			<cfif NOT structKeyExists(session, "roleId")>
				<cflocation url="/login.cfm?redirect=#arguments.targetPage#" addToken="false">
			</cfif>
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

	<cffunction name="onSessionEnd" returnType="void">
		<cfset structClear(session)>
	</cffunction>
</cfcomponent>
