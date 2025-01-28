<!--- Redirect to login page if user is not logged in --->
<cfif NOT structKeyExists(session, "userId")>
	<cflocation url="/login.cfm?redirect=cart.cfm" addToken="no">
</cfif>
