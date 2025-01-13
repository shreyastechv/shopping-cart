<cfcomponent>
	<cffunction  name="login" access="public" returnType="struct">
		<cfargument  name="userInput">
		<cfargument  name="password">

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

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
		<cfset local.response["message"] = "">

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
				<cfquery name="local.qryAddCategory" result="local.resultAddCategory">
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
				<cfset local.response["categoryId"] = local.resultAddCategory.GENERATED_KEY>
				<cfset local.response["message"] = "Category Added">
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteCategory" access="remote">
		<cfargument name="categoryId">

		<cfquery name="qryDeleteProducts">
			UPDATE
				tblProduct
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
			WHERE
				fldSubCategoryId IN (
					SELECT
						fldSubCategory_Id
					FROM
						tblSubCategory
					WHERE
						fldCategoryId = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "cf_sql_integer">
				);
		</cfquery>

		<cfquery name="qryDeleteSubCategory">
			UPDATE
				tblSubCategory
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
			WHERE
				fldCategoryId = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "cf_sql_integer">
		</cfquery>

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

	<cffunction name="getSubCategories" access="remote" returnType="query" returnFormat="json">
		<cfargument  name="categoryId">

		<cfquery name="local.qryGetSubCategories">
			SELECT
				fldSubCategory_Id,
				fldSubCategoryName
			FROM
				tblSubCategory
			WHERE
				fldCategoryId = <cfqueryparam value = "#arguments.categoryId#" cfsqltype = "cf_sql_integer">
				AND fldActive = 1
		</cfquery>

		<cfreturn local.qryGetSubCategories>
	</cffunction>

	<cffunction name="modifySubCategory" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="subCategoryId">
		<cfargument name="subCategoryName">
		<cfargument name="categoryId">

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<cfquery name="local.qryCheckSubCategory">
			SELECT
				fldSubCategory_Id
			FROM
				tblSubCategory
			WHERE
				fldSubCategoryName = <cfqueryparam value = "#trim(arguments.subCategoryName)#" cfsqltype = "cf_sql_varchar">
				AND fldCategoryId = <cfqueryparam value = "#trim(arguments.categoryId)#" cfsqltype = "cf_sql_integer">
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
						fldSubCategoryName = <cfqueryparam value = "#trim(arguments.subCategoryName)#" cfsqltype = "cf_sql_varchar">,
						fldCategoryId = <cfqueryparam value = "#trim(arguments.categoryId)#" cfsqltype = "cf_sql_integer">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
					WHERE
						fldSubCategory_Id = <cfqueryparam value = "#trim(arguments.subCategoryId)#" cfsqltype = "cf_sql_integer">
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
						<cfqueryparam value = "#trim(arguments.subCategoryName)#" cfsqltype = "cf_sql_varchar">,
						<cfqueryparam value = "#trim(arguments.categoryId)#" cfsqltype = "cf_sql_integer">,
						<cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
					)
				</cfquery>
				<cfset local.response["subCategoryId"] = local.resultAddSubCategory.GENERATED_KEY>
				<cfset local.response["message"] = "SubCategory Added">
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteSubCategory" access="remote">
		<cfargument name="subCategoryId">

		<cfquery name="qryDeleteProducts">
			UPDATE
				tblProduct
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
			WHERE
				fldSubCategoryId = <cfqueryparam value = "#arguments.subCategoryId#" cfsqltype = "cf_sql_integer">
		</cfquery>

		<cfquery name="qryDeleteSubCategory">
			UPDATE
				tblSubCategory
			SET
				fldActive = 0,
				fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
			WHERE
				fldSubCategory_Id = <cfqueryparam value = "#arguments.subCategoryId#" cfsqltype = "cf_sql_integer">
		</cfquery>
	</cffunction>

	<cffunction name="getProducts" access="public" returnType="query">
		<cfargument  name="subCategoryId">

		<cfquery name="local.qryGetProducts">
			SELECT
				fldProduct_Id,
				fldProductName
			FROM
				tblProduct
			WHERE
				fldSubCategoryId = <cfqueryparam value = "#arguments.subCategoryId#" cfsqltype = "cf_sql_integer">
				AND fldActive = 1
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
		<cfargument name="productId">
		<cfargument name="categorySelect">
		<cfargument name="subCategorySelect">
		<cfargument name="productName">
		<cfargument name="brandSelect">
		<cfargument name="productDesc">
		<cfargument name="productPrice">
		<cfargument name="productTax">
		<cfargument name="productImage">

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Create images dir if not exists --->
		<cfif NOT directoryExists(expandPath("../assets/images/productImages"))>
			<cfdirectory action="create" directory="#expandPath("../assets/images/productImages")#">
		</cfif>

		<!--- Upload images --->
		<cffile
			action="uploadall"
			destination="#expandpath("../assets/images/productImages")#"
			nameconflict="MakeUnique"
			accept="image/png,image/jpeg,.png,.jpg,.jpeg"
			strict="true"
			result="local.imageUploaded"
			allowedextensions=".png,.jpg,.jpeg"
		>

		<cfquery name="local.qryCheckProduct">
			SELECT
				fldProduct_Id
			FROM
				tblProduct
			WHERE
				fldProductName = <cfqueryparam value = "#trim(arguments.productName)#" cfsqltype = "cf_sql_varchar">
				AND fldSubCategoryId = <cfqueryparam value = "#trim(arguments.subCategorySelect)#" cfsqltype = "cf_sql_integer">
				AND fldActive = 1
		</cfquery>

		<cfif local.qryCheckProduct.recordCount>
			<cfset local.response["message"] = "SubCategory already exists!">
		<cfelse>
			<cfif len(trim(arguments.productId))>
				<cfquery name="qryEditProduct">
					UPDATE
						tblProduct
					SET
						fldProductName = <cfqueryparam value = "#trim(arguments.productName)#" cfsqltype = "cf_sql_varchar">,
						fldSubCategoryId = <cfqueryparam value = "#trim(arguments.subCategorySelect)#" cfsqltype = "cf_sql_integer">,
						fldBrandId = <cfqueryparam value = "#trim(arguments.brandSelect)#" cfsqltype = "cf_sql_integer">,
						fldDescription = <cfqueryparam value = "#trim(arguments.productDesc)#" cfsqltype = "cf_sql_varchar">,
						fldPrice = <cfqueryparam value = "#trim(arguments.productPrice)#" cfsqltype = "cf_sql_decimal">,
						fldTax = <cfqueryparam value = "#trim(arguments.productTax)#" cfsqltype = "cf_sql_decimal">,
						fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
					WHERE
						fldProduct_Id = <cfqueryparam value = "#trim(arguments.productId)#" cfsqltype = "cf_sql_integer">
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
						<cfqueryparam value = "#trim(arguments.productName)#" cfsqltype = "cf_sql_varchar">,
						<cfqueryparam value = "#trim(arguments.subCategorySelect)#" cfsqltype = "cf_sql_varchar">,
						<cfqueryparam value = "#trim(arguments.brandSelect)#" cfsqltype = "cf_sql_integer">,
						<cfqueryparam value = "#trim(arguments.productDesc)#" cfsqltype = "cf_sql_varchar">,
						<cfqueryparam value = "#trim(arguments.productPrice)#" cfsqltype = "cf_sql_decimal">,
						<cfqueryparam value = "#trim(arguments.productTax)#" cfsqltype = "cf_sql_decimal">,
						<cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
					)
				</cfquery>
				<cfset local.response["productId"] = local.resultAddProduct.GENERATED_KEY>

				<cfquery name="qryAddImages">
					INSERT INTO
						tblProductImages (
							fldProductId,
							fldImageFileName,
							fldCreatedBy
						)
					VALUES
						<cfloop array="#local.imageUploaded#" item="local.image" index="local.i">
							(
								<cfqueryparam value = "#local.resultAddProduct.GENERATED_KEY#" cfsqltype = "cf_sql_integer">,
								<cfqueryparam value = "#local.image.serverFile#" cfsqltype = "cf_sql_varchar">,
								<cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
							)
							<cfif local.i LT arrayLen(local.imageUploaded)>,</cfif>
						</cfloop>
				</cfquery>
				<cfset local.response["message"] = "Product Added">
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="logOut" access="remote">
		<cfset structClear(session)>
		<cflocation url="/">
	</cffunction>
</cfcomponent>
