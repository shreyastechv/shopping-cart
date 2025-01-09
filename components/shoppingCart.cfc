<cffunction  name="login" returnType="struct">
	<cfargument  name="username">
	<cfargument  name="password">

	<cfset local.response = {}>

	<cfquery name="local.qryCheckUser">
		SELECT
			fldFirstName,
			fldLastName,
			fldRoleId,
			fldUserSaltString,
			fldHashedPassword
		FROM
			tblUser
		WHERE
			(fldEmail = <cfqueryparam value = "#trim(form.username)#" cfsqltype = "cf_sql_varchar">
			OR fldPhone = <cfqueryparam value = "#trim(form.username)#" cfsqltype = "cf_sql_varchar">)
			AND fldActive = 1
	</cfquery>

	<cfif local.qryCheckUser.recordCount>
		<cfif local.qryCheckUser.fldHashedPassword EQ hash(form.password & local.qryCheckUser.fldUserSaltString, "SHA-512", "UTF-8", 3)>
			<cfset session.isLoggedIn = true>
			<cfset session.userFullname = local.qryCheckUser.fldFirstName & " " & local.qryCheckUser.fldLastName>
			<cfset session.roleId = local.qryCheckUser.fldRoleId>
			Login successfull
		<cfelse>
			Wrong username or password
		</cfif>
	<cfelse>
		User does not exist
	</cfif>

	<cfreturn local.response>
</cffunction>