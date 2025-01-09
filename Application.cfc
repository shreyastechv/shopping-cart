<cfcomponent>
	<cfset this.name = "Shopping Cart">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
	<cfset this.dataSource = "shoppingCart">

<!--- 	<cffunction  name="onRequestStart" returnType="boolean">
		<cfargument type="String" name="targetPage" required=true>

		<cfif structKeyExists(session, "isLoggedIn")>
			<cflocation url="#arguments.targetPage#">
		<cfelse>
			<cflocation url="login.cfm" addToken="no">
		</cfif>
		<cfreturn true>
	</cffunction> --->
</cfcomponent>
