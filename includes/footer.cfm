		<cfoutput>
			<!--- Variables used in this page --->
			<cfparam name="application.productImageDirectory" type="string" default="./">
			<cfparam name="application.scriptDirectory" type="string" default="">
			<cfparam name="application.scriptPath" default="#arrayNew(1)#">

			<!--- Load common scripts --->
			<script src="#application.scriptDirectory#fontawesome.js"></script>
			<script src="#application.scriptDirectory#bootstrap.bundle.min.js"></script>
			<script src="#application.scriptDirectory#jquery-3.7.1.min.js"></script>

			<!--- Set js variables --->
			<script>
				var productImageDirectory = "#application.productImageDirectory#";
			</script>

			<!--- Load individual page-specific scripts --->
			<cfloop array="#request.scriptPath#" index="local.script">
				<script src="#application.scriptDirectory&local.script#"></script>
			</cfloop>
		</cfoutput>
	</body>
</html>