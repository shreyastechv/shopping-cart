<cfcomponent>
	<cffunction name="trimArguments" access="private" returnType="struct">
		<cfargument name="args" type="struct" required=true>

		<cfloop collection="#arguments.args#" item="arg">
			<cfset arguments.args[arg] = trim(arguments.args[arg])>
		</cfloop>

		<cfreturn arguments.args>
	</cffunction>

	<cffunction name="signup" access="public" returnType="struct">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="email" type="string" required=true>
		<cfargument name="phone" type="string" required=true>
		<cfargument name="password" type="string" required=true>
		<cfargument name="confirmPassword" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Trim arguments --->
		<cfset arguments = trimArguments(arguments)>

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

		<!--- Email Validation --->
		<cfif len(arguments.email) EQ 0>
			<cfset local.response["message"] &= "Enter an email address. ">
		<cfelseif NOT isValid("email", arguments.email)>
			<cfset local.response["message"] &= "Invalid email. ">
		</cfif>

		<!--- Phone Number Validation --->
		<cfif len(arguments.phone) EQ 0>
			<cfset local.response["message"] &= "Enter an phone number. ">
		<cfelseif NOT isValid("regex", arguments.phone, "^\d{10}$")>
			<cfset local.response["message"] &= "Phone number should be 10 digits long. ">
		</cfif>

		<!--- Password Validation --->
		<cfif len(arguments.password) EQ 0>
			<cfset local.response["message"] &= "Enter a password. ">
		</cfif>

		<!--- Confirm Password Validation --->
		<cfif len(arguments.confirmPassword) EQ 0>
			<cfset local.response["message"] &= "Confirm the password. ">
		<cfelseif arguments.password NEQ arguments.confirmPassword>
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
			<cfset local.hashedPassword = hash(arguments.password & local.saltString, "SHA-512", "UTF-8", 50)>
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

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Trim arguments --->
		<cfset arguments = trimArguments(arguments)>

		<!--- UserInput Validation --->
		<cfif len(trim(arguments.userInput)) EQ 0>
			<cfset local.response["message"] &= "Enter an Email or Phone Number. ">
		<cfelseif isValid("integer", arguments.userInput) AND arguments.userInput GT 0>
			<cfif len(arguments.userInput) NEQ 10>
				<cfset local.response["message"] &= "Phone number should be 10 digits long. ">
			</cfif>
		<cfelse>
			<cfif NOT isValid("email", arguments.userInput)>
				<cfset local.response["message"] &= "Invalid email. ">
			</cfif>
		</cfif>

		<!--- Password Validation --->
		<cfif len(arguments.password) EQ 0>
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
			<cfif local.qryCheckUser.fldHashedPassword EQ hash(arguments.password & local.qryCheckUser.fldUserSaltString, "SHA-512", "UTF-8", 50)>
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

	<cffunction name="getCategories" access="public" returnType="query">
		<cfquery name="local.qryGetCategories">
			SELECT
				c.fldCategory_Id,
				c.fldCategoryName
			FROM
				tblCategory c
			WHERE
				c.fldActive = 1
				-- Below code is to make sure to return only no-empty categories
				AND EXISTS (
					SELECT
						1
					FROM
						tblSubCategory sc
					WHERE
						sc.fldCategoryId = c.fldCategory_Id
						AND sc.fldActive = 1
				)
		</cfquery>

		<cfreturn local.qryGetCategories>
	</cffunction>

	<cffunction name="modifyCategory" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="categoryId" type="string" required=true>
		<cfargument name="categoryName" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Category Id Validation --->
		<cfif len(arguments.categoryId) AND NOT isValid("integer", arguments.categoryId)>
			<cfset local.response["message"] &= "Category Id should be an integer">
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
			<cfif len(trim(arguments.categoryId))>
				<cfquery name="qryEditCategory">
					UPDATE
						tblCategory
					SET
						fldCategoryName = <cfqueryparam value = "#trim(arguments.categoryName)#" cfsqltype = "varchar">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					WHERE
						fldCategory_Id = <cfqueryparam value = "#trim(arguments.categoryId)#" cfsqltype = "integer">
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
				<cfset local.response["categoryId"] = local.resultAddCategory.GENERATED_KEY>
				<cfset local.response["message"] = "Category Added">
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteCategory" access="remote" returnType="void">
		<cfargument name="categoryId" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Category Id Validation --->
		<cfif len(arguments.categoryId) EQ 0>
			<cfset local.response["message"] &= "Category Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.categoryId)>
			<cfset local.response["message"] &= "Category Id should be an integer">
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
				fldSubCategoryId IN (
					SELECT
						fldSubCategory_Id
					FROM
						tblSubCategory
					WHERE
						fldCategoryId = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "integer">
				);
		</cfquery>

		<cfquery name="qryDeleteSubCategory">
			UPDATE
				tblSubCategory
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldCategoryId = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "integer">
		</cfquery>

		<cfquery name="qryDeleteCategory">
			UPDATE
				tblCategory
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldCategory_Id = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "integer">
		</cfquery>
	</cffunction>

	<cffunction name="getSubCategories" access="remote" returnType="query" returnFormat="json">
		<cfargument name="categoryId" type="string" required=false>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Category Id Validation --->
		<cfif structKeyExists(arguments, "categoryId") AND isValid("integer", arguments.categoryId) EQ false>
			<cfset local.response["message"] &= "Category Id should be an integer">
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
				<cfif structKeyExists(arguments, "categoryId") AND len(trim(arguments.categoryId))>
					AND sc.fldCategoryId = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "integer">
				</cfif>
		</cfquery>

		<cfreturn local.qryGetSubCategories>
	</cffunction>

	<cffunction name="modifySubCategory" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="subCategoryId" type="string" required=true>
		<cfargument name="subCategoryName" type="string" required=true>
		<cfargument name="categoryId" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- SubCategory Id Validation --->
		<cfif len(arguments.subCategoryId) AND NOT isValid("integer", arguments.subCategoryId)>
			<cfset local.response["message"] &= "SubCategory Id should be an integer">
		</cfif>

		<!--- SubCategory Name Validation --->
		<cfif len(arguments.subCategoryName) EQ 0>
			<cfset local.response["message"] &= "SubCategory Name should not be empty. ">
		</cfif>

		<!--- Category Id Validation --->
		<cfif len(arguments.categoryId) EQ 0>
			<cfset local.response["message"] &= "Category Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.categoryId)>
			<cfset local.response["message"] &= "Category Id should be an integer">
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
				AND fldCategoryId = <cfqueryparam value = "#trim(arguments.categoryId)#" cfsqltype = "integer">
				AND fldSubCategory_Id != <cfqueryparam value = "#val(trim(arguments.subCategoryId))#" cfsqltype = "integer">
				AND fldActive = 1
		</cfquery>

		<cfif local.qryCheckSubCategory.recordCount>
			<cfset local.response["message"] = "SubCategory already exists!">
		<cfelse>
			<cfif len(trim(arguments.subCategoryId))>
				<cfquery name="qryEditSubCategory">
					UPDATE
						tblSubCategory
					SET
						fldSubCategoryName = <cfqueryparam value = "#trim(arguments.subCategoryName)#" cfsqltype = "varchar">,
						fldCategoryId = <cfqueryparam value = "#trim(arguments.categoryId)#" cfsqltype = "integer">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					WHERE
						fldSubCategory_Id = <cfqueryparam value = "#trim(arguments.subCategoryId)#" cfsqltype = "integer">
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
						<cfqueryparam value = "#trim(arguments.categoryId)#" cfsqltype = "integer">,
						<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					)
				</cfquery>
				<cfset local.response["subCategoryId"] = local.resultAddSubCategory.GENERATED_KEY>
				<cfset local.response["message"] = "SubCategory Added">
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteSubCategory" access="remote" returnType="void">
		<cfargument name="subCategoryId" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- SubCategory Id Validation --->
		<cfif len(arguments.subCategoryId) EQ 0>
			<cfset local.response["message"] &= "SubCategory Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.subCategoryId)>
			<cfset local.response["message"] &= "SubCategory Id should be an integer">
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
				fldSubCategoryId = <cfqueryparam value = "#arguments.subCategoryId#" cfsqltype = "integer">
		</cfquery>

		<cfquery name="qryDeleteSubCategory">
			UPDATE
				tblSubCategory
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldSubCategory_Id = <cfqueryparam value = "#arguments.subCategoryId#" cfsqltype = "integer">
		</cfquery>
	</cffunction>

	<cffunction name="getProducts" access="remote" returnType="query" returnFormat="json">
		<cfargument name="subCategoryId" type="string" required=false default="">
		<cfargument name="productId" type="string" required=false default="">
		<cfargument name="random" type="string" required=false default="0">
		<cfargument name="limit" type="string" required="false" default="">
		<cfargument name="offset" type="string" required="false" default=0>
		<cfargument name="sort" type="string" required="false" default="">
		<cfargument name="min" type="string" required="false" default="0">
		<cfargument name="max" type="string" required="false" default="">
		<cfargument name="searchTerm" type="string" required="false" default="">

 		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- SubCategory Id Validation --->
		<cfif len(trim(arguments.subCategoryId)) AND isValid("integer", arguments.subCategoryId) EQ false>
			<cfset local.response["message"] &= "SubCategory Id should be an integer">
		</cfif>

		<!--- Product ID Validation --->
		<cfif len(trim(arguments.productId)) AND isValid("integer", arguments.productId) EQ false>
			<cfset local.response["message"] &= "Product Id should be an integer">
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
				<cfif len(trim(arguments.subCategoryId)) AND arguments.subCategoryId NEQ 0>
					AND p.fldSubCategoryId = <cfqueryparam value = "#arguments.subCategoryId#" cfsqltype = "integer">
				<cfelseif len(trim(arguments.productId)) AND arguments.productId NEQ 0>
					AND p.fldProduct_Id = <cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">
				</cfif>

				<cfif len(trim(arguments.max))>
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

			<cfif arguments.random EQ 1>
				ORDER BY
					RAND()
			<cfelseif len(trim(arguments.sort))>
				ORDER BY
					p.fldPrice #arguments.sort#
			</cfif>

			<cfif len(trim(arguments.limit))>
				LIMIT <cfqueryparam value = "#val(arguments.limit)#" cfsqltype = "integer">
				<cfif len(trim(arguments.offset))>
					OFFSET <cfqueryparam value = "#arguments.offset#" cfsqltype = "integer">
				</cfif>
			</cfif>
		</cfquery>

		<cfreturn local.qryGetProducts>
	</cffunction>

	<cffunction name="getBrands" access="public" returnType="query">
		<cfquery name="local.qryGetBrands">
			SELECT
				fldBrand_Id,
				fldBrandName
			FROM
				tblBrands
		</cfquery>

		<cfreturn local.qryGetBrands>
	</cffunction>

	<cffunction name="modifyProduct" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true>
		<cfargument name="categorySelect" type="string" required=true>
		<cfargument name="subCategorySelect" type="string" required=true>
		<cfargument name="productName" type="string" required=true>
		<cfargument name="brandSelect" type="string" required=true>
		<cfargument name="productDesc" type="string" required=true>
		<cfargument name="productPrice" type="string" required=true>
		<cfargument name="productTax" type="string" required=true>
		<cfargument name="productImage" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Product Id Validation --->
		<cfif len(arguments.productId) AND NOT isValid("integer", arguments.productId)>
			<cfset local.response["message"] &= "Product Id should be an integer">
		</cfif>

		<!--- Category Id Validation --->
		<cfif len(arguments.categorySelect) EQ 0>
			<cfset local.response["message"] &= "Category Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.categorySelect)>
			<cfset local.response["message"] &= "Category Id should be an integer">
		</cfif>

		<!--- SubCategory Id Validation --->
		<cfif len(arguments.subCategorySelect) EQ 0>
			<cfset local.response["message"] &= "SubCategory Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.subCategorySelect)>
			<cfset local.response["message"] &= "SubCategory Id should be an integer">
		</cfif>

		<!--- Product Description Validation --->
		<cfif len(arguments.productDesc) EQ 0>
			<cfset local.response["message"] &= "Product Description should not be empty. ">
		</cfif>

		<!--- Brand Id Validation --->
		<cfif len(arguments.brandSelect) EQ 0>
			<cfset local.response["message"] &= "Brand Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.brandSelect)>
			<cfset local.response["message"] &= "Brand Id should be an integer">
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
				AND fldSubCategoryId = <cfqueryparam value = "#trim(arguments.subCategorySelect)#" cfsqltype = "integer">
				AND fldProduct_Id != <cfqueryparam value = "#val(trim(arguments.productId))#" cfsqltype = "integer">
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

			<cfif len(trim(arguments.productId))>
				<cfquery name="qryEditProduct">
					UPDATE
						tblProduct
					SET
						fldProductName = <cfqueryparam value = "#trim(arguments.productName)#" cfsqltype = "varchar">,
						fldSubCategoryId = <cfqueryparam value = "#trim(arguments.subCategorySelect)#" cfsqltype = "integer">,
						fldBrandId = <cfqueryparam value = "#trim(arguments.brandSelect)#" cfsqltype = "integer">,
						fldDescription = <cfqueryparam value = "#trim(arguments.productDesc)#" cfsqltype = "varchar">,
						fldPrice = <cfqueryparam value = "#trim(arguments.productPrice)#" cfsqltype = "decimal">,
						fldTax = <cfqueryparam value = "#trim(arguments.productTax)#" cfsqltype = "decimal">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					WHERE
						fldProduct_Id = <cfqueryparam value = "#val(trim(arguments.productId))#" cfsqltype = "integer">
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
						<cfqueryparam value = "#trim(arguments.subCategorySelect)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#trim(arguments.brandSelect)#" cfsqltype = "integer">,
						<cfqueryparam value = "#trim(arguments.productDesc)#" cfsqltype = "varchar">,
						<cfqueryparam value = "#val(arguments.productPrice)#" cfsqltype = "decimal" scale = "2">,
						<cfqueryparam value = "#val(arguments.productTax)#" cfsqltype = "decimal" scale = "2">,
						<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					)
				</cfquery>
				<cfset local.response["productId"] = local.resultAddProduct.GENERATED_KEY>
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
								<cfif len(trim(arguments.productId))>
									<cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">,
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
		<cfargument name="productId" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Product Id Validation --->
		<cfif len(arguments.productId) EQ 0>
			<cfset local.response["message"] &= "Product Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.productId)>
			<cfset local.response["message"] &= "Product Id should be an integer">
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
				fldProduct_Id = <cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">
		</cfquery>

		<cfquery name="qryDeleteProductImages">
			UPDATE
				tblProductImages
			SET
				fldActive = 0,
				fldDeactivatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">,
				fldDeactivatedDate = <cfqueryparam value = "#DateTimeFormat(now(), "yyyy-MM-dd HH:mm:ss")#" cfsqltype = "timestamp">
			WHERE
				fldProductId = <cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">
		</cfquery>

	</cffunction>

	<cffunction name="getProductImages" access="remote" returnType="array" returnFormat="json">
		<cfargument name="productId" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">
		<cfset local.imageArray = []>

		<!--- Product Id Validation --->
		<cfif len(arguments.productId) EQ 0>
			<cfset local.response["message"] &= "Product Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.productId)>
			<cfset local.response["message"] &= "Product Id should be an integer">
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
				fldProductId = <cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">
		</cfquery>

		<cfloop query="local.qryGetImages">
			<cfset local.imageStruct = {
				"imageId" = local.qryGetImages.fldProductImage_Id,
				"imageFileName" = local.qryGetImages.fldImageFileName,
				"defaultImage" = local.qryGetImages.fldDefaultImage
			}>
			<cfset arrayAppend(local.imageArray, local.imageStruct)>
		</cfloop>

		<cfreturn local.imageArray>
	</cffunction>

	<cffunction name="setDefaultImage" access="remote" returnType="void">
		<cfargument name="imageId" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Image Id Validation --->
		<cfif len(arguments.imageId) EQ 0>
			<cfset local.response["message"] &= "Image Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.imageId)>
			<cfset local.response["message"] &= "Image Id should be an integer">
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
					fldProductImage_Id = <cfqueryparam value="#trim(arguments.imageId)#" cfsqltype="integer">
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
				fldProductImage_Id = <cfqueryparam value = "#trim(arguments.imageId)#" cfsqltype = "integer">
		</cfquery>
	</cffunction>

	<cffunction name="deleteImage" access="remote" returnType="void">
		<cfargument name="imageId" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Image Id Validation --->
		<cfif len(arguments.imageId) EQ 0>
			<cfset local.response["message"] &= "Image Id should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.imageId)>
			<cfset local.response["message"] &= "Image Id should be an integer">
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
				fldActive = 1
			WHERE
				fldProductImage_Id = <cfqueryparam value = "#trim(arguments.imageId)#" cfsqltype = "integer">
		</cfquery>
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
			WHERE
				c.fldUserId = <cfqueryparam value = "#trim(session.userId)#" cfsqltype = "integer">
		</cfquery>

		<cfloop query="local.qryGetCart">
			<cfset local.cartItems[local.qryGetCart.fldProductId] = {
				"cartId" = local.qryGetCart.fldCart_Id,
				"quantity" = local.qryGetCart.fldQuantity,
				"unitPrice" = local.qryGetCart.fldPrice,
				"unitTax" = local.qryGetCart.fldTax
			}>
		</cfloop>

		<cfreturn local.cartItems>
	</cffunction>

	<cffunction name="modifyCart" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="productId" type="string" required=true default="">
		<cfargument name="action" type="string" required=true default="">

		<cfset local.response = {}>
		<cfset local.response["success"] = false>
		<cfset local.response["message"] = "">
		<cfset local.response["data"] = {}>

		<!--- Validate productId --->
		<cfif NOT len(trim(arguments.productId))>
			<cfset local.response["message"] &= "Product ID should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.productId)>
			<cfset local.response["message"] &= "Product ID should be an integer. ">
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

		<!--- Check whether the item is present in cart --->
		<cfquery name="local.qryCheckCart">
			SELECT
				fldCart_Id
			FROM
				tblCart
			WHERE
				fldProductId = <cfqueryparam value = "#trim(arguments.productId)#" cfsqltype = "integer">
				AND fldUserId = <cfqueryparam value = "#trim(session.userId)#" cfsqltype = "integer">
		</cfquery>

		<!--- Continue with code execution if validation succeeds --->
		<cfif arguments.action EQ "increment">

			<cfif local.qryCheckCart.recordCount>
				<!--- Update cart in case it already have the product --->
				<cfquery name="local.qryEditCart">
					UPDATE
						tblCart
					SET
						fldQuantity = fldQuantity + 1
					WHERE
						fldProductId = <cfqueryparam value = "#trim(arguments.productId)#" cfsqltype = "integer">
						AND fldUserId = <cfqueryparam value = "#trim(session.userId)#" cfsqltype = "integer">
				</cfquery>

				<!--- Increment quantity of product in session variable --->
				<cfset session.cart[arguments.productId].quantity += 1>

				<!--- Set response message --->
				<cfset local.response["message"] = "Product Quantity Incremented">

			<cfelse>
				<!--- Get Product Into --->
				<cfset local.productInfo = getProducts(
					productId = arguments.productId
				)>

				<!--- Add product to cart in case it do not have it already --->
				<cfquery name="local.qryAddToCart" result="local.resultAddToCart">
					INSERT INTO
						tblCart (
							fldUserId,
							fldProductId,
							fldQuantity
						)
					VALUES (
						<cfqueryparam value = "#trim(session.userId)#" cfsqltype = "integer">,
						<cfqueryparam value = "#trim(arguments.productId)#" cfsqltype = "integer">,
						1
					)
				</cfquery>

				<!--- Add product to session variable --->
				<cfset session.cart[arguments.productId] = {
					"cartId" = local.resultAddToCart.GENERATED_KEY,
					"quantity" = 1,
					"unitPrice" = local.productInfo.fldPrice,
					"unitTax" = local.productInfo.fldTax
				}>

				<!--- Set response message --->
				<cfset local.response["message"] = "Product Added">

			</cfif>

		<cfelseif arguments.action EQ "decrement" AND session.cart[arguments.productId].quantity GT 1>

			<!--- Decrement product quantity in cart --->
			<cfquery name="local.qryDecrItem">
				UPDATE
					tblCart
				SET
					fldQuantity = fldQuantity - 1
				WHERE
					fldProductId = <cfqueryparam value = "#trim(arguments.productId)#" cfsqltype = "integer">
			</cfquery>

			<!--- Decrement quantity of product in session variable --->
			<cfset session.cart[arguments.productId].quantity -= 1>

			<!--- Set response message --->
			<cfset local.response["message"] = "Product Quantity Decremented">

		<cfelse>

			<!--- Delete product from cart --->
			<cfquery name="local.qryDeleteItem">
				DELETE FROM
					tblCart
				WHERE
					fldProductId = <cfqueryparam value = "#trim(arguments.productId)#" cfsqltype = "integer">
			</cfquery>

			<!--- Delete productId key from struct in session variable --->
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

	<cffunction name="getAddress" access="public" returnType="array">
		<cfargument name="addressId" type="string" required=false>

		<cfset local.addresses = []>

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
				<cfif structKeyExists(arguments, "addressId") AND len(trim(arguments.addressId))>
					AND fldAddress_Id = <cfqueryparam value = "#arguments.addressId#" cfsqltype = "integer">
				<cfelse>
					AND fldUserId = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
				</cfif>
		</cfquery>

		<cfloop query="local.qryGetAddress">
			<cfset arrayAppend(local.addresses, {
				"addressId" = local.qryGetAddress.fldAddress_Id,
				"fullName" = local.qryGetAddress.fldFirstName & " " & local.qryGetAddress.fldLastName,
				"addressLine1" = local.qryGetAddress.fldAddressLine1,
				"addressLine2" = local.qryGetAddress.fldAddressLine2,
				"city" = local.qryGetAddress.fldCity,
				"state" = local.qryGetAddress.fldState,
				"pincode" = local.qryGetAddress.fldPincode,
				"phone" = local.qryGetAddress.fldPhone
			})>
		</cfloop>

		<cfreturn local.addresses>
	</cffunction>

	<cffunction name="addAddress" access="public" returnType="void">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="addressLine1" type="string" required=true>
		<cfargument name="addressLine2" type="string" required=true>
		<cfargument name="city" type="string" required=true>
		<cfargument name="state" type="string" required=true>
		<cfargument name="pincode" type="string" required=true>
		<cfargument name="phone" type="string" required=true>

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
	</cffunction>

	<cffunction name="deleteAddress" access="remote" returnType="void">
		<cfargument name="addressId" type="string" required=true>

		<cfquery name="local.qryDeleteAddress">
			UPDATE
				tblAddress
			SET
				fldActive = 0,
				fldDeactivatedDate = <cfqueryparam value = "#DateTimeFormat(now(), "yyyy-MM-dd HH:mm:ss")#" cfsqltype = "timestamp">
			WHERE
				fldAddress_Id = <cfqueryparam value = "#trim(arguments.addressId)#" cfsqltype = "integer">
		</cfquery>
	</cffunction>

	<cffunction name="editProfile" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="firstName" type="string" required=true>
		<cfargument name="lastName" type="string" required=true>
		<cfargument name="email" type="string" required=true>
		<cfargument name="phone" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

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

		<cfif (local.qryCheckUser.recordCount NEQ 1) OR (local.qryCheckUser.fldUser_Id NEQ session.userId)>
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

		<cfset local.response = {}>
		<cfset local.response["success"] = false>
		<cfset local.response["message"] = "">
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

		<cfset local.response = {}>
		<cfset local.response["success"] = false>
		<cfset local.response["message"] = "">
		<cfset local.response["data"] = {}>

		<!--- Validate productId --->
		<cfif NOT len(trim(arguments.productId))>
			<cfset local.response["message"] &= "Product ID should not be empty. ">
		<cfelseif NOT isValid("integer", arguments.productId)>
			<cfset local.response["message"] &= "Product ID should be an integer. ">
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

	<cffunction name="createOrder" access="remote" returnType="struct">
		<cfargument name="addressId" type="string" required=true>

		<cfset local.response = {}>
		<cfset local.response["success"] = false>
		<cfset local.response["message"] = "">

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
		<cfelseif NOT isValid("integer", arguments.addressId)>
			<cfset local.response["message"] &= "Address Id should be an integer. ">
		</cfif>

		<!--- Return message if validation fails --->
		<cfif structKeyExists(local.response, "message") AND len(trim(local.response.message))>
			<cfreturn local.response>
		</cfif>

		<!--- Create Order Id --->
		<cfset local.orderId = createUUID()>

		<!--- Calculate Total price and Total tax --->
		<cfset local.priceDetails = session.cart.reduce(function(result,key,value){
			result.totalPrice += value.unitPrice * ( 1 + value.unitTax) * value.quantity;
			result.totalTax += value.unitPrice * value.unitTax * value.quantity;
			return result;
		},{totalPrice = 0, totalTax = 0})>

		<!--- Insert into order table --->
		<cfquery name="local.qryCreateOrder">
			INSERT INTO
				tblOrder (
					fldOrder_Id,
					fldUserId,
					fldAddressId,
					fldTotalPrice,
					fldTotalTax
				)
			VALUES (
				<cfqueryparam value = "#trim(local.orderId)#" cfsqltype = "varchar">,
				<cfqueryparam value = "#trim(session.userId)#" cfsqltype = "integer">,
				<cfqueryparam value = "#trim(arguments.addressId)#" cfsqltype = "varchar">,
				<cfqueryparam value = "#trim(local.priceDetails.totalPrice)#" cfsqltype = "decimal">,
				<cfqueryparam value = "#trim(local.priceDetails.totalTax)#" cfsqltype = "decimal">
			)
		</cfquery>

		<!--- Insert into order items table --->
		<cfquery name="local.qryCreateOrderItems">
			INSERT INTO
				tblOrderItems (
					fldOrderId,
					fldProductId,
					fldQuantity,
					fldUnitPrice,
					fldUnitTax
				)
			VALUES
			<cfset local.index = 1>
			<cfloop collection="#session.checkout#" item="local.productId">
				(
					<cfqueryparam value = "#trim(local.orderId)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(local.productId)#" cfsqltype = "integer">,
					<cfqueryparam value = "#trim(session.checkout[local.productId].quantity)#" cfsqltype = "varchar">,
					<cfqueryparam value = "#trim(session.checkout[local.productId].unitPrice)#" cfsqltype = "decimal">,
					<cfqueryparam value = "#trim(session.checkout[local.productId].unitTax)#" cfsqltype = "decimal">
				)
				<cfif local.index LT structCount(session.checkout)>
					,
				</cfif>
				<cfset local.index += 1>
			</cfloop>
		</cfquery>

		<!--- Delete ordered products from cart table --->
		<cfquery name="local.qryDeleteCart">
			DELETE FROM
				tblCart
			WHERE
				fldUserId = <cfqueryparam value = "#trim(session.userId)#" cfsqltype = "integer">
				AND fldProductId IN (#structKeyList(session.checkout)#)
		</cfquery>

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
			#local.address[1].fullName#,
			#local.address[1].addressLine1#,
			#local.address[1].addressLine2#,
			#local.address[1].city#, #local.address[1].state# - #local.address[1].pincode#,
			#local.address[1].phone#

			Order Id: #local.orderId#
        </cfmail>

		<!--- Clear session variable --->
		<cfset structDelete(session, "checkout")>

		<!--- Set success status --->
		<cfset local.response["success"] = true>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="getOrders" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="searchTerm" type="string" required=false default="">

		<cfset local.response = {}>
		<cfset local.response["message"] = "">
		<cfset local.response["data"] = []>

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
					AND img.fldActive = 1
					AND img.fldDefaultImage = 1
				INNER JOIN tblBrands brnd ON prod.fldBrandId = brnd.fldBrand_Id
			WHERE
				ord.fldUserId = <cfqueryparam value = "#session.userId#" cfsqltype = "varchar">
				AND ord.fldOrder_Id LIKE <cfqueryparam value = "%#arguments.searchTerm#%" cfsqltype = "varchar">
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

	<cffunction name="downloadInvoice" access="remote" returnType="void">
		<cfargument name="orderId" type="string" required=true>
	</cffunction>

	<cffunction name="encryptUrlParam" access="public" returnType="string">
		<cfargument name="urlParam" type="string" required=true>

		<cfset local.encryptedParam = encrypt(arguments.urlParam, application.secretKey, "AES", "Base64")>
		<cfset local.encodedParam = urlEncodedFormat(local.encryptedParam)>

		<cfreturn local.encodedParam>
	</cffunction>

	<cffunction name="decryptUrlParam" access="public" returnType="string">
		<cfargument name="urlParam" type="string" required=true>

		<!--- Handle exception in case decryption failes --->
		<cftry>
			<!--- URL Decode not needed since it is handled by cfml page --->
			<!--- <cfset local.decodedParam = urlDecode(arguments.urlParam)> --->
			<cfset local.decryptedParam = decrypt(arguments.urlParam, application.secretKey, "AES", "Base64")>

			<cfreturn local.decryptedParam>

			<cfcatch type="any">
				<!--- Return -1 if decryption fails --->
				<cfreturn "-1">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="logOut" access="remote" returnType="void">
		<cfset structClear(session)>
	</cffunction>
</cfcomponent>
