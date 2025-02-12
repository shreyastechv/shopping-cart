<cfparam name="url.eventName" default="">

<cfoutput>
	<div class="text-center p-4 rounded">
		<img src="#application.imageDirectory#error.jpg" width="400px" alt="Error Page Image">
		<h2 class="text-danger mb-4">An unexpected error occurred.</h2>
		<cfif len(trim(url.eventName))>
			<p>Please provide the following information to technical support:</p>
			<p><strong>Error Event:</strong> <span class="text-info">#url.eventName#</span></p>
		</cfif>
		<a href="/" class="btn btn-primary">Go Back Home</a>
	</div>
</cfoutput>