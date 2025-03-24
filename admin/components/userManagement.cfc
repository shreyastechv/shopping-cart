<cfcomponent displayname="User Management" hint="Includes functions that help in admin login and logout.">
	<cffunction name="logOut" access="remote" returnType="void">
		<!--- Clear session --->
		<cfset structClear(session)>
	</cffunction>
</cfcomponent>
