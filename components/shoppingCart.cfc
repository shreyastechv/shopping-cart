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
		<cfelseif NOT isValid("regex", arguments.firstName, "[^0-9]+")>
			<cfset local.response["message"] &= "First name should not contain any digits. ">
		</cfif>

		<!--- Lastname Validation --->
		<cfif len(arguments.lastname) EQ 0>
			<cfset local.response["message"] &= "Enter last name. ">
		<cfelseif NOT isValid("regex", arguments.lastname, "[^0-9]+")>
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
		<cfquery name="local.qryCheckUser" dataSource="shoppingCart">
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
			<cfquery name="local.qryAddUser" dataSource="shoppingCart">
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
		<cfquery name="local.qryCheckUser" dataSource="shoppingCart">
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
				(fldEmail = <cfqueryparam value = "#trim(arguments.userInput)#" cfsqltype = "varchar">
				OR fldPhone = <cfqueryparam value = "#trim(arguments.userInput)#" cfsqltype = "varchar">)
				AND fldActive = 1
		</cfquery>

		<cfif local.qryCheckUser.recordCount>
			<cfif local.qryCheckUser.fldHashedPassword EQ hash(arguments.password & local.qryCheckUser.fldUserSaltString, "SHA-512", "UTF-8", 50)>
				<cfset session.userFullname = local.qryCheckUser.fldFirstName & " " & local.qryCheckUser.fldLastName>
				<cfset session.userId = local.qryCheckUser.fldUser_Id>
				<cfset session.roleId = local.qryCheckUser.fldRoleId>
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
		<cfquery name="local.qryGetCategories" dataSource="shoppingCart">
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
		<cfquery name="local.qryCheckCategory" dataSource="shoppingCart">
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
				<cfquery name="qryEditCategory" dataSource="shoppingCart">
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
				<cfquery name="local.qryAddCategory" result="local.resultAddCategory" dataSource="shoppingCart">
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
		<cfquery name="qryDeleteProducts" dataSource="shoppingCart">
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

		<cfquery name="qryDeleteSubCategory" dataSource="shoppingCart">
			UPDATE
				tblSubCategory
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldCategoryId = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "integer">
		</cfquery>

		<cfquery name="qryDeleteCategory" dataSource="shoppingCart">
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
		<cfquery name="local.qryGetSubCategories" dataSource="shoppingCart">
			SELECT
				fldSubCategory_Id,
				fldSubCategoryName
			FROM
				tblSubCategory
			WHERE
				fldCategoryId = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "integer">
				AND fldActive = 1
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
		<cfquery name="local.qryCheckSubCategory" dataSource="shoppingCart">
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
				<cfquery name="qryEditSubCategory" dataSource="shoppingCart">
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
				<cfquery name="local.qryAddSubCategory" result="local.resultAddSubCategory" dataSource="shoppingCart">
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
		<cfquery name="qryDeleteProducts" dataSource="shoppingCart">
			UPDATE
				tblProduct
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldSubCategoryId = <cfqueryparam value = "#arguments.subCategoryId#" cfsqltype = "integer">
		</cfquery>

		<cfquery name="qryDeleteSubCategory" dataSource="shoppingCart">
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
		<cfquery name="local.qryGetProducts" dataSource="shoppingCart">
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
				LEFT JOIN tblBrands b ON p.fldBrandId = b.fldBrand_Id
				LEFT JOIN tblProductImages i ON p.fldProduct_Id = i.fldProductId
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
			</cfif>
		</cfquery>

		<cfreturn local.qryGetProducts>
	</cffunction>

	<cffunction name="getBrands" access="public" returnType="query">
		<cfquery name="local.qryGetBrands" dataSource="shoppingCart">
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
		<cfquery name="local.qryCheckProduct" dataSource="shoppingCart">
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
				<cfquery name="qryEditProduct" dataSource="shoppingCart">
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
				<cfquery name="local.qryAddProduct" result="local.resultAddProduct" dataSource="shoppingCart">
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
				<cfquery name="qryAddImages" dataSource="shoppingCart">
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

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="qryDeleteProducts" dataSource="shoppingCart">
			UPDATE
				tblProduct
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
			WHERE
				fldProduct_Id = <cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">
		</cfquery>

		<cfquery name="qryDeleteProductImages" dataSource="shoppingCart">
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

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="local.qryGetImages" dataSource="shoppingCart">
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

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="qryUnsetDefautImage" dataSource="shoppingCart">
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

		<cfquery name="qrySetDefautImage" dataSource="shoppingCart">
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

		<!--- Continue with code execution if validation succeeds --->
		<cfquery name="qryDeleteImage" dataSource="shoppingCart">
			UPDATE
				tblProductImages
			SET
				fldActive = 1
			WHERE
				fldProductImage_Id = <cfqueryparam value = "#trim(arguments.imageId)#" cfsqltype = "integer">
		</cfquery>
	</cffunction>

	<cffunction name="getCart" access="public" returnType="array">
		<cfset local.cartItems = []>

		<!--- UserId Validation --->
		<cfif NOT structKeyExists(session, "userId")>
			<cfreturn local.cartItems>
		</cfif>

		<cfquery name="local.qryGetCart">
			SELECT
				fldCart_Id
			FROM
				tblCart
			WHERE
				fldUserId = <cfqueryparam value = "#trim(session.userId)#" cfsqltype = "integer">
		</cfquery>

		<cfloop query="local.qryGetCart">
			<cfset local.item = {
				"cartId" = local.qryGetCart.fldCart_Id
			}>
			<cfset arrayAppend(local.cartItems, local.item)>
		</cfloop>

		<cfreturn local.cartItems>
	</cffunction>

	<cffunction name="logOut" access="remote" returnType="void">
		<cfset structClear(session)>
	</cffunction>
</cfcomponent>
