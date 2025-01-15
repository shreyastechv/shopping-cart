<cfcomponent>
	<cffunction name="login" access="public" returnType="struct">
		<cfargument name="userInput" type="string" required="true">
		<cfargument name="password" type="string" required="true">

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<cfif len(trim(arguments.userInput)) EQ 0>
			<cfset local.response["message"] = "Enter an email/password">
		<cfelseif len(trim(arguments.password)) EQ 0>
			<cfset local.response["message"] = "Enter a password">
		</cfif>

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
		<cfargument name="categoryId" type="string" required="true">
		<cfargument name="categoryName" type="string" required="true">

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

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
		<cfargument name="categoryId" type="string" required="true">

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
		<cfargument name="categoryId" type="string" required="true">

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
		<cfargument name="subCategoryId" type="string" required="true">
		<cfargument name="subCategoryName" type="string" required="true">
		<cfargument name="categoryId" type="string" required="true">

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

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
		<cfargument name="subCategoryId" type="string" required="true">

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
		<cfargument name="subCategoryId" type="string" required="true">
		<cfargument name="productId" type="string" required="false" default="">

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
			WHERE
				p.fldSubCategoryId = <cfqueryparam value = "#arguments.subCategoryId#" cfsqltype = "integer">
				<cfif len(trim(arguments.productId))>
					AND p.fldProduct_Id = <cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">
				</cfif>
				AND i.fldDefaultImage = 1
				AND p.fldActive = 1
				AND b.fldActive = 1
				AND i.fldActive = 1
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
		<cfargument name="productId" type="string" required="true">
		<cfargument name="categorySelect" type="string" required="true">
		<cfargument name="subCategorySelect" type="string" required="true">
		<cfargument name="productName" type="string" required="true">
		<cfargument name="brandSelect" type="string" required="true">
		<cfargument name="productDesc" type="string" required="true">
		<cfargument name="productPrice" type="string" required="true">
		<cfargument name="productTax" type="string" required="true">
		<cfargument name="productImage" type="string" required="true">

		<cfset local.response = {}>
		<cfset local.response["message"] = "">

		<!--- Create images dir if not exists --->
		<cfif NOT directoryExists(application.productImageDirectory)>
			<cfdirectory action="create" directory="#application.productImageDirectory#">
		</cfif>

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
				destination="#application.productImageDirectory#"
				nameconflict="MakeUnique"
				accept="image/png,image/jpeg,.png,.jpg,.jpeg"
				strict="true"
				result="local.imageUploaded"
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
						<cfqueryparam value = "#trim(arguments.productPrice)#" cfsqltype = "decimal">,
						<cfqueryparam value = "#trim(arguments.productTax)#" cfsqltype = "decimal">,
						<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
					)
				</cfquery>
				<cfset local.response["productId"] = local.resultAddProduct.GENERATED_KEY>
				<cfset local.response["message"] = "Product Added">
			</cfif>

			<!--- Store images in DB --->
			<cfif arrayLen(local.imageUploaded)>
				<cfquery name="qryAddImages" dataSource="shoppingCart">
					INSERT INTO
						tblProductImages (
							fldProductId,
							fldImageFileName,
							fldDefaultImage,
							fldCreatedBy
						)
					VALUES
						<cfloop array="#local.imageUploaded#" item="local.image" index="local.i">
							(
								<cfif len(trim(arguments.productId))>
									<cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">,
								<cfelse>
									<cfqueryparam value = "#local.resultAddProduct.GENERATED_KEY#" cfsqltype = "integer">,
								</cfif>
								<cfqueryparam value = "#local.image.serverFile#" cfsqltype = "varchar">,
								<cfif local.i EQ 1 AND len(trim(arguments.productId)) NEQ 0>
									<cfset local.response["defaultImageFile"] = local.image.serverFile>
									1,
								<cfelse>
									0,
								</cfif>
								<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
							)
							<cfif local.i LT arrayLen(local.imageUploaded)>,</cfif>
						</cfloop>
				</cfquery>
			</cfif>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteProduct" access="remote" returnType="void">
		<cfargument name="productId" type="string" required="true">

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
				fldDeactivatedDate = <cfqueryparam value = "#DateTimeFormat(now(), "yyyy-MM-dd HH:mm:ss")#" cfsqltype = "timestamp">,
			WHERE
				fldProductId = <cfqueryparam value = "#arguments.productId#" cfsqltype = "integer">
		</cfquery>

	</cffunction>

	<cffunction name="getProductImages" access="remote" returnType="array" returnFormat="json">
		<cfargument name="productId" type="string" required="true">

		<cfset local.imageArray = []>

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
		<cfargument name="imageId" type="string" required="true">

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
		<cfargument name="imageId" type="string" required="true">

		<cfquery name="qryDeleteImage" dataSource="shoppingCart">
			UPDATE
				tblProductImages
			SET
				fldActive = 1
			WHERE
				fldProductImage_Id = <cfqueryparam value = "#trim(arguments.imageId)#" cfsqltype = "integer">
		</cfquery>
	</cffunction>

	<cffunction name="logOut" access="remote" returnType="void">
		<cfset structClear(session)>
		<cflocation url="/">
	</cffunction>
</cfcomponent>
