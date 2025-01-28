	<cfoutput>
			<script src="assets/js/fontawesome.js"></script>
			<script src="assets/js/bootstrap.bundle.min.js"></script>
			<script src="assets/js/jquery-3.7.1.min.js"></script>
			<cfif structKeyExists(application, "productImageDirectory")>
				<script>
					var productImageDirectory = "#application.productImageDirectory#";
				</script>
			</cfif>
			<cfif structKeyExists(application, "scriptPath") AND len(trim(request.scriptPath))>
				<script src="#request.scriptPath#"></script>
			</cfif>
		</body>
	</cfoutput>
</html>
