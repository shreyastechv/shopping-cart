<cfcomponent>
	<cfset this.name = "Shopping Cart">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
	<cfset this.dataSource = "shoppingCart">
	<cfset This.customTagPaths = expandPath("/customTags")>

	<cffunction name="onApplicationStart" returnType="boolean">
		<cfset application.productImageDirectory = "/assets/images/productImages/">
		<cfset application.shoppingCart = createObject("component", "components.shoppingCart")>

		<!--- Map pages to title, css and script path --->
		<cfset application.pageDetailsMapping = {
			"/index.cfm": {
				"pageTitle": "Home Page",
				"cssPath": "assets/css/index.css",
				"scriptPath": "assets/js/index.js"
			},
			"/login.cfm": {
				"pageTitle": "Log In",
				"cssPath": "",
				"scriptPath": "assets/js/login.js"
			},
			"/signup.cfm": {
				"pageTitle": "Sign Up",
				"cssPath": "",
				"scriptPath": "assets/js/signup.js"
			},
			"/adminDashboard.cfm": {
				"pageTitle": "Admin Dashboard",
				"cssPath": "",
				"scriptPath": "assets/js/adminDashboard.js"
			},
			"/subCategory.cfm": {
				"pageTitle": "Sub Category",
				"cssPath": "",
				"scriptPath": "assets/js/subCategory.js"
			},
			"/productEdit.cfm": {
				"pageTitle": "Product Edit",
				"cssPath": "",
				"scriptPath": "assets/js/productEdit.js"
			}
		}>

		<!--- Create images dir if not exists --->
		<cfif NOT directoryExists(expandPath(application.productImageDirectory))>
			<cfdirectory action="create" directory="#expandPath(application.productImageDirectory)#">
		</cfif>

		<cfreturn true>
	</cffunction>

	<cffunction name="onMissingTemplate" returnType="void">
		<cfargument name="targetPage" type="string" required=true>

		<cflog type="error" text="Missing template: #arguments.targetPage#">
		<cfoutput>
			<h3>#Arguments.targetPage# could not be found.</h3>
			<p>You requested a non-existent ColdFusion page.<br />
			Please check the URL.</p>
		</cfoutput>
	</cffunction>

	<!--- <cffunction name="onError" returnType="void">
		<cfargument name="exception" required=true>
		<cfargument name="eventName" type="string" required=true>

		<!--- Display an error message if there is a page context --->
		<cfif NOT (arguments.eventName IS "onSessionEnd") OR
			(arguments.eventName IS "onApplicationEnd")>

			<!--- Reset page content in case of error --->
			<cfcontent reset=true>

			<!--- Print error message --->
			<cfoutput>
				<h2>An unexpected error occurred.</h2>
				<p>Please provide the following information to technical support:</p>
				<p>Error Event: #arguments.eventName#</p>
			</cfoutput>
		</cfif>
	</cffunction> --->

	<cffunction name="onRequestStart" returnType="boolean">
		<cfargument name="targetPage" type="string" required=true>

		<!--- Hot reloading application if required --->
		<cfif structKeyExists(url, "reload") AND url.reload EQ 1>
			<cfset onApplicationStart()>
		</cfif>

		<!--- Set page title and script tag path dynamically --->
		<cfif StructKeyExists(application.pageDetailsMapping, arguments.targetPage)>
			<cfset application.pageTitle = application.pageDetailsMapping[arguments.targetPage]["pageTitle"]>
			<cfset application.scriptPath = application.pageDetailsMapping[arguments.targetPage]["scriptPath"]>
			<cfset application.cssPath = application.pageDetailsMapping[arguments.targetPage]["cssPath"]>
		<cfelse>
			<cfset application.pageTitle = "Title">
			<cfset application.scriptPath = "">
			<cfset application.cssPath = "">
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
					<cflocation url="/" addToken="false">
				</cfif>
			</cfif>
		<cfelseif arrayFindNoCase(local.privatePages, arguments.targetPage)>
			<cfif (NOT structKeyExists(session, "roleId")) OR (session.roleId NEQ 1)>
				<cflocation url="/" addToken="false">
			</cfif>
		</cfif>

		<cfreturn true>
	</cffunction>

	<cffunction name="onRequest" returnType="void">
		<cfargument name="targetPage" type="string" required=true>

		<!--- Common Header file --->
		<cfinclude  template="/includes/header.cfm">

		<!--- Requested page content --->
		<cfinclude  template="#arguments.targetPage#">

		<!--- Common Footer file --->
		<cfinclude  template="/includes/footer.cfm">
	</cffunction>
</cfcomponent>
