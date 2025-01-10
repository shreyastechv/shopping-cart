<cffunction  name="login" access="public" returnType="struct">
	<cfargument  name="userInput">
	<cfargument  name="password">

	<cfset local.response = {}>

	<cfquery name="local.qryCheckUser">
		SELECT
			fldUser_Id,
			fldFirstName,
			fldLastName,
			fldRoleId,
			fldUserSaltString,
			fldHashedPassword
		FROM
			tblUser
		WHERE
			(fldEmail = <cfqueryparam value = "#trim(arguments.userInput)#" cfsqltype = "cf_sql_varchar">
			OR fldPhone = <cfqueryparam value = "#trim(arguments.userInput)#" cfsqltype = "cf_sql_varchar">)
			AND fldActive = 1
	</cfquery>

	<cfif local.qryCheckUser.recordCount>
		<cfif local.qryCheckUser.fldHashedPassword EQ hash(arguments.password & local.qryCheckUser.fldUserSaltString, "SHA-512", "UTF-8", 3)>
			<cfset session.isLoggedIn = true>
			<cfset session.userFullname = local.qryCheckUser.fldFirstName & " " & local.qryCheckUser.fldLastName>
			<cfset session.userId = local.qryCheckUser.fldUser_Id>
			<cfset session.roleId = local.qryCheckUser.fldRoleId>
			<cfset local.response["message"] = "Login successfull">
		<cfelse>
			<cfset local.response["message"] = "Wrong username or password">
		</cfif>
	<cfelse>
		<cfset local.response["message"] = "User does not exist">
	</cfif>

	<cfreturn local.response>
</cffunction>

<cffunction name="getCategories" access="public" returnType="query">
	<cfquery name="local.qryGetCategories">
		SELECT
			fldCategory_Id,
			fldCategoryName
		FROM
			tblCategory
		WHERE
			fldActive = 1
	</cfquery>

	<cfreturn local.qryGetCategories>
</cffunction>

<cffunction name="modifyCategory" access="remote" returnType="struct" returnFormat="json">
	<cfargument name="categoryId">
	<cfargument name="categoryName">

	<cfset local.response = {}>

	<cfquery name="local.qryCheckCategory">
		SELECT
			fldCategory_Id
		FROM
			tblCategory
		WHERE
			fldCategoryName = <cfqueryparam value = "#trim(arguments.categoryName)#" cfsqltype = "cf_sql_varchar">
			AND fldActive = 1
	</cfquery>

	<cfif local.qryCheckCategory.recordCount>
		<cfset local.response["message"] = "Category already exists!">
	<cfelse>
		<cfif len(trim(arguments.categoryId))>
			<cfquery name="qryEditCategory">
				UPDATE
					tblCategory
				SET
					fldCategoryName = <cfqueryparam value = "#trim(arguments.categoryName)#" cfsqltype = "cf_sql_varchar">,
					fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
				WHERE
					fldCategory_Id = <cfqueryparam value = "#trim(arguments.categoryId)#" cfsqltype = "cf_sql_integer">
			</cfquery>
			<cfset local.response["message"] = "Category Updated">
		<cfelse>
			<cfquery name="qryAddCategory">
				INSERT INTO
					tblCategory (
						fldCategoryName,
						fldCreatedBy
					)
				VALUES (
					<cfqueryparam value = "#trim(arguments.categoryName)#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
				)
			</cfquery>
			<cfset local.response["message"] = "Category Added">
		</cfif>
	</cfif>

	<cfreturn local.response>
</cffunction>

<cffunction name="deleteCategory" access="remote">
	<cfargument name="categoryId">

	<cfquery name="qryDeleteCategory">
		UPDATE
			tblCategory
		SET
			fldActive = 0,
			fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
		WHERE
			fldCategory_Id = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "cf_sql_integer">
	</cfquery>
</cffunction>