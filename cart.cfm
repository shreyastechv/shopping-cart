<cfif NOT structKeyExists(session, "userId")>
	<cflocation url="/login.cfm?redirect=cart.cfm" addToken="no">
</cfif>