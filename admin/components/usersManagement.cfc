<cfcomponent displayname="User Management" hint="Includes functions that help in user login, signup, modify profile, etc.">
	<cffunction name="logOut" access="remote" returnType="void">
		<!--- Clear session --->
		<cfset structClear(session)>
	</cffunction>
</cfcomponent>