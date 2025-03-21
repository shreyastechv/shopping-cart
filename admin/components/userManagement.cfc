<cfcomponent displayname="User Management" hint="Includes functions that help in admin login and logout.">
	<cffunction name="login" access="public" returnType="struct">
		<cfargument name="userInput" type="string" required=true>
		<cfargument name="password" type="string" required=true>

		<cfset local.response = {
			"message" = ""
		}>

		<cftry>
			<!--- UserInput Validation --->
			<cfif len(trim(arguments.userInput)) EQ 0>
				<cfset local.response["message"] &= "Enter an Email or Phone Number. ">
			<cfelseif isValid("integer", trim(arguments.userInput)) AND arguments.userInput GT 0>
				<cfif len(trim(arguments.userInput)) NEQ 10>
					<cfset local.response["message"] &= "Phone number should be 10 digits long. ">
				</cfif>
			<cfelse>
				<cfif NOT isValid("email", trim(arguments.userInput))>
					<cfset local.response["message"] &= "Invalid email. ">
				</cfif>
			</cfif>

			<!--- Password Validation --->
			<cfif len(trim(arguments.password)) EQ 0>
				<cfset local.response["message"] &= "Enter a password. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- Continue with code execution if validation succeeds --->
			<cfquery name="local.qryCheckUser">
				SELECT
					fldUser_Id,
					fldFirstName,
					fldLastName,
					fldEmail,
					fldPhone,
					fldRoleId,
					fldUserSaltString,
					fldHashedPassword
				FROM
					tblUser
				WHERE
					(fldEmail = <cfqueryparam value = "#trim(arguments.userInput)#" cfsqltype = "varchar">
					OR fldPhone = <cfqueryparam value = "#trim(arguments.userInput)#" cfsqltype = "varchar">)
					AND fldActive = 1
			</cfquery>

			<cfif local.qryCheckUser.recordCount>
				<cfif local.qryCheckUser.fldHashedPassword EQ hash(trim(arguments.password) & local.qryCheckUser.fldUserSaltString, "SHA-512", "UTF-8", 50)>
					<cfset session.firstName = local.qryCheckUser.fldFirstName>
					<cfset session.lastName = local.qryCheckUser.fldLastName>
					<cfset session.email = local.qryCheckUser.fldEmail>
					<cfset session.phone = local.qryCheckUser.fldPhone>
					<cfset session.userId = local.qryCheckUser.fldUser_Id>
					<cfset session.roleId = local.qryCheckUser.fldRoleId>
					<cfset session.cart = application.dataFetch.getCart()>
					<cfset local.response["message"] = "Login successful">
				<cfelse>
					<cfset local.response["message"] = "Wrong username or password">
				</cfif>
			<cfelse>
				<cfset local.response["message"] = "User does not exist">
			</cfif>

			<cfcatch type="any">
				<cfset local.response["message"] = "Error while login!">
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="logOut" access="remote" returnType="void">
		<!--- Clear session --->
		<cfset structClear(session)>
	</cffunction>
</cfcomponent>