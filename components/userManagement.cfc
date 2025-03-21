<cfcomponent displayname="User Management" hint="Includes functions that help in user login, signup, modify profile, etc.">
	<cffunction name="signup" access="public" returnType="struct">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="email" type="string" required=true>
		<cfargument name="phone" type="string" required=true>
		<cfargument name="password" type="string" required=true>
		<cfargument name="confirmPassword" type="string" required=true>

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>

		<cftry>
			<!--- Firstname Validation --->
			<cfif len(trim(arguments.firstName)) EQ 0>
				<cfset local.response["message"] &= "Enter first name. ">
			<cfelseif isValid("regex", trim(arguments.firstName), "\d")>
				<cfset local.response["message"] &= "First name should not contain any digits. ">
			</cfif>

			<!--- Lastname Validation --->
			<cfif len(trim(arguments.lastname)) EQ 0>
				<cfset local.response["message"] &= "Enter last name. ">
			<cfelseif isValid("regex", trim(arguments.lastName), "\d")>
				<cfset local.response["message"] &= "Last name should not contain any digits. ">
			</cfif>

			<!--- Email Validation --->
			<cfif len(trim(arguments.email)) EQ 0>
				<cfset local.response["message"] &= "Enter an email address. ">
			<cfelseif NOT isValid("email", trim(arguments.email))>
				<cfset local.response["message"] &= "Invalid email. ">
			</cfif>

			<!--- Phone Number Validation --->
			<cfif len(trim(arguments.phone)) EQ 0>
				<cfset local.response["message"] &= "Enter an phone number. ">
			<cfelseif NOT isValid("regex", trim(arguments.phone), "^\d{10}$")>
				<cfset local.response["message"] &= "Phone number should be 10 digits long. ">
			</cfif>

			<!--- Password Validation --->
			<cfif len(trim(arguments.password)) EQ 0>
				<cfset local.response["message"] &= "Enter a password. ">
			<cfelseif NOT ( len(trim(arguments.password)) GTE 8
				AND refind('[A-Z]',trim(arguments.password))
				AND refind('[a-z]',trim(arguments.password))
				AND refind('[0-9]',trim(arguments.password))
				AND refind('[!@##$&*]',trim(arguments.password))
			)>
				<cfset local.response["message"] &= "Password must be at least 8 characters long and include uppercase, lowercase, number, and special character. ">
			</cfif>

			<!--- Confirm Password Validation --->
			<cfif len(trim(arguments.confirmPassword)) EQ 0>
				<cfset local.response["message"] &= "Confirm the password. ">
			<cfelseif arguments.password NEQ trim(arguments.confirmPassword)>
				<cfset local.response["message"] &= "Passwords must be equal. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- Continue with code execution if validation succeeds --->
			<cfquery name="local.qryCheckUser">
				SELECT
					fldUser_Id
				FROM
					tblUser
				WHERE
					(fldEmail = <cfqueryparam value = "#trim(arguments.email)#" cfsqltype = "varchar">
					OR fldPhone = <cfqueryparam value = "#trim(arguments.phone)#" cfsqltype = "varchar">)
					AND fldActive = 1
			</cfquery>

			<cfif local.qryCheckUser.recordCount>
				<cfset local.response["message"] = "Email or Phone number already exists.">
			<cfelse>
				<!--- Generate random salt string --->
				<cfset local.saltString = generateSecretKey("AES", 128)>
				<cfset local.hashedPassword = hash(trim(arguments.password) & local.saltString, "SHA-512", "UTF-8", 50)>
				<cfquery name="local.qryAddUser">
					INSERT INTO
						tblUser (
							fldFirstName,
							fldLastName,
							fldEmail,
							fldPhone,
							fldRoleId,
							fldHashedPassword,
							fldUserSaltString
						)
					VALUES (
						<cfqueryparam value = "#trim(arguments.firstName)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#trim(arguments.lastName)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#trim(arguments.email)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#trim(arguments.phone)#" cfsqltype = "varchar">,
						2,
						<cfqueryparam value = "#trim(local.hashedPassword)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#trim(local.saltString)#" cfsqltype = "varchar">
					)
				</cfquery>

				<cfset local.response["message"] = "Account created successfully.">
			</cfif>

			<cfset local.response.success = true>

			<cfcatch type="any">
				<cfset local.response["message"] = "Error while creating account!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

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
					<cfset session.cartCount = structCount(application.dataFetch.getCart().items)>
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

	<cffunction name="addAddress" access="remote" returnType="struct" returnformat="json">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="addressLine1" type="string" required=true>
		<cfargument name="addressLine2" type="string" required=true>
		<cfargument name="city" type="string" required=true>
		<cfargument name="state" type="string" required=true>
		<cfargument name="pincode" type="string" required=true>
		<cfargument name="phone" type="string" required=true>

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>

		<cftry>
			<cfif NOT structKeyExists(session, "userId")>
				<cfset local.response["message"] &= "Cannot proceed without loggin in">
			</cfif>

			<!--- Firstname Validation --->
			<cfif len(trim(arguments.firstName)) EQ 0>
				<cfset local.response["message"] &= "Enter first name. ">
			<cfelseif len(trim(arguments.firstName)) GT 32>
				<cfset local.response["message"] &= "First name should not be more than 32 characters. ">
			<cfelseif NOT isValid("regex", trim(arguments.firstName), "^[A-Za-z ]+$")>
				<cfset local.response["message"] &= "First name should only contain letters and spaces">
			</cfif>

			<!--- Lastname Validation --->
			<cfif len(trim(arguments.lastname)) EQ 0>
				<cfset local.response["message"] &= "Enter last name. ">
			<cfelseif len(trim(arguments.lastName)) GT 32>
				<cfset local.response["message"] &= "Last name should not be more than 32 characters. ">
			<cfelseif NOT isValid("regex", trim(arguments.lastName), "^[A-Za-z ]+$")>
				<cfset local.response["message"] &= "Last name should only contain letters and spaces">
			</cfif>

			<!--- Address Line 1 Validation --->
			<cfif len(trim(arguments.addressLine1)) EQ 0>
				<cfset local.response["message"] &= "Enter address line 1. ">
			<cfelseif len(trim(arguments.addressLine1)) GT 64>
				<cfset local.response["message"] &= "Address line 1 should not be more than 64 characters. ">
			</cfif>

			<!--- Address Line 2 Validation --->
			<cfif len(arguments.addressLine2) EQ 0>
				<cfset local.response["message"] &= "Enter address line 2. ">
			<cfelseif len(trim(arguments.addressLine2)) GT 64>
				<cfset local.response["message"] &= "Address line 2 should not be more than 64 characters. ">
			</cfif>

			<!--- City Validation --->
			<cfif len(arguments.city) EQ 0>
				<cfset local.response["message"] &= "Enter city. ">
			<cfelseif len(trim(arguments.city)) GT 64>
				<cfset local.response["message"] &= "City should not be more than 64 characters. ">
			<cfelseif isValid("regex", arguments.city, "\d")>
				<cfset local.response["message"] &= "City should not contain any digits. ">
			</cfif>

			<!--- State Validation --->
			<cfif len(trim(arguments.state)) EQ 0>
				<cfset local.response["message"] &= "Enter state. ">
			<cfelseif len(trim(arguments.state)) GT 64>
				<cfset local.response["message"] &= "State should not be more than 64 characters. ">
			<cfelseif isValid("regex", trim(arguments.state), "\d")>
				<cfset local.response["message"] &= "State should not contain any digits. ">
			</cfif>

			<!--- Pincode Validation --->
			<cfif len(arguments.pincode) EQ 0>
				<cfset local.response["message"] &= "Enter pincode. ">
			<cfelseif NOT isValid("regex", trim(arguments.pincode), "^\d{6}$")>
				<cfset local.response["message"] &= "Pincode should be 6 digits long. ">
			</cfif>

			<!--- Phone Number Validation --->
			<cfif len(arguments.phone) EQ 0>
				<cfset local.response["message"] &= "Enter an phone number. ">
			<cfelseif NOT isValid("regex", trim(arguments.phone), "^\d{10}$")>
				<cfset local.response["message"] &= "Phone number should be 10 digits long. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- Continue with code execution if validation succeeds --->
			<cfquery name="qryAddAddress">
				INSERT INTO
					tblAddress (
						fldUserId,
						fldFirstName,
						fldLastName,
						fldAddressLine1,
						fldAddressLine2,
						fldCity,
						fldState,
						fldPincode,
						fldPhone
					)
				VALUES (
					<cfqueryparam value = "#session.userId#" cfsqltype = "integer">,
					<cfqueryparam value = "#trim(arguments.firstName)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(arguments.lastName)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(arguments.addressLine1)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(arguments.addressLine2)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(arguments.city)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(arguments.state)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(arguments.pincode)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(arguments.phone)#" cfsqltype = "varchar">
				)
			</cfquery>


			<cfset local.response.success = true>
			<cfset local.response.message = "Address Created successfully!">

			<cfcatch type="any">
				<cfset local.response.message = "Error while adding address!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteAddress" access="remote" returnType="struct">
		<cfargument name="addressId" type="string" required=true default="">

		<cfset local.response = application.productManagement.deleteItem(
			itemName = "address",
			itemId = arguments.addressId
		)>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="editProfile" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="email" type="string" required=true>
		<cfargument name="phone" type="string" required=true>

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>

		<cftry>
			<cfif NOT structKeyExists(session, "userId")>
				<cfset local.response["message"] &= "Cannot proceed without loggin in">
			</cfif>

			<!--- Firstname Validation --->
			<cfif len(trim(arguments.firstName)) EQ 0>
				<cfset local.response["message"] &= "Enter first name. ">
			<cfelseif len(trim(arguments.firstName)) GT 32>
				<cfset local.response["message"] &= "First name should not be more than 32 characters. ">
			<cfelseif NOT isValid("regex", trim(arguments.firstName), "^[A-Za-z ]+$")>
				<cfset local.response["message"] &= "First name should only contain letters and spaces. ">
			</cfif>

			<!--- Lastname Validation --->
			<cfif len(trim(arguments.lastname)) EQ 0>
				<cfset local.response["message"] &= "Enter last name. ">
			<cfelseif len(trim(arguments.lastName)) GT 32>
				<cfset local.response["message"] &= "Last name should not be more than 32 characters. ">
			<cfelseif NOT isValid("regex", trim(arguments.lastName), "^[A-Za-z ]+$")>
				<cfset local.response["message"] &= "Last name should only contain letters and spaces. ">
			</cfif>

			<!--- Email Validation --->
			<cfif len(trim(arguments.email)) EQ 0>
				<cfset local.response["message"] &= "Enter an email address. ">
			<cfelseif NOT isValid("email", trim(arguments.email))>
				<cfset local.response["message"] &= "Invalid email. ">
			</cfif>

			<!--- Phone Number Validation --->
			<cfif len(arguments.phone) EQ 0>
				<cfset local.response["message"] &= "Enter an phone number. ">
			<cfelseif NOT isValid("regex", trim(arguments.phone), "^\d{10}$")>
				<cfset local.response["message"] &= "Phone number should be 10 digits long. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- Continue with code execution if validation succeeds --->
			<cfquery name="local.qryCheckUser">
				-- Check if email or phone number already exists
				SELECT
					fldUser_Id
				FROM
					tblUser
				WHERE
					fldActive = 1
					AND (
						fldEmail = <cfqueryparam value = "#trim(arguments.email)#" cfsqltype = "varchar">
						OR fldPhone = <cfqueryparam value = "#trim(arguments.phone)#" cfsqltype = "varchar">
					)
			</cfquery>

			<cfif (local.qryCheckUser.recordCount GT 1) OR (local.qryCheckUser.recordCount AND local.qryCheckUser.fldUser_Id NEQ session.userId)>
				<cfset local.response["message"] = "Email or Phone number already exits.">
			<cfelse>
				<cfquery name="local.qryEditProfile">
					UPDATE
						tblUser
					SET
						fldFirstName = <cfqueryparam value = "#trim(arguments.firstName)#" cfsqltype = "varchar">,
						fldLastName = <cfqueryparam value = "#trim(arguments.lastName)#" cfsqltype = "varchar">,
						fldEmail = <cfqueryparam value = "#trim(arguments.email)#" cfsqltype = "varchar">,
						fldPhone = <cfqueryparam value = "#trim(arguments.phone)#" cfsqltype = "varchar">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					WHERE
						fldUser_Id = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
				</cfquery>

				<cfset session.firstName = arguments.firstName>
				<cfset session.lastName = arguments.lastName>
				<cfset session.email = arguments.email>
				<cfset session.phone = arguments.phone>

				<cfset local.response.success = true>
				<cfset local.response["message"] = "Profile Updated successfully">
			</cfif>

			<cfcatch type="any">
				<cfset local.response["message"] = "Error while editing profile!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="logOut" access="remote" returnType="void">
		<!--- Clear session --->
		<cfset structClear(session)>
	</cffunction>
</cfcomponent>