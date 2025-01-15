<cfcomponent>
	<cfset this.name = "Shopping Cart">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
	<cfset this.dataSource = "shoppingCart">

	<cffunction name="onRequestStart">
		<cfargument type="String" name="targetPage" required=true>

		<cfset local.publicPages = ["/login.cfm"]>

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
