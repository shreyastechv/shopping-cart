<!--- Attribute Params --->
<cfparam name="attributes.addresses" default=[]>
<cfparam name="attributes.currentPage" default="">

<cfoutput>
	<div class="list-group">
		<cfif arrayLen(attributes.addresses)>
			<cfloop array="#attributes.addresses#" item="address">
				<!--- Generate random id for the mian container div --->
				<cfset local.randomId = createUUID()>

				<div class="d-flex justify-content-between list-group-item shadow-sm mb-3" id="#local.randomId#">
					<div>
						<p class="fw-semibold mb-1">
							#address.fullName# -
							#address.phone#
						</p>
						<p class="mb-1">#address.addressLine1#</p>
						<p class="mb-0">#address.addressLine2#</p>
						<div class="mb-0">
							#address.city#,
							#address.state# -
							<span class="fw-semibold">#address.pincode#</span>
						</div>
					</div>
					<div class="d-flex align-items-center px-4">
						<cfif attributes.currentPage EQ "profile">
							<button class="btn btn-danger" onclick="deleteAddress('#local.randomId#', #address.addressId#)">
								<i class="fa-solid fa-trash"></i>
							</button>
						<cfelseif attributes.currentPage EQ "checkout">
							<input type="radio" name="addressId" value="#address.addressId#" checked>
						</cfif>
					</div>
				</div>
		</cfloop>
		<cfelse>
			<div class="text-secondary">No Address Saved</div>
		</cfif>
	</div>
</cfoutput>
