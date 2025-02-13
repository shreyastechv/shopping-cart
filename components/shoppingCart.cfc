<cfcomponent>
	<cffunction name="signup" access="public" returnType="struct">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="email" type="string" required=true>
		<cfargument name="phone" type="string" required=true>
		<cfargument name="password" type="string" required=true>
		<cfargument name="confirmPassword" type="string" required=true>

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Firstname Validation --->
		<cfif len(trim(arguments.firstName)) EQ 0>
			<cfset local.response["message"] &= "Enter first name. ">
		<cfelseif isValid("regex", trim(arguments.firstName), "/\d/")>
			<cfset local.response["message"] &= "First name should not contain any digits. ">
		</cfif>

		<!--- Lastname Validation --->
		<cfif len(trim(arguments.lastname)) EQ 0>
			<cfset local.response["message"] &= "Enter last name. ">
		<cfelseif isValid("regex", trim(arguments.lastName), "/\d/")>
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

		<cfreturn local.response>
	</cffunction>

	<cffunction name="login" access="public" returnType="struct">
		<cfargument name="userInput" type="string" required=true>
		<cfargument name="password" type="string" required=true>

		<cfset local.response = {
			"message" = ""
		}>

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
				<cfset session.cart = getCart()>
				<cfset local.response["message"] = "Login successful">
			<cfelse>
				<cfset local.response["message"] = "Wrong username or password">
			</cfif>
		<cfelse>
			<cfset local.response["message"] = "User does not exist">
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getCategories" access="public" returnType="struct">
		<!--- Create response struct --->
		<cfset local.response = {
			"data" = []
		}>

		<cfquery name="local.qryGetCategories">
			SELECT
				c.fldCategory_Id,
				c.fldCategoryName
			FROM
				tblCategory c
			WHERE
				c.fldActive = 1
				-- Make sure to return only no-empty categories for non-admin users
				<cfif NOT structKeyExists(session, "roleId") OR session.roleId EQ 2>
					AND EXISTS (
						SELECT
							1
						FROM
							tblSubCategory sc
						WHERE
							sc.fldCategoryId = c.fldCategory_Id
							AND sc.fldActive = 1
					)
				</cfif>
		</cfquery>

		<!--- Fill up the array with category information --->
		<cfloop query="local.qryGetCategories">
			<cfset local.categoryStruct = {
				"categoryId": encryptText(local.qryGetCategories.fldCategory_Id),
				"categoryName": local.qryGetCategories.fldCategoryName
			}>

			<cfset arrayAppend(local.response.data, local.categoryStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="modifyCategory" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="categoryId" type="string" required=true default="">
		<cfargument name="categoryName" type="string" required=true>

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.categoryId = decryptText(arguments.categoryId)>

		<!--- Category Id Validation --->
		<cfif len(trim(arguments.categoryId)) AND local.categoryId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Category Id is invalid. ">
		</cfif>

		<!--- Category Name Validation --->
		<cfif len(arguments.categoryName) EQ 0>
			<cfset local.response["message"] &= "Category Name should not be empty. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryCheckCategory">
			SELECT
				fldCategory_Id
			FROM
				tblCategory
			WHERE
				fldCategoryName = <cfqueryparam value = "#trim(arguments.categoryName)#" cfsqltype = "varchar">
				AND fldActive = 1
		</cfquery>

		<cfif local.qryCheckCategory.recordCount>
			<cfset local.response["message"] = "Category already exists!">
		<cfelse>
			<!--- Category Id not empty means we used edit button --->
			<cfif len(trim(arguments.categoryId))>
				<cfquery name="qryEditCategory">
					UPDATE
						tblCategory
					SET
						fldCategoryName = <cfqueryparam value = "#trim(arguments.categoryName)#" cfsqltype = "varchar">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					WHERE
						fldCategory_Id = <cfqueryparam value = "#trim(local.categoryId)#" cfsqltype = "integer">
				</cfquery>
				<cfset local.response["message"] = "Category Updated">
			<cfelse>
				<cfquery name="local.qryAddCategory" result="local.resultAddCategory">
					INSERT INTO
						tblCategory (
							fldCategoryName,
							fldCreatedBy
						)
					VALUES (
						<cfqueryparam value = "#trim(arguments.categoryName)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					)
				</cfquery>
				<cfset local.response["categoryId"] = encryptText(local.resultAddCategory.GENERATED_KEY)>
				<cfset local.response["message"] = "Category Added">
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteCategory" access="remote" returnType="void">
		<cfargument name="categoryId" type="string" required=true default="">

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.categoryId = decryptText(arguments.categoryId)>

		<!--- Login Check --->
		<cfif NOT structKeyExists(session, "userId")>
			<cfset local.response["message"] &= "User not logged in">
		</cfif>

		<!--- Category Id Validation --->
		<cfif NOT len(trim(arguments.categoryId))>
			<cfset local.response["message"] &= "Category Id is required. ">
		<cfelseif local.categoryId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Category Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfstoredproc procedure="spDeleteCategory">
			<cfprocparam cfsqltype="integer" variable="categoryId" value="#local.categoryId#">
			<cfprocparam cfsqltype="integer" variable="userId" value="#session.userId#">
		</cfstoredproc>
	</cffunction>

	<cffunction name="getSubCategories" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="categoryId" type="string" required=false default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
		}>

		<!--- Decrypt ids--->
		<cfset local.categoryId = decryptText(arguments.categoryId)>

		<!--- Category Id Validation --->
		<cfif (len(trim(arguments.categoryId)) NEQ 0) AND (local.categoryId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Category Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetSubCategories">
			SELECT
				sc.fldSubCategory_Id,
				sc.fldSubCategoryName,
				sc.fldCategoryId
			FROM
				tblSubCategory sc
			WHERE
				sc.fldActive = 1
				<cfif structKeyExists(local, "categoryId") AND (trim(local.categoryId) NEQ -1)>
					AND sc.fldCategoryId = <cfqueryparam value = "#local.categoryId#" cfsqltype = "integer">
				</cfif>
		</cfquery>

		<!--- Fill up the array with sub category information --->
		<cfloop query="local.qryGetSubCategories">
			<cfset local.subCategoryStruct = {
				"subCategoryId": encryptText(local.qryGetSubCategories.fldSubCategory_Id),
				"subCategoryName": local.qryGetSubCategories.fldSubCategoryName,
				"categoryId": encryptText(local.qryGetSubCategories.fldCategoryId)
			}>

			<cfset arrayAppend(local.response.data, local.subCategoryStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="modifySubCategory" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="subCategoryId" type="string" required=true default="">
		<cfargument name="subCategoryName" type="string" required=true>
		<cfargument name="categoryId" type="string" required=true default="">

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.subCategoryId = decryptText(arguments.subCategoryId)>
		<cfset local.categoryId = decryptText(arguments.categoryId)>

		<!--- Sub Category Id Validation --->
		<cfif len(trim(arguments.subCategoryId)) AND local.subCategoryId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Sub Category Id is invalid. ">
		</cfif>

		<!--- SubCategory Name Validation --->
		<cfif len(arguments.subCategoryName) EQ 0>
			<cfset local.response["message"] &= "SubCategory Name should not be empty. ">
		</cfif>

		<!--- Category Id Validation --->
		<cfif NOT len(trim(arguments.categoryId))>
			<cfset local.response["message"] &= "Category Id is required. ">
		<cfelseif local.categoryId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Category Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryCheckSubCategory">
			SELECT
				fldSubCategory_Id
			FROM
				tblSubCategory
			WHERE
				fldSubCategoryName = <cfqueryparam value = "#trim(arguments.subCategoryName)#" cfsqltype = "varchar">
				AND fldCategoryId = <cfqueryparam value = "#trim(local.categoryId)#" cfsqltype = "integer">
				AND fldSubCategory_Id != <cfqueryparam value = "#val(trim(local.subCategoryId))#" cfsqltype = "integer">
				AND fldActive = 1
		</cfquery>

		<cfif local.qryCheckSubCategory.recordCount>
			<cfset local.response["message"] = "SubCategory already exists!">
		<cfelse>
			<!--- sub category id has length means we used edit button --->
			<cfif len(trim(arguments.subCategoryId))>
				<cfquery name="qryEditSubCategory">
					UPDATE
						tblSubCategory
					SET
						fldSubCategoryName = <cfqueryparam value = "#trim(arguments.subCategoryName)#" cfsqltype = "varchar">,
						fldCategoryId = <cfqueryparam value = "#trim(local.categoryId)#" cfsqltype = "integer">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					WHERE
						fldSubCategory_Id = <cfqueryparam value = "#trim(local.subCategoryId)#" cfsqltype = "integer">
				</cfquery>
				<cfset local.response["message"] = "SubCategory Updated">
			<cfelse>
				<cfquery name="local.qryAddSubCategory" result="local.resultAddSubCategory">
					INSERT INTO
						tblSubCategory (
							fldSubCategoryName,
							fldCategoryId,
							fldCreatedBy
						)
					VALUES (
						<cfqueryparam value = "#trim(arguments.subCategoryName)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#trim(local.categoryId)#" cfsqltype = "integer">,
						<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					)
				</cfquery>
				<cfset local.response["subCategoryId"] = encryptText(local.resultAddSubCategory.GENERATED_KEY)>
				<cfset local.response["message"] = "SubCategory Added">
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteSubCategory" access="remote" returnType="void">
		<cfargument name="subCategoryId" type="string" required=true default="">

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.subCategoryId = decryptText(arguments.subCategoryId)>

		<!--- Sub Category Id Validation --->
		<cfif NOT len(trim(arguments.subCategoryId))>
			<cfset local.response["message"] &= "Sub Category Id is required. ">
		<cfelseif local.subCategoryId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Sub Category Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="qryDeleteProducts">
			UPDATE
				tblProduct
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldSubCategoryId = <cfqueryparam value = "#local.subCategoryId#" cfsqltype = "integer">
		</cfquery>

		<cfquery name="qryDeleteProductImages">
			UPDATE
				tblProductImages
			SET
				fldActive = 0,
				fldDeactivatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">,
				fldDeactivatedDate = <cfqueryparam value = "#DateTimeFormat(now(), "yyyy-MM-dd HH:mm:ss")#" cfsqltype = "timestamp">
			WHERE
				fldProductId IN (
					SELECT
						fldProduct_Id
					FROM
						tblProduct
					WHERE
						fldSubCategoryId = <cfqueryparam value = "#local.subCategoryId#" cfsqltype = "integer">
				);
		</cfquery>

		<cfquery name="qryDeleteSubCategory">
			UPDATE
				tblSubCategory
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldSubCategory_Id = <cfqueryparam value = "#local.subCategoryId#" cfsqltype = "integer">
		</cfquery>
	</cffunction>

	<cffunction name="getProducts" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="subCategoryId" type="string" required=false default="">
		<cfargument name="productId" type="string" required=false default="">
		<cfargument name="productIdList" type="string" required=false default="">
		<cfargument name="random" type="integer" required=false default="0">
		<cfargument name="limit" type="string" required="false" default="">
		<cfargument name="offset" type="string" required="false" default=0>
		<cfargument name="sort" type="string" required="false" default="">
		<cfargument name="min" type="float" required="false" default="0">
		<cfargument name="max" type="float" required="false" default="0">
		<cfargument name="searchTerm" type="string" required="false" default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
		}>

		<!--- Decrypt ids--->
		<cfset local.subCategoryId = decryptText(arguments.subCategoryId)>
		<cfset local.productId = decryptText(arguments.productId)>
		<cfset local.productIdList = listMap(arguments.productIdList, function(item) {
			return decryptText(item);
		})>

		<!--- Sub Category Id Validation --->
		<cfif (len(trim(arguments.subCategoryId)) NEQ 0) AND (local.subCategoryId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Sub Category Id is invalid. ">
		</cfif>

		<!--- Product Id Validation --->
		<cfif (len(trim(arguments.productId)) NEQ 0) AND (local.productId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Product Id is invalid. ">
		</cfif>

		<!--- Orderby Validation --->
		<cfif NOT arrayContainsNoCase(["asc",  "desc", ""], arguments.sort)>
			<cfset local.response["message"] &= "Sort value should either be asc or desc">
		</cfif>

		<!--- Min Max Validation --->
		<cfif len(trim(arguments.max)) AND arguments.max LT arguments.min>
			<cfset local.response["message"] &= "Max should be greater than or equal to Min">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetProducts">
			SELECT
				p.fldProduct_Id,
				p.fldProductName,
				p.fldBrandId,
				p.fldDescription,
				p.fldPrice,
				p.fldTax,
				b.fldBrandName,
				i.fldImageFileName AS fldProductImage
			FROM
				tblProduct p
				INNER JOIN tblBrands b ON p.fldBrandId = b.fldBrand_Id
				INNER JOIN tblSubCategory s ON p.fldSubCategoryId = s.fldSubCategory_Id
				INNER JOIN tblCategory c ON s.fldCategoryId = c.fldCategory_Id
				INNER JOIN tblProductImages i ON p.fldProduct_Id = i.fldProductId
					AND i.fldActive = 1
					AND i.fldDefaultImage = 1
			WHERE
				p.fldActive = 1
				<cfif len(trim(local.subCategoryId)) AND local.subCategoryId NEQ -1>
					AND p.fldSubCategoryId = <cfqueryparam value = "#local.subCategoryId#" cfsqltype = "integer">
				<cfelseif len(trim(local.productId)) AND local.productId NEQ -1>
					AND p.fldProduct_Id = <cfqueryparam value = "#local.productId#" cfsqltype = "integer">
				<cfelseif len(trim(arguments.productIdList))>
					AND fldProductId IN (<cfqueryparam value = "#local.productIdList#" cfsqltype = "varchar" list = "yes">)
				</cfif>

				<!--- 0 is the default value of arguments.max hence it should not be used --->
				<cfif len(trim(arguments.max)) AND trim(arguments.max) NEQ 0>
					AND p.fldPrice BETWEEN <cfqueryparam value = "#arguments.min#" cfsqltype = "integer">
						AND <cfqueryparam value = "#arguments.max#" cfsqltype = "integer">
				</cfif>

				<cfif len(trim(arguments.searchTerm))>
					AND (p.fldProductName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
						OR p.fldDescription LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
						OR c.fldCategoryName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
						OR s.fldSubCategoryName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
						OR b.fldBrandName LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">)
				</cfif>

		</cfquery>

		<!--- Loop through the query results and populate the array --->
		<cfloop query="local.qryGetProducts">
			<cfset local.productStruct = {
				"productId": encryptText(local.qryGetProducts.fldProduct_Id),
				"productName": local.qryGetProducts.fldProductName,
				"brandId": encryptText(local.qryGetProducts.fldBrandId),
				"brandName": local.qryGetProducts.fldBrandName,
				"description": local.qryGetProducts.fldDescription,
				"price": local.qryGetProducts.fldPrice,
				"tax": local.qryGetProducts.fldTax,
				"productImage": local.qryGetProducts.fldProductImage
			}>

			<!--- Append each product struct to the response array --->
			<cfset arrayAppend(local.response.data, local.productStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getBrands" access="public" returnType="struct">
		<cfset local.response = {
			"data" = []
		}>

		<cfquery name="local.qryGetBrands">
			SELECT
				fldBrand_Id,
				fldBrandName
			FROM
				tblBrands
			ORDER BY
				fldBrandName
		</cfquery>

		<!--- Fill up the array with brand information --->
		<cfloop query="local.qryGetBrands">
			<cfset local.brandStruct = {
				"brandId": encryptText(local.qryGetBrands.fldBrand_Id),
				"brandName": local.qryGetBrands.fldBrandName
			}>

			<cfset arrayAppend(local.response.data, local.brandStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="modifyProduct" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">
		<cfargument name="subCategorySelect" type="string" required=true default="">
		<cfargument name="productName" type="string" required=true>
		<cfargument name="brandSelect" type="string" required=true default="">
		<cfargument name="productDesc" type="string" required=true>
		<cfargument name="productPrice" type="float" required=true>
		<cfargument name="productTax" type="float" required=true>
		<cfargument name="productImage" type="string" required=true>

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.productId = decryptText(arguments.productId)>
		<cfset local.subCategorySelect = decryptText(arguments.subCategorySelect)>
		<cfset local.brandSelect = decryptText(arguments.brandSelect)>

		<!--- Product Id Validation --->
		<cfif len(trim(arguments.productId)) AND (local.productId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Product Id is invalid. ">
		</cfif>

		<!--- Sub Category Id Validation --->
		<cfif (len(trim(arguments.subCategorySelect)) NEQ 0) AND (local.subCategorySelect EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Sub Category Id is invalid. ">
		</cfif>

		<!--- Product Description Validation --->
		<cfif len(arguments.productDesc) EQ 0>
			<cfset local.response["message"] &= "Product Description should not be empty. ">
		<cfelseif len(arguments.productDesc) GT 400>
			<cfset local.response["message"] &= "Product Description should be less than 400 characters. ">
		</cfif>

		<!--- Brand Id Validation --->
		<cfif (len(trim(arguments.brandSelect)) NEQ 0) AND (local.brandSelect EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Sub Category Id is invalid. ">
		</cfif>

		<!--- Product Name Validation --->
		<cfif len(arguments.productName) EQ 0>
			<cfset local.response["message"] &= "Product Name should not be empty. ">
		</cfif>

		<!--- Price Validation --->
		<cfif len(arguments.productPrice) EQ 0>
			<cfset local.response["message"] &= "Price should not be empty. ">
		<cfelseif NOT isValid("float", arguments.productPrice)>
			<cfset local.response["message"] &= "Price should be an number">
		</cfif>

		<!--- Tax Validation --->
		<cfif len(arguments.productTax) EQ 0>
			<cfset local.response["message"] &= "Tax should not be empty. ">
		<cfelseif NOT isValid("float", arguments.productTax)>
			<cfset local.response["message"] &= "Tax should be an number">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryCheckProduct">
			SELECT
				fldProduct_Id
			FROM
				tblProduct
			WHERE
				fldProductName = <cfqueryparam value = "#trim(arguments.productName)#" cfsqltype = "varchar">
				AND fldSubCategoryId = <cfqueryparam value = "#trim(local.subCategorySelect)#" cfsqltype = "integer">
				AND fldProduct_Id != <cfqueryparam value = "#val(trim(local.productId))#" cfsqltype = "integer">
				AND fldActive = 1
		</cfquery>

		<cfif local.qryCheckProduct.recordCount>
			<cfset local.response["message"] = "Product already exists!">
		<cfelse>
			<!--- Upload images --->
			<cffile
				action="uploadall"
				destination="#expandPath(application.productImageDirectory)#"
				nameconflict="MakeUnique"
				accept="image/png,image/jpeg,.png,.jpg,.jpeg"
				strict="true"
				result="local.uploadedImages"
				allowedextensions=".png,.jpg,.jpeg"
			>

			<!--- Sub category id has length means we used edit button --->
			<cfif len(trim(arguments.productId))>
				<cfquery name="qryEditProduct">
					UPDATE
						tblProduct
					SET
						fldProductName = <cfqueryparam value = "#trim(arguments.productName)#" cfsqltype = "varchar">,
						fldSubCategoryId = <cfqueryparam value = "#trim(local.subCategorySelect)#" cfsqltype = "integer">,
						fldBrandId = <cfqueryparam value = "#trim(local.brandSelect)#" cfsqltype = "integer">,
						fldDescription = <cfqueryparam value = "#trim(arguments.productDesc)#" cfsqltype = "varchar">,
						fldPrice = <cfqueryparam value = "#trim(arguments.productPrice)#" cfsqltype = "decimal">,
						fldTax = <cfqueryparam value = "#trim(arguments.productTax)#" cfsqltype = "decimal">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					WHERE
						fldProduct_Id = <cfqueryparam value = "#val(trim(local.productId))#" cfsqltype = "integer">
				</cfquery>
				<cfset local.response["message"] = "Product Updated">
			<cfelse>
				<cfquery name="local.qryAddProduct" result="local.resultAddProduct">
					INSERT INTO
						tblProduct (
							fldProductName,
							fldSubCategoryId,
							fldBrandId,
							fldDescription,
							fldPrice,
							fldTax,
							fldCreatedBy
						)
					VALUES (
						<cfqueryparam value = "#trim(arguments.productName)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#trim(local.subCategorySelect)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#trim(local.brandSelect)#" cfsqltype = "integer">,
						<cfqueryparam value = "#trim(arguments.productDesc)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#val(arguments.productPrice)#" cfsqltype = "decimal" scale = "2">,
						<cfqueryparam value = "#val(arguments.productTax)#" cfsqltype = "decimal" scale = "2">,
						<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					)
				</cfquery>
				<cfset local.response["productId"] = encryptText(local.resultAddProduct.GENERATED_KEY)>
				<cfset local.response["defaultImageFile"] = local.uploadedImages[1].serverFile>
				<cfset local.response["message"] = "Product Added">
			</cfif>

			<!--- Store images in DB --->
			<cfif arrayLen(local.uploadedImages)>
				<cfquery name="qryAddImages">
					INSERT INTO
						tblProductImages (
							fldProductId,
							fldImageFileName,
							fldDefaultImage,
							fldCreatedBy
						)
					VALUES
						<cfloop array="#local.uploadedImages#" item="local.image" index="local.i">
							(
								-- Product id is not empty means we clicked on edit button
								<cfif len(trim(arguments.productId))>
									<cfqueryparam value = "#local.productId#" cfsqltype = "integer">,
								<cfelse>
									<cfqueryparam value = "#local.resultAddProduct.GENERATED_KEY#" cfsqltype = "integer">,
								</cfif>
								<cfqueryparam value = "#local.image.serverFile#" cfsqltype = "varchar">,
								<cfif local.i EQ 1 AND len(trim(arguments.productId)) EQ 0>
									1,
								<cfelse>
									0,
								</cfif>
								<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
							)
							<cfif local.i LT arrayLen(local.uploadedImages)>,</cfif>
						</cfloop>
				</cfquery>
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteProduct" access="remote" returnType="void">
		<cfargument name="productId" type="string" required=true default="">

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.productId = decryptText(arguments.productId)>

		<!--- Product Id Validation --->
		<cfif len(arguments.productId) EQ 0>
			<cfset local.response["message"] &= "Product Id should not be empty. ">
		<cfelseif local.productId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Product Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="qryDeleteProducts">
			UPDATE
				tblProduct
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldProduct_Id = <cfqueryparam value = "#local.productId#" cfsqltype = "integer">
		</cfquery>

		<cfquery name="qryDeleteProductImages">
			UPDATE
				tblProductImages
			SET
				fldActive = 0,
				fldDeactivatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">,
				fldDeactivatedDate = <cfqueryparam value = "#DateTimeFormat(now(), "yyyy-MM-dd HH:mm:ss")#" cfsqltype = "timestamp">
			WHERE
				fldProductId = <cfqueryparam value = "#local.productId#" cfsqltype = "integer">
		</cfquery>

	</cffunction>

	<cffunction name="getProductImages" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
		}>

		<!--- Decrypt ids--->
		<cfset local.productId = decryptText(arguments.productId)>

		<!--- Product Id Validation --->
		<cfif len(arguments.productId) EQ 0>
			<cfset local.response["message"] &= "Product Id should not be empty. ">
		<cfelseif local.productId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Product Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetImages">
			SELECT
				fldProductImage_Id,
				fldImageFileName,
				fldDefaultImage
			FROM
				tblProductImages
			WHERE
				fldProductId = <cfqueryparam value = "#local.productId#" cfsqltype = "integer">
				AND fldActive = 1
		</cfquery>

		<cfloop query="local.qryGetImages">
			<cfset local.imageStruct = {
				"imageId" = encryptText(local.qryGetImages.fldProductImage_Id),
				"imageFileName" = local.qryGetImages.fldImageFileName,
				"defaultImage" = local.qryGetImages.fldDefaultImage
			}>
			<cfset arrayAppend(local.response.data, local.imageStruct)>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="setDefaultImage" access="remote" returnType="void">
		<cfargument name="imageId" type="string" required=true default="">

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.imageId = decryptText(arguments.imageId)>

		<!--- Image Id Validation --->
		<cfif len(arguments.imageId) EQ 0>
			<cfset local.response["message"] &= "Image Id should not be empty. ">
		<cfelseif local.imageId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Image Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="qryUnsetDefautImage">
			UPDATE
				tblProductImages AS p
			JOIN (
				SELECT
					fldProductId
				FROM
					tblProductImages
				WHERE
					fldProductImage_Id = <cfqueryparam value="#trim(local.imageId)#" cfsqltype="integer">
			) AS subquery
			ON p.fldProductId = subquery.fldProductId
			SET
				p.fldDefaultImage = 0
			WHERE
				p.fldDefaultImage = 1;
		</cfquery>

		<cfquery name="qrySetDefautImage">
			UPDATE
				tblProductImages
			SET
				fldDefaultImage = 1
			WHERE
				fldProductImage_Id = <cfqueryparam value = "#trim(local.imageId)#" cfsqltype = "integer">
		</cfquery>
	</cffunction>

	<cffunction name="deleteImage" access="remote" returnType="struct">
		<cfargument name="imageId" type="string" required=true defaul="">

		<cfset local.response = {
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.imageId = decryptText(arguments.imageId)>

		<!--- Image Id Validation --->
		<cfif len(arguments.imageId) EQ 0>
			<cfset local.response["message"] &= "Image Id should not be empty. ">
		<cfelseif local.imageId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Image Id is invalid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="qryDeleteImage">
			UPDATE
				tblProductImages
			SET
				fldActive = 0
			WHERE
				fldProductImage_Id = <cfqueryparam value = "#trim(local.imageId)#" cfsqltype = "integer">
		</cfquery>

		<!--- Set success message --->
		<cfset local.response["message"] = "Product Image deleted">

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getCart" access="public" returnType="struct">
		<cfset local.cartItems = {}>

		<!--- UserId Validation --->
		<cfif NOT structKeyExists(session, "userId")>
			<cfreturn local.cartItems>
		</cfif>

		<cfquery name="local.qryGetCart">
			SELECT
				c.fldCart_Id,
				c.fldProductId,
				c.fldQuantity,
				p.fldPrice,
				p.fldTax
			FROM
				tblCart c
				INNER JOIN tblProduct p ON c.fldProductId = p.fldProduct_Id
					AND p.fldActive = 1 <!--- Only take active products --->
			WHERE
				c.fldUserId = <cfqueryparam value = "#trim(session.userId)#" cfsqltype = "integer">
		</cfquery>

		<cfloop query="local.qryGetCart">
			<cfset local.cartItems[encryptText(local.qryGetCart.fldProductId)] = {
				"quantity" = local.qryGetCart.fldQuantity
			}>
		</cfloop>

		<cfreturn local.cartItems>
	</cffunction>

	<cffunction name="modifyCart" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">
		<cfargument name="action" type="string" required=true default="">

		<cfset local.response = {
			"message" = "",
			"success" = false,
			"data" = {}
		}>

		<!--- Decrypt ids--->
		<cfset local.productId = decryptText(arguments.productId)>

		<!--- Product Id Validation --->
		<cfif len(arguments.productId) EQ 0>
			<cfset local.response["message"] &= "Product Id should not be empty. ">
		<cfelseif local.productId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Product Id is invalid. ">
		</cfif>

		<!--- Validate Action --->
		<cfif NOT len(trim(arguments.action))>
			<cfset local.response["message"] &= "Action should not be empty. ">
		<cfelseif NOT arrayContainsNoCase(["increment", "decrement", "delete"], arguments.action)>
			<cfset local.response["message"] &= "Specified action is not valid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfif arguments.action EQ "increment">

			<!--- Check whether the item is present in cart --->
			<cfif structKeyExists(session.cart, arguments.productId)>
				<!--- Increment quantity of product in session variable --->
				<cfset session.cart[arguments.productId].quantity += 1>

				<!--- Set response message --->
				<cfset local.response["message"] = "Product Quantity Incremented">

			<cfelse>
				<!--- Add product to session variable --->
				<cfset session.cart[arguments.productId] = {
					"quantity" = 1
				}>

				<!--- Set response message --->
				<cfset local.response["message"] = "Product Added">

			</cfif>

		<cfelseif arguments.action EQ "decrement" AND session.cart[arguments.productId].quantity GT 1>

			<!--- Decrement quantity of product in session variable --->
			<cfset session.cart[arguments.productId].quantity -= 1>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Quantity Decremented">

		<cfelse>

			<!--- Delete product from session variable --->
			<cfset structDelete(session.cart, arguments.productId)>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Deleted">

		</cfif>

		<!--- Do the math --->
		<cfif structKeyExists(session.cart, arguments.productId)>
			<cfset local.unitPrice = session.cart[arguments.productId].unitPrice>
			<cfset local.unitTax = session.cart[arguments.productId].unitTax>
			<cfset local.quantity = session.cart[arguments.productId].quantity>
			<cfset local.actualPrice = local.unitPrice * local.quantity>
			<cfset local.price = local.actualPrice + (local.unitPrice * (local.unitTax / 100) * local.quantity)>

			<!--- Package data into struct --->
			<cfset local.response["data"] = {
				"price" = local.price,
				"actualPrice" = local.actualPrice,
				"quantity" = session.cart[arguments.productId].quantity
			}>
		</cfif>

		<!--- Do the math on total price and tax in cart --->
		<cfset local.priceDetails = session.cart.reduce(function(result,key,value){
			result.totalActualPrice += value.unitPrice * value.quantity;
			result.totalPrice += value.unitPrice * ( 1 + (value.unitTax/100)) * value.quantity;
			result.totalTax += value.unitPrice * value.unitTax / 100 * value.quantity;
			return result;
		},{totalActualPrice = 0, totalPrice = 0, totalTax = 0})>
		<cfset local.totalPrice = local.priceDetails.totalPrice>
		<cfset local.totalActualPrice = local.priceDetails.totalActualPrice>
		<cfset local.totalTax = local.priceDetails.totalTax>

		<!--- Append total price and tax to data struct --->
		<cfset structAppend(local.response["data"], {
			"totalPrice" = local.totalPrice,
			"totalActualPrice" = local.totalActualPrice,
			"totalTax" = local.totalTax
		})>

		<cfset local.response["success"] = true>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="updateCartBatch" access="public" returnType="struct" returnFormat="json">
		<cfargument name="userId" type="integer" required=true>
		<cfargument name="cartData" type="struct" required=false>

		<cfset local.response = {
			success = false,
			message = ""
		}>

		<cftry>
			<cftransaction>
				<!--- Get all products currently in the cart --->
				<cfquery name="local.qryCartProducts">
					SELECT fldProductId FROM tblCart WHERE fldUserId = <cfqueryparam value="#arguments.userId#" cfsqltype="integer">
				</cfquery>

				<!--- Get product Ids from cart table --->
				<cfset local.cartProductIdList = valueList(local.qryCartProducts.fldProductId)>

				<!--- Encrypt product ids from cart --->
				<cfset local.cartProductIdList = listMap(local.cartProductIdList, function(item) {
					return encryptText(item);
				})>

				<!--- Get product Ids from session variable --->
				<cfset local.productIdList = structKeyList(arguments.cartData)>

				<!--- Separate product ids into groups --->
				<cfset local.updatedIdList = listFilter(local.productIdList,function(id){
					return listContainsNoCase(cartProductIdList, id);
				})>
				<cfset local.deleteIdList = listFilter(local.cartProductIdList,function(id){
					return NOT listContainsNoCase(productIdList, id);
				})>
				<cfset local.insertIdList = listFilter(local.productIdList, function(id) {
					return NOT listContainsNoCase(cartProductIdList, id);
				})>

				<!--- Decrypt some ids --->
				<cfset local.updatedIdList = listMap(local.updatedIdList, function(item) {
					return decryptText(item);
				})>
				<cfset local.deleteIdList = listMap(local.deleteIdList, function(item) {
					return decryptText(item);
				})>

				<!--- Insert new products to cart --->
				<cfif listLen(local.insertIdList)>
					<cfquery>
						INSERT INTO
							tblCart (
								fldUserId,
								fldProductId,
								fldQuantity
							)
						VALUES
							<cfloop list="#local.insertIdList#" item="id" index="i">
								(
									<cfqueryparam value="#arguments.userId#" cfsqltype="integer">,
									<cfqueryparam value="#decryptText(id)#" cfsqltype="integer">,
									<cfqueryparam value="#arguments.cartData[id].quantity#" cfsqltype="integer">
								)
								<cfif i NEQ listLen(local.insertIdList)>,</cfif>
							</cfloop>
					</cfquery>
				</cfif>

				<!--- Update products in cart --->
				<cfif listLen(local.updatedIdList)>
					<cfquery>
						UPDATE
							tblCart
						SET
							fldQuantity = CASE fldProductId
								<cfloop list="#local.updatedIdList#" item="id" index="i">
									WHEN <cfqueryparam value="#id#" cfsqltype="integer">
									THEN <cfqueryparam value="#arguments.cartData[encryptText(id)].quantity#" cfsqltype="integer">
								</cfloop>
							END
						WHERE
							fldProductId IN (<cfqueryparam value = "#local.updatedIdList#" cfsqltype = "varchar" list = "yes">)
					</cfquery>
				</cfif>

				<!--- Delete products from cart --->
				<cfquery>
					DELETE FROM
						tblCart
					WHERE
						fldUserId = <cfqueryparam value="#arguments.userId#" cfsqltype="integer">
						AND fldProductId IN (<cfqueryparam value = "#local.deleteIdList#" cfsqltype = "varchar" list = "yes">)
				</cfquery>
			</cftransaction>

			<cfset local.response.success = true>

			<!--- Catch error --->
			<cfcatch>
				<!--- Rollback cart update if some queries fail --->
				<cftransaction action="rollback">
				<cfset local.response.message="Error: #cfcatch.message#">
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getAddress" access="public" returnType="struct">
		<cfargument name="addressId" type="string" required=false default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
		}>

		<!--- Decrypt ids--->
		<cfset local.addressId = decryptText(arguments.addressId)>

		<!--- Address Id Validation --->
		<cfif (len(arguments.addressId) NEQ 0) AND (local.addressId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] = "Address Id is invalid.">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetAddress">
			SELECT
				fldAddress_Id,
				fldFirstName,
				fldLastName,
				fldAddressLine1,
				fldAddressLine2,
				fldCity,
				fldState,
				fldPincode,
				fldPhone
			FROM
				tblAddress
			WHERE
				fldActive = 1
				<cfif structKeyExists(local, "addressId") AND trim(local.addressId) NEQ -1>
					AND fldAddress_Id = <cfqueryparam value = "#local.addressId#" cfsqltype = "integer">
				<cfelse>
					AND fldUserId = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
				</cfif>
		</cfquery>

		<cfloop query="local.qryGetAddress">
			<cfset arrayAppend(local.response.data, {
				"addressId" = encryptText(local.qryGetAddress.fldAddress_Id),
				"fullName" = local.qryGetAddress.fldFirstName & " " & local.qryGetAddress.fldLastName,
				"addressLine1" = local.qryGetAddress.fldAddressLine1,
				"addressLine2" = local.qryGetAddress.fldAddressLine2,
				"city" = local.qryGetAddress.fldCity,
				"state" = local.qryGetAddress.fldState,
				"pincode" = local.qryGetAddress.fldPincode,
				"phone" = local.qryGetAddress.fldPhone
			})>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="addAddress" access="remote" returnType="struct">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="addressLine1" type="string" required=true>
		<cfargument name="addressLine2" type="string" required=true>
		<cfargument name="city" type="string" required=true>
		<cfargument name="state" type="string" required=true>
		<cfargument name="pincode" type="string" required=true>
		<cfargument name="phone" type="string" required=true>

		<cfset local.response = {
			"message" = ""
		}>

		<cfif NOT structKeyExists(session, "userId")>
			<cfset local.response["message"] &= "Cannot proceed without loggin in">
		</cfif>

		<!--- Firstname Validation --->
		<cfif len(arguments.firstName) EQ 0>
			<cfset local.response["message"] &= "Enter first name. ">
		<cfelseif isValid("regex", arguments.firstName, "/\d/")>
			<cfset local.response["message"] &= "First name should not contain any digits. ">
		</cfif>

		<!--- Lastname Validation --->
		<cfif len(arguments.lastname) EQ 0>
			<cfset local.response["message"] &= "Enter last name. ">
		<cfelseif isValid("regex", arguments.lastName, "/\d/")>
			<cfset local.response["message"] &= "Last name should not contain any digits. ">
		</cfif>

		<!--- Address Line 1 Validation --->
		<cfif len(arguments.addressLine1) EQ 0>
			<cfset local.response["message"] &= "Enter address line 1. ">
		</cfif>

		<!--- Address Line 2 Validation --->
		<cfif len(arguments.addressLine2) EQ 0>
			<cfset local.response["message"] &= "Enter address line 2. ">
		</cfif>

		<!--- City Validation --->
		<cfif len(arguments.city) EQ 0>
			<cfset local.response["message"] &= "Enter city. ">
		<cfelseif isValid("regex", arguments.city, "/\d/")>
			<cfset local.response["message"] &= "City should not contain any digits. ">
		</cfif>

		<!--- State Validation --->
		<cfif len(arguments.state) EQ 0>
			<cfset local.response["message"] &= "Enter state. ">
		<cfelseif isValid("regex", arguments.state, "/\d/")>
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

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteAddress" access="remote" returnType="struct">
		<cfargument name="addressId" type="string" required=true default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
		}>

		<!--- Decrypt ids--->
		<cfset local.addressId = decryptText(arguments.addressId)>

		<!--- Address Id Validation --->
		<cfif (len(arguments.addressId) NEQ 0) AND (local.addressId EQ -1)>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] = "Address Id is invalid.">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryDeleteAddress">
			UPDATE
				tblAddress
			SET
				fldActive = 0,
				fldDeactivatedDate = <cfqueryparam value = "#DateTimeFormat(now(), "yyyy-MM-dd HH:mm:ss")#" cfsqltype = "timestamp">
			WHERE
				fldAddress_Id = <cfqueryparam value = "#trim(local.addressId)#" cfsqltype = "integer">
		</cfquery>

		<cfset local.response["message"] = "Address deleted succcessfully.">

		<cfreturn local.response>
	</cffunction>

	<cffunction name="editProfile" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="email" type="string" required=true>
		<cfargument name="phone" type="string" required=true>

		<cfset local.response = {
			"message" = ""
		}>

		<cfif NOT structKeyExists(session, "userId")>
			<cfset local.response["message"] &= "Cannot proceed without loggin in">
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

			<cfset local.response["message"] = "Profile Updated successfully">
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="validateCard" access="remote" returnType="struct" returnformat="json">
		<cfargument name="cardNumber" type="string" required=true>
		<cfargument name="cvv" type="string" required=true>

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>
		<cfset local.validCardNumber = "1111111111111111">
		<cfset local.validCvv = "111">

		<!--- Trim and remove dashes from card number --->
		<cfset arguments.cardNumber = replace(trim(arguments.cardNumber), "-", "", "all")>

		<!--- Validate card number --->
		<cfif NOT len(arguments.cardNumber)>
			<cfset local.response["message"] &= "Card number is required. ">
		<cfelseif (len(arguments.cardNumber) NEQ 16) OR (NOT isValid("numeric", arguments.cardNumber))>
			<cfset local.response["message"] &= "Not a valid card number. ">
		</cfif>

		<!--- Validate CVV --->
		<cfif NOT len(trim(arguments.cvv))>
			<cfset local.response["message"] &= "CVV number is required. ">
		<cfelseif (len(trim(arguments.cvv)) NEQ 3) OR (NOT isValid("numeric", arguments.cvv))>
			<cfset local.response["message"] &= "CVV is not valid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<cfif (arguments.cardNumber EQ local.validCardNumber) AND (arguments.cvv EQ local.validcvv)>
			<cfset local.response["message"] = "Validation successful">
			<cfset local.response["success"] = true>
		<cfelse>
			<cfset local.response["message"] = "Wrong Card number or CVV">
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="modifyCheckout" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">
		<cfargument name="action" type="string" required=true default="">

		<cfset local.response = {
			"success" = false,
			"message" = "",
			"data" = {}
		}>

		<!--- Decrypt ids--->
		<cfset local.productId = decryptText(arguments.productId)>

		<!--- Product Id Validation --->
		<cfif len(arguments.productId) EQ 0>
			<cfset local.response["message"] &= "Product Id should not be empty. ">
		<cfelseif local.productId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] &= "Product Id is invalid. ">
		</cfif>

		<!--- Validate Action --->
		<cfif NOT len(trim(arguments.action))>
			<cfset local.response["message"] &= "Action should not be empty. ">
		<cfelseif NOT arrayContainsNoCase(["increment", "decrement", "delete"], arguments.action)>
			<cfset local.response["message"] &= "Specified action is not valid. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfif arguments.action EQ "increment">

			<!--- Delete productId key from struct in session variable --->
			<cfset session.checkout[arguments.productId].quantity += 1>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Quantity Incremented">

		<cfelseif arguments.action EQ "decrement" AND session.checkout[arguments.productId].quantity GT 1>

			<!--- Delete productId key from struct in session variable --->
			<cfset session.checkout[arguments.productId].quantity -= 1>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Quantity Decremented">

		<cfelse>

			<!--- Delete productId key from struct in session variable --->
			<cfset structDelete(session.checkout, arguments.productId)>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Deleted">

		</cfif>

		<!--- Do the math --->
		<cfif structKeyExists(session.checkout, arguments.productId)>
			<cfset local.unitPrice = session.checkout[arguments.productId].unitPrice>
			<cfset local.unitTax = session.checkout[arguments.productId].unitTax>
			<cfset local.quantity = session.checkout[arguments.productId].quantity>
			<cfset local.actualPrice = local.unitPrice * local.quantity>
			<cfset local.price = local.actualPrice + (local.unitPrice * (local.unitTax / 100) * local.quantity)>

			<!--- Package data into struct --->
			<cfset local.response["data"] = {
				"price" = local.price,
				"actualPrice" = local.actualPrice,
				"quantity" = session.checkout[arguments.productId].quantity
			}>
		</cfif>

		<!--- Do the math on total price and tax --->
		<cfset local.priceDetails = session.checkout.reduce(function(result,key,value){
			result.totalActualPrice += value.unitPrice * value.quantity;
			result.totalPrice += value.unitPrice * ( 1 + (value.unitTax/100)) * value.quantity;
			result.totalTax += value.unitPrice * value.unitTax / 100 * value.quantity;
			return result;
		},{totalActualPrice = 0, totalPrice = 0, totalTax = 0})>
		<cfset local.totalPrice = local.priceDetails.totalPrice>
		<cfset local.totalActualPrice = local.priceDetails.totalActualPrice>
		<cfset local.totalTax = local.priceDetails.totalTax>

		<!--- Append total price and tax data into struct --->
		<cfset structAppend(local.response["data"], {
			"totalPrice" = local.totalPrice,
			"totalActualPrice" = local.totalActualPrice,
			"totalTax" = local.totalTax
		})>

		<cfset local.response["success"] = true>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="orderIdIsUnique" access="private" returnType="boolean">
		<cfargument name="orderId" type="string" required=true>
		<cfset local.result = false>

		<cfquery name="local.qryCheckOrderId">
			SELECT
				fldOrder_Id
			FROM
				tblOrder
			WHERE
				fldOrder_Id  = <cfqueryparam value = "#trim(arguments.orderId)#" cfsqltype = "varchar">
		</cfquery>

		<cfset local.result = (local.qryCheckOrderId.recordCount EQ 0)>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="createOrder" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="addressId" type="string" required=true default="">

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>

		<!--- Decrypt ids--->
		<cfset local.addressId = decryptText(arguments.addressId)>

		<!--- Check whether user is logged in --->
		<cfif NOT structKeyExists(session, "userId")>
			<cfset local.response["message"] &= "User not logged in. ">
		</cfif>

		<!--- Check whether session variable is empty or not --->
		<cfif (NOT structKeyExists(session, "checkout")) OR (structCount(session.checkout) EQ 0)>
			<cfset local.response["message"] &= "Checkout section is empty. ">
		</cfif>

		<!--- Address Id Validation --->
		<cfif NOT len(trim(arguments.addressId))>
			<cfset local.response["message"] &= "Address Id is required. ">
		<cfelseif local.addressId EQ -1>
			<!--- Value equals -1 means decryption failed --->
			<cfset local.response["message"] = "Address Id is invalid.">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif structKeyExists(local.response, "message") AND len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Create Order Id --->
		<cfset local.orderId = createUUID()>
		<cfloop condition="NOT orderIdIsUnique(orderId = local.orderId)">
			<cfset local.orderId = createUUID()>
		</cfloop>

		<!--- Variables to store total price and total tax --->
		<cfset local.totalPrice = 0>
		<cfset local.totalTax = 0>

		<!--- json array to pass to stored procedure --->
		<cfset local.productList = []>

		<!--- Loop through checkout items --->
		<cfloop collection="#session.checkout#" item="item">
			<!--- Calculate total price and tax --->
			<cfset local.totalPrice += session.checkout[item].unitPrice * ( 1 + session.checkout[item].unitTax) * session.checkout[item].quantity>
			<cfset local.totalTax += session.checkout[item].unitPrice * session.checkout[item].unitTax * session.checkout[item].quantity>

			<!--- build json array --->
			<cfset arrayAppend(local.productList, {
				"productId": decryptText(trim(item)),
				"quantity": trim(session.checkout[item].quantity)
			})>
		</cfloop>

		<!--- Convert array to JSON --->
		<cfset local.productJSON = serializeJSON(local.productList)>

		<cftry>
			<cfstoredproc procedure="spCreateOrderItems">
				<cfprocparam type="in" cfsqltype="varchar" variable="p_orderId" value="#local.orderId#">
				<cfprocparam type="in" cfsqltype="integer" variable="p_userId" value="#session.userId#">
				<cfprocparam type="in" cfsqltype="integer" variable="p_addressId" value="#local.addressId#">
				<cfprocparam type="in" cfsqltype="decimal" variable="p_totalPrice" value="#local.totalPrice#">
				<cfprocparam type="in" cfsqltype="decimal" variable="p_totalTax" value="#local.totalTax#">
				<cfprocparam type="in" cfsqltype="longvarchar" variable="p_jsonProducts" value="#local.productJSON#">
			</cfstoredproc>

			<!--- Empty cart structure in session --->
			<cfset structEach(session.checkout, function(key) {
				structDelete(session.cart, key);
			})>

			<!--- Fetch address details --->
			<cfset local.address = getAddress(
				addressId = arguments.addressId
			)>

			<!--- Send email to user --->
			<cfmail to="#session.email#" from="no-reply@shoppingcart.local" subject="Your order has been successfully placed">
				Hi #session.firstName# #session.lastName#,

				Your order was placed successfully.

				Delivery Address:
				#local.address.data[1].fullName#,
				#local.address.data[1].addressLine1#,
				#local.address.data[1].addressLine2#,
				#local.address.data[1].city#, #local.address.data[1].state# - #local.address.data[1].pincode#,
				#local.address.data[1].phone#

				Order Id: #local.orderId#
			</cfmail>

			<!--- Clear session variable --->
			<cfset structDelete(session, "checkout")>

			<!--- Set success status --->
			<cfset local.response["success"] = true>

			<cfcatch type="any">
				<cfset local.response["success"] = false>
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getOrders" access="public" returnType="struct">
		<cfargument name="searchTerm" type="string" required=false default="">
		<cfargument name="orderId" type="string" required=false default="">

		<cfset local.response = {
			"message" = "",
			"data" = []
		}>

		<!--- Validate login --->
		<cfif NOT structKeyExists(session, "userId")>
			<cfset local.response["message"] = "User not authenticated">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetOrders">
			SELECT
				ord.fldOrder_Id,
				ord.fldOrderDate,
				ord.fldTotalPrice,
				ord.fldTotalTax,
				addr.fldAddressLine1,
				addr.fldAddressLine2,
				addr.fldCity,
				addr.fldState,
				addr.fldPincode,
				addr.fldFirstName,
				addr.fldLastName,
				addr.fldPhone,
				GROUP_CONCAT(itm.fldProductId SEPARATOR ',') AS productIds,
				GROUP_CONCAT(itm.fldQuantity SEPARATOR ',') AS quantities,
				GROUP_CONCAT(itm.fldUnitPrice SEPARATOR ',') AS unitPrices,
				GROUP_CONCAT(itm.fldUnitTax SEPARATOR ',') AS unitTaxes,
				GROUP_CONCAT(prod.fldProductName SEPARATOR ',') AS productNames,
				GROUP_CONCAT(img.fldImageFileName SEPARATOR ',') AS productImages,
				GROUP_CONCAT(brnd.fldBrandName SEPARATOR ',') AS brandNames
			FROM
				tblOrder ord
				INNER JOIN tblAddress addr ON ord.fldAddressId = addr.fldAddress_Id
				INNER JOIN tblOrderItems itm ON ord.fldOrder_Id = itm.fldOrderId
				INNER JOIN tblProduct prod ON itm.fldProductId = prod.fldProduct_Id
				INNER JOIN tblProductImages img ON prod.fldProduct_Id = img.fldProductId
					AND img.fldDefaultImage = 1
				INNER JOIN tblBrands brnd ON prod.fldBrandId = brnd.fldBrand_Id
			WHERE
				ord.fldUserId = <cfqueryparam value = "#session.userId#" cfsqltype = "varchar">
				<cfif len(trim(arguments.orderId))>
					<!--- For printing pdf for each order --->
					AND ord.fldOrder_Id = <cfqueryparam value = "#arguments.orderId#" cfsqltype = "varchar">
				<cfelse>
					<!--- When searching for orders --->
					AND ord.fldOrder_Id LIKE <cfqueryparam value = "%#trim(arguments.searchTerm)#%" cfsqltype = "varchar">
				</cfif>
			GROUP BY
				ord.fldOrder_Id
			ORDER BY
				ord.fldOrderDate DESC
		</cfquery>

		<cfloop query="local.qryGetOrders">
			<cfset arrayAppend(local.response["data"], {
				"orderId" = local.qryGetOrders.fldOrder_Id,
				"orderDate" = local.qryGetOrders.fldOrderDate,
				"totalPrice" = local.qryGetOrders.fldTotalPrice,
				"totalTax" = local.qryGetOrders.fldTotalTax,
				"addressLine1" = local.qryGetOrders.fldAddressLine1,
				"addressLine2" = local.qryGetOrders.fldAddressLine2,
				"city" = local.qryGetOrders.fldCity,
				"state" = local.qryGetOrders.fldState,
				"pincode" = local.qryGetOrders.fldPincode,
				"firstName" = local.qryGetOrders.fldFirstName,
				"lastName" = local.qryGetOrders.fldLastName,
				"phone" = local.qryGetOrders.fldPhone,
				"productIds" = listMap(local.qryGetOrders.productIds, function(item) {
					return encryptText(item);
				}),
				"quantities" = local.qryGetOrders.quantities,
				"unitPrices" = local.qryGetOrders.unitPrices,
				"unitTaxes" = local.qryGetOrders.unitTaxes,
				"productNames" = local.qryGetOrders.productNames,
				"productImages" = local.qryGetOrders.productImages,
				"brandNames" = local.qryGetOrders.brandNames
			})>
		</cfloop>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="encryptText" access="private" returnType="string">
		<cfargument name="plainText" type="string" required=true>

		<cfset local.encryptedText = encrypt(arguments.plainText, application.secretKey, "AES", "Base64")>

		<cfreturn local.encryptedText>
	</cffunction>

	<cffunction name="decryptText" access="private" returnType="string">
		<cfargument name="encryptedText" type="string" required=true>

		<!--- Handle exception in case decryption failes --->
		<cftry>
			<cfset local.decryptedText = decrypt(arguments.encryptedText, application.secretKey, "AES", "Base64")>

			<cfreturn local.decryptedText>

			<cfcatch type="any">
				<!--- Return -1 if decryption fails --->
				<cfreturn "-1">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="logOut" access="remote" returnType="void">
		<!--- Delete roleId from session immediately so that page will be redirected on location.reload --->
		<cfset structDelete(session, "roleId")>

		<!--- Update cart asynchronously --->
		<cfthread name="cartUpdateThread">
			<cfif structKeyExists(session, "cartVisit")>
				<cfset updateCartBatch(
					userId = session.userId,
					cartData = session.cart
				)>
			</cfif>

			<!--- Clear session --->
			<cfset structClear(session)>
		</cfthread>
	</cffunction>
</cfcomponent>
