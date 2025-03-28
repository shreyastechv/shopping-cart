<!--- Attribute Params --->
<cfparam name="attributes.addresses" default=[]>
<cfparam name="attributes.currentPage" default="">

<cfoutput>
	<div class="list-group">
		<cfif arrayLen(attributes.addresses)>
			<cfloop array="#attributes.addresses#" item="address" index="i">
				<div class="d-flex justify-content-between list-group-item border shadow-sm mb-3" id="addressContainer_#i#"
					onMouseOver="this.style.cursor='pointer'"
					onclick="$(this).children().find('input[name=addressId]').prop('checked', true).trigger('change');"
				>
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
							<!--- Delete button on profile page --->
							<button class="btn btn-sm btn-danger" onclick="deleteAddress('addressContainer_#i#', '#address.addressId#')">
								<i class="fa-solid fa-trash"></i>
							</button>
						<cfelseif attributes.currentPage EQ "checkout">
							<!--- Radio button on checkout page --->
							<input type="radio" name="addressId" value="#address.addressId#" checked>
						</cfif>
					</div>
				</div>
		</cfloop>
		<cfelse>
			<div class="text-secondary px-2 py-3">No Address Saved</div>
		</cfif>
	</div>
</cfoutput>
