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

		<!--- Show success message --->
		<div>Cleanup Successful.</div>

		<cfcatch type="any">
			<!--- Show error message --->
			<div>Cleanup Unsuccessful.</div>
			<div>Error message: </div>
			<br>
			<cfoutput>#cfcatch.message#</cfoutput>
		</cfcatch>
	</cftry>
<cfelse>
	<cfinclude template="/403.cfm">
</cfif>
