	<cfoutput>
			<script src="assets/js/fontawesome.js"></script>
			<script src="assets/js/bootstrap.bundle.min.js"></script>
			<script src="assets/js/jquery-3.7.1.min.js"></script>
			<cfif structKeyExists(application, "productImageDirectory")>
				<script>
					var productImageDirectory = "#application.productImageDirectory#";
				</script>
			</cfif>
			<cfif structKeyExists(request, "scriptPath") AND arrayLen(request.scriptPath)>
				<cfloop array="#request.scriptPath#" index="local.script">
					<script src="#local.script#"></script>
				</cfloop>
			</cfif>
		</body>
	</cfoutput>
</html>
