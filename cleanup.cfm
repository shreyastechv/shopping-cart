<!--- This page can be accessed by admins and cfschedule --->
<cfif trim(cgi?.HTTP_USER_AGENT) == "CFSCHEDULE"
	OR trim(cgi?.HTTP_USER_AGENT) == "ColdFusion"
		OR (structKeyExists(session, "roleId") AND session.roleId EQ 1)
>
	<cftry>
		<!--- Get inactive (soft-deleted) images --->
		<cfquery name="variables.qryGetProductImages">
			SELECT
				fldImageFileName
			FROM
				tblProductImages
			WHERE
				fldActive = 0
				<!--- Only select images other than default image --->
				<!--- since it is needed for order history page --->
				AND fldDefaultImage = 0
		</cfquery>


		<!--- Delete images --->
		<cfloop query="variables.qryGetProductImages">
			<cfset variables.productPath = expandPath(application.productImageDirectory)&variables.qryGetProductImages.fldImageFileName>

			<cfif fileExists(variables.productPath)>
				<cffile action="delete" file="#variables.productPath#">
			</cfif>
		</cfloop>

		<!--- Hard-delete images from db --->
		<cfquery name="variables.qryDeleteProductImages">
			DELETE FROM
				tblProductImages
			WHERE
				fldActive = 0
				AND fldDefaultImage = 0
		</cfquery>

		<!--- Delete inactive products from cart --->
		<cfquery name="variables.qryCleanupCart">
			DELETE
				C
			FROM
				tblCart C
				INNER JOIN tblProduct P ON C.fldProductId = P.fldProduct_Id
			WHERE
				P.fldActive = 0
		</cfquery>

		<!--- Show success message --->
		<div class="d-flex flex-column align-items-center p-5 gap-2 my-auto">
			<i class="fa-solid fa-circle-check fs-2 text-success"></i>
			<div class="text-success h4 text-center">Cleanup Successful.</div>
		</div>

		<cfcatch type="any">
			<!--- Show error message --->
			<cfoutput>
				<div class="text-center p-5 my-auto">
					<i class="fa-solid fa-circle-xmark fs-2 text-danger"></i>
					<div class="text-danger h4">Cleanup Unsuccessful.</div>
					<div class="fs-6">Error message: #cfcatch.message#</div>
					<div class="fs-6">Error code: #cfcatch.errorCode#</div>
					<div class="fs-6">Native Error code: #cfcatch.nativeErrorCode#</div>
				</div>
			</cfoutput>
		</cfcatch>
	</cftry>
<cfelse>
	<cfinclude template="/403.cfm">
</cfif>
