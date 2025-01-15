<cfcomponent>
	<cfset this.name = "Shopping Cart">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
	<cfset this.dataSource = "shoppingCart">

	<cffunction name="onApplicationStart">
		<cfset application.productImageDirectory = expandPath("assets/images/productImages")>
		<cfset application.shoppingCart = createObject("component", "components.shoppingCart")>
	</cffunction>

	<cffunction name="onRequestStart">
		<cfargument type="String" name="targetPage" required=true>

		<!--- Map pages to title and script path --->
		<cfset pageDetailsMapping = {
			"/shopping-cart/login.cfm": {
				"pageTitle": "Log In",
				"scriptPath": "assets/js/login.js"
			},
			"/shopping-cart/adminDashboard.cfm": {
				"pageTitle": "Admin Dashboard",
				"scriptPath": "assets/js/adminDashboard.js"
			},
			"/shopping-cart/subCategory.cfm": {
				"pageTitle": "Sub Category",
				"scriptPath": "assets/js/subCategory.js"
			},
			"/shopping-cart/productEdit.cfm": {
				"pageTitle": "Product Edit",
				"scriptPath": "assets/js/productEdit.js"
			}
		}>

		<!--- Set page title and script tag path dynamically --->
		<cfif StructKeyExists(pageDetailsMapping, arguments.targetPage)>
			<cfset application.pageTitle = pageDetailsMapping[arguments.targetPage]["pageTitle"]>
			<cfset application.scriptPath = pageDetailsMapping[arguments.targetPage]["scriptPath"]>
		<cfelse>
			<cfset application.pageTitle = "Title">
			<cfset application.scriptPath = "assets/js/dummy.js">
		</cfif>

		<!--- Define publically viewable pages --->
		<cfset local.publicPages = ["/login.cfm"]>

		<!--- Handle page restrictions --->
		<cfif arrayFindNoCase(local.publicPages, arguments.targetPage)>
			<cfreturn true>
		<cfelseif structKeyExists(session, "userId")>
			<cfif arguments.targetPage EQ "/login.cfm">
				<cflocation url="adminDashboard.cfm" addToken="false">
			<cfelse>
				<cfreturn true>
			</cfif>
		<cfelse>
			<cflocation url="/login.cfm" addToken="false">
		</cfif>
	</cffunction>
</cfcomponent>
