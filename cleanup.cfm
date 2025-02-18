<cfif trim(cgi?.HTTP_USER_AGENT) == "CFSCHEDULE"
	OR trim(cgi?.HTTP_USER_AGENT) == "ColdFusion"
		OR (structKeyExists(session, "roleId") AND session.roleId EQ 1)
>
	<cfquery name="variables.qryGetProductImages">
		SELECT
			fldImageFileName
		FROM
			tblProductImages
		WHERE
			fldActive = 0
	</cfquery>

	<cfloop query="variables.qryGetProductImages">
		<cfset variables.productPath = expandPath(application.productImageDirectory)&variables.qryGetProductImages.fldImageFileName>

		<cfif fileExists(variables.productPath)>
			<cffile action="delete" file="#variables.productPath#">
		</cfif>
	</cfloop>
<cfelse>
	<cfinclude template="/403.cfm">
</cfif>