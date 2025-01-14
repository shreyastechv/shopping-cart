<cfcomponent>
	<cfset this.name = "Shopping Cart">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
	<cfset this.dataSource = "shoppingCart">

	<cffunction name="onRequestStart">
		<cfargument type="String" name="targetPage" required=true>

		<cfset local.publicPages = ["/login.cfm"]>

		<cfif arrayFindNoCase(local.publicPages, arguments.targetPage) OR structKeyExists(session, "userId")>
			<cfreturn true>
		<cfelse>
			<cflocation url="login.cfm" addToken="false">
		</cfif>
	</cffunction>
</cfcomponent>
