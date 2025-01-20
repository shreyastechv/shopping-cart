<cfparam name="attributes.qryProducts" default="">

<cfoutput>
	<div class="d-flex flex-wrap px-3 py-1">
		<cfloop query="attributes.qryProducts">
			<div class="w-16 d-flex flex-column align-items-center border rounded border-dark mb-3">
				<img src="#application.productImageDirectory&attributes.qryProducts.fldProductImage#" class="productThumbnail" alt="Random Product Image">
				<div>
					<p class="fs-3 text-dark fw-semibold">#attributes.qryProducts.fldProductName#</p>
				</div>
			</div>
		</cfloop>
	</div>
</cfoutput>