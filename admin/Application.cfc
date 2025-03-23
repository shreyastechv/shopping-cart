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
			"/admin/login.cfm": {
				"pageTitle": "Admin Log In",
				"cssPath": "",
				"scriptPath": ["login.js"]
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
		<cfif structKeyExists(url, "reload") AND url.reload EQ 1
			AND structKeyExists(session, "roleId") AND session.roleId EQ 1
		>
			<cfset onApplicationStart()>
		</cfif>

		<!--- Define page types --->
		<cfset local.initialPages = ["/admin/login.cfm"]>
		<cfset local.adminPages = ["/admin/adminDashboard.cfm", "/admin/subCategory.cfm", "/admin/productEdit.cfm", "/components/productManagement.cfc"]>

		<!--- Handle page restrictions --->
		<cfif arrayFindNoCase(local.initialPages, arguments.targetPage)>
			<cfif structKeyExists(session, "roleId")>
				<cfif session.roleId EQ 1>
					<cflocation url="/admin/adminDashboard.cfm" addToken="false">
				<cfelse>
					<cflocation url="/" addToken="false">
				</cfif>
			</cfif>
		<cfelseif arrayFindNoCase(local.adminPages, arguments.targetPage)>
			<cfif structKeyExists(session, "roleId") AND session.roleId EQ 1>
				<cfreturn true>
			<cfelse>
				<cflocation url="/admin/login.cfm?redirect=#arguments.targetPage#" addToken="false">
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
</cfcomponent>
