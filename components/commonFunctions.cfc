<cfcomponent displayname="Common functions" hint="Includes common functions that are used by multiple other functions">
	<cffunction name="encryptText" access="public" returnType="string">
		<cfargument name="plainText" type="string" required=true>

		<cfset local.encryptedText = encrypt(arguments.plainText, application.secretKey, "AES", "Base64")>

		<cfreturn local.encryptedText>
	</cffunction>

	<cffunction name="decryptText" access="public" returnType="string">
		<cfargument name="encryptedText" type="string" required=true>

		<!--- Handle exception in case decryption failes --->
		<cftry>
			<cfset local.decryptedText = decrypt(arguments.encryptedText, application.secretKey, "AES", "Base64")>
			<cfreturn local.decryptedText>

			<cfcatch type="any">
				<!--- Return -1 if decryption fails --->
				<cfreturn "-1">
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>
