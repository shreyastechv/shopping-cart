<cfcomponent>
	<cfset this.name = "Shopping Cart">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
	<cfset this.dataSource = "shoppingCart">

	<cffunction name="onApplicationStart">
		<cfset application.productImageDirectory = expandPath("assets/images/productImages")>
		<cfset application.shoppingCart = createObject("component", "components.shoppingCart")>
	</cffunction>

	<cffunction name="onMissingTemplate">
		<cfargument name="targetPage" type="string" required=true>
		<cflog type="error" text="Missing template: #Arguments.targetPage#">
		<cfoutput>
			<h3>#Arguments.targetPage# could not be found.</h3>
			<p>You requested a non-existent ColdFusion page.<br />
			Please check the URL.</p>
		</cfoutput>
	</cffunction>

	<cffunction name="onError">
		<cfargument name="Exception" required=true>
		<cfargument type="String" name="EventName" required=true>

		<!--- Display an error message if there is a page context. --->
		<cfif NOT (Arguments.EventName IS "onSessionEnd") OR
			(Arguments.EventName IS "onApplicationEnd")>
			<cfoutput>
				<h2>An unexpected error occurred.</h2>
				<p>Please provide the following information to technical support:</p>
				<p>Error Event: #Arguments.EventName#</p>
			</cfoutput>
		</cfif>
	</cffunction>

	<cffunction name="onRequestStart">
		<cfargument name="targetPage" type="string" required=true>

		<!--- Map pages to title and script path --->
		<cfset pageDetailsMapping = {
			"/login.cfm": {
				"pageTitle": "Log In",
				"scriptPath": "assets/js/login.js"
			},
			"/adminDashboard.cfm": {
				"pageTitle": "Admin Dashboard",
				"scriptPath": "assets/js/adminDashboard.js"
			},
			"/subCategory.cfm": {
				"pageTitle": "Sub Category",
				"scriptPath": "assets/js/subCategory.js"
			},
			"/productEdit.cfm": {
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

		<!--- Define page types --->
		<cfset local.initialPages = ["/login.cfm", "/signup.cfm"]>
		<cfset local.privatePages = ["/adminDashboard.cfm", "/subCategory.cfm", "/productEdit.cfm"]>

		<!--- Handle page restrictions --->
		<cfif arrayFindNoCase(local.initialPages, arguments.targetPage)>
			<cfif structKeyExists(session, "roleId") AND session.roleId>
				<cfif session.roleId EQ 1>
					<cflocation url="/adminDashboard.cfm" addToken="false">
				<cfelse>
					<cflocation url="/home.cfm" addToken="false">
				</cfif>
			</cfif>
			<cfreturn true>
		<cfelseif arrayFindNoCase(local.privatePages, arguments.targetPage)>
			<cfif structKeyExists(session, "roleId") AND session.roleId EQ 1>
				<cfreturn true>
			</cfif>
			<cflocation url="/home.cfm" addToken="false">
		</cfif>
	</cffunction>

	<cffunction name="onRequest">
		<cfargument name="targetPage" type="String" required=true>

		<!--- Common Header file --->
		<cfinclude  template="/includes/header.cfm">

		<!--- Requested page content --->
		<cfinclude  template="#arguments.targetPage#">

		<!--- Common Footer file --->
		<cfinclude  template="/includes/footer.cfm">
	</cffunction>
</cfcomponent>
