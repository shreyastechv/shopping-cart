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