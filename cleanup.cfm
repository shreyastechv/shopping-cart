<cfquery name="local.qryGetProductImages">
	SELECT
		fldImageFileName
	FROM
		tblProductImages
	WHERE
		fldActive = 0
</cfquery>

<cfloop query="local.qryGetProductImages">
	<cfset local.productPath = expandPath(application.productImageDirectory)&local.qryGetProductImages.fldImageFileName>

	<cfif fileExists(local.productPath)>
		<cffile action="delete" file="#local.productPath#">
	</cfif>
</cfloop>