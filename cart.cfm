<cfif NOT structKeyExists(session, "userId")>
	<cflocation  url="/login.cfm" addToken="no">
</cfif>