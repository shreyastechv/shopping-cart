<cfcomponent displayname="Product Management" hint="Includes functions that help admins to add/edit products">
	<cffunction name="modifyCategory" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="categoryId" type="string" required=true default="">
		<cfargument name="categoryName" type="string" required=true>

		<cfset local.response = {
			"success" = false,
			"message" = ""
		}>

		<cftry>
			<!--- Decrypt ids--->
			<cfset local.categoryId = application.commonFunctions.decryptText(arguments.categoryId)>

			<!--- Category Id Validation --->
			<cfif len(trim(arguments.categoryId)) AND (local.categoryId EQ -1)>
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
							fldCategory_Id = <cfqueryparam value = "#val(local.categoryId)#" cfsqltype = "integer">
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
					<cfset local.response["categoryId"] = application.commonFunctions.encryptText(local.resultAddCategory.GENERATED_KEY)>
					<cfset local.response["message"] = "Category Added">
				</cfif>
				<cfset local.response.success = true>
			</cfif>

			<cfcatch type="any">
				<cfset local.response.message = "Error while modifying category!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="modifySubCategory" access="remote" returnType="struct" returnFormat="json">
		<cfargument name="subCategoryId" type="string" required=true default="">
		<cfargument name="subCategoryName" type="string" required=true>
		<cfargument name="categoryId" type="string" required=true default="">

		<cfset local.response = {
			"message" = "",
			"success" = false
		}>

		<cftry>
			<!--- Decrypt ids--->
			<cfset local.subCategoryId = application.commonFunctions.decryptText(arguments.subCategoryId)>
			<cfset local.categoryId = application.commonFunctions.decryptText(arguments.categoryId)>

			<!--- Sub Category Id Validation --->
			<cfif len(trim(arguments.subCategoryId)) AND (local.subCategoryId EQ -1)>
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
					AND fldCategoryId = <cfqueryparam value = "#val(local.categoryId)#" cfsqltype = "integer">
					AND fldSubCategory_Id != <cfqueryparam value = "#val(local.subCategoryId)#" cfsqltype = "integer">
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
							fldCategoryId = <cfqueryparam value = "#val(local.categoryId)#" cfsqltype = "integer">,
							fldUpdatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "integer">
						WHERE
							fldSubCategory_Id = <cfqueryparam value = "#val(local.subCategoryId)#" cfsqltype = "integer">
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
							<cfqueryparam value = "#val(local.categoryId)#" cfsqltype = "integer">,
							<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
						)
					</cfquery>
					<cfset local.response["subCategoryId"] = application.commonFunctions.encryptText(local.resultAddSubCategory.GENERATED_KEY)>
					<cfset local.response["message"] = "SubCategory Added">
				</cfif>

				<cfset local.response.success = true>
			</cfif>

			<cfcatch type="any">
				<cfset local.response.message = "Error while modifying subcategory!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

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
		<cfargument name="defaultImageId" type="string" required=false default="">
		<cfargument name="deletedImageIdArray" type="array" required=false default=#arrayNew(1)#>

		<cfset local.response = {
			"message" = "",
			"success" = false
		}>

		<cftransaction>
			<cftry>
				<!--- Decrypt ids--->
				<cfset local.productId = application.commonFunctions.decryptText(arguments.productId)>
				<cfset local.subCategorySelect = application.commonFunctions.decryptText(arguments.subCategorySelect)>
				<cfset local.brandSelect = application.commonFunctions.decryptText(arguments.brandSelect)>
				<cfset local.defaultImageId = application.commonFunctions.decryptText(arguments.defaultImageId)>
				<cfset local.deletedImageIdArray = arrayMap(arguments.deletedImageIdArray, function(item) {
					return application.commonFunctions.decryptText(item);
				})>

				<!--- Product Id Validation --->
				<cfif len(trim(arguments.productId)) AND (local.productId EQ -1)>
					<!--- Value equals -1 means decryption failed --->
					<cfset local.response["message"] &= "Product Id is invalid. ">
				</cfif>

				<!--- Sub Category Id Validation --->
				<cfif len(trim(arguments.subCategorySelect)) AND (local.subCategorySelect EQ -1)>
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
				<cfif len(trim(arguments.brandSelect)) AND (local.brandSelect EQ -1)>
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
					<cfset local.response["message"] &= "Price should be an number. ">
				</cfif>

				<!--- Tax Validation --->
				<cfif len(arguments.productTax) EQ 0>
					<cfset local.response["message"] &= "Tax should not be empty. ">
				<cfelseif NOT isValid("float", arguments.productTax)>
					<cfset local.response["message"] &= "Tax should be an number. ">
				</cfif>

				<!--- Product Image Validation (only when adding new products, not when editing) --->
				<cfif (len(arguments.productId) EQ 0) AND (len(trim(arguments.productImage)) EQ 0)>
					<cfset local.response["message"] &= "Select at least one product image. ">
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
						AND fldSubCategoryId = <cfqueryparam value = "#local.subCategorySelect#" cfsqltype = "integer">
						AND fldProduct_Id != <cfqueryparam value = "#val(local.productId)#" cfsqltype = "integer">
						AND fldActive = 1
				</cfquery>

				<cfif local.qryCheckProduct.recordCount>
					<cfset local.response["message"] = "Product already exists!">
				<cfelse>
					<!--- Product id has length means we used edit button --->
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
								fldProduct_Id = <cfqueryparam value = "#val(local.productId)#" cfsqltype = "integer">
						</cfquery>

						<!--- Not equal to -1 means we selected an already uploaded image --->
						<cfif val(local.defaultImageId) NEQ -1>
							<cfquery name="qrySetDefautImage">
								UPDATE
									tblProductImages PI1
								JOIN
									tblProductImages PI2 ON PI1.fldProductId = PI2.fldProductId
								SET
									PI1.fldDefaultImage =
										CASE
											WHEN PI1.fldProductImage_Id = <cfqueryparam value = "#val(local.defaultImageId)#" cfsqltype = "integer"> THEN 1
											ELSE 0
										END
								WHERE
									PI2.fldProductImage_Id = <cfqueryparam value = "#val(local.defaultImageId)#" cfsqltype = "integer">
							</cfquery>
						</cfif>

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
						<cfset local.productId = local.resultAddProduct.GENERATED_KEY>
						<cfset local.response["productId"] = application.commonFunctions.encryptText(local.resultAddProduct.GENERATED_KEY)>
						<cfset local.response["message"] = "Product Added">
					</cfif>

					<!--- Create images dir if not exists --->
					<cfif NOT directoryExists(expandPath(application.productImageDirectory))>
						<cfdirectory action="create" directory="#expandPath(application.productImageDirectory)#">
					</cfif>

					<!--- Upload images --->
					<cffile
						action="uploadall"
						destination="#expandPath(application.productImageDirectory)#"
						nameconflict="MakeUnique"
						accept="image/*"
						strict="true"
						result="local.uploadedImages"
					>

					<!--- If there are no product images uploaded while adding new products --->
					<cfif len(trim(arguments.productId)) EQ 0 AND arrayLen(local.uploadedImages) EQ 0>
						<cftransaction action="rollback">
						<cfset local.response.message = "Select at least one image.">
						<cfreturn local.response>
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
										<cfqueryparam value = "#val(local.productId)#" cfsqltype = "integer">,
										<cfqueryparam value = "#local.image.serverFile#" cfsqltype = "varchar">,
										<cfqueryparam value = "#(local.i EQ val(arguments.defaultImageId) ? 1 : 0)#" cfsqltype = "tinyint">,
										<cfqueryparam value = "#session.userId#" cfsqltype = "integer">
									)
									<cfif local.i LT arrayLen(local.uploadedImages)>,</cfif>
								</cfloop>
						</cfquery>
					</cfif>

					<!--- Remove deleted imaged from db --->
					<cfquery name="local.qryDeleteImages">
						DELETE FROM
							tblProductImages
						WHERE
							fldProductImage_Id IN (<cfqueryparam value = "#arrayToList(local.deletedImageIdArray)#" cfsqltype = "varchar" list = "yes">)
					</cfquery>

					<cfset local.response.success = true>
				</cfif>

				<cfcatch type="any">
					<cftransaction action="rollback">
					<cfif structKeyExists(cfcatch, "Accept") AND cfcatch.Accept EQ "image/*">
						<cfset local.response.message = "Only image files are allowed.">
					<cfelse>
						<cfset local.response.message = "Error while modifying product!">
					</cfif>
					<cfreturn local.response>
				</cfcatch>
			</cftry>
		</cftransaction>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="deleteItem" access="remote" returnType="struct">
		<cfargument name="itemName" type="string" required=true defaul="">
		<cfargument name="itemId" type="string" required=true defaul="">

		<cfset local.response = {
			"success" = true,
			"message" = ""
		}>

		<cftry>
			<!--- Decrypt item id --->
			<cfset local.itemId = application.commonFunctions.decryptText(arguments.itemId)>

			<!--- Item Id Validation --->
			<cfif local.itemId EQ -1>
				<!--- Value equals -1 means decryption failed --->
				<cfset local.response["message"] &= "Item Id is invalid. ">
			</cfif>

			<!--- Return message if validation fails --->
			<cfif len(trim(local.response.message))>
				<cfreturn local.response>
			</cfif>

			<!--- Continue with code execution if validation succeeds --->
			<cfstoredproc procedure="spDeleteItem">
				<cfprocparam type="in" cfsqltype="varchar" value="#trim(arguments.itemName)#">
				<cfprocparam type="in"cfsqltype="integer" value="#val(local.itemId)#">
				<cfprocparam type="in"cfsqltype="integer" value="#session.userId#">
				<cfprocparam type="out"cfsqltype="bit" variable="local.success">
			</cfstoredproc>

			<!--- Throw error if the stored procedure errored out --->
			<cfif NOT local.success>
				<cfthrow message = "#arguments.itemName# deletion failed!">
			</cfif>

			<!--- Set success message --->
			<cfset local.response.success = true>
			<cfset local.response.message = "#arguments.itemName# deleted successfully.">

			<cfcatch type="any">
				<cfset local.response["message"] = "#arguments.itemName# deletion failed!">
				<cfreturn local.response>
			</cfcatch>
		</cftry>

		<cfreturn local.response>
	</cffunction>
</cfcomponent>
