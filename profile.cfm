<!--- Add address if form is submitted --->
<cfif structKeyExists(form, "addressFormSubmit")>
	<cfset application.shoppingCart.addAddress(
		firstName = form.firstname,
		lastName = form.lastName,
		addressLine1 = form.address,
		addressLine2 = form.landmark,
		city = form.city,
		state = form.state,
		pincode = form.pincode,
		phone = form.phone
	)>
	<cflocation url="profile.cfm" addToken="no">
</cfif>

<!--- Get Data --->
<cfset variables.addresses = application.shoppingCart.getAddress()>

<cfoutput>
    <div class="container mt-5">
        <div class="card shadow-sm">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div>
                        <h4 class="fw-semibold mb-1">#session.firstName & " " & session.lastName#</h4>
                        <p class="text-muted mb-0">#session.email#</p>
                    </div>

					<button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="##profileModal">
						Edit Profile
					</button>
                </div>

                <h5 class="mt-4">Saved Addresses</h5>
                <div class="list-group">
					<cfif arrayLen(variables.addresses)>
						<cf_addresslist addresses="#variables.addresses#" currentPage="profile">
					<cfelse>
						<div class="text-secondary">No Address Saved</div>
					</cfif>
                </div>

                <div class="mt-3">
					<button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="##addressFormModal">
						Add New Address
					</button>
                    <a href="/orders.cfm" class="btn btn-outline-secondary ms-2">View Previous Orders</a>
                </div>
            </div>
        </div>
    </div>

	<!-- Address Modal -->
	<div class="modal fade" id="addressFormModal" tabindex="-1" aria-hidden="true">
		<div class="modal-dialog modal-lg">
			<div class="modal-content">
				<div class="modal-header">
					<h1 class="modal-title fs-5">ADD ADDRESS</h1>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				</div>
				<form method="post" onsubmit="processAddressForm()">
					<div class="modal-body px-4">
						<div class="row">
							<div class="col-sm-6">
								<div class="mb-3">
									<label for="firstName" class="form-label">First Name</label>
									<input type="text" class="form-control addressInput" id="firstName" name="firstName">
									<div id="firstNameError" class="form-text text-danger addressError"></div>
								</div>
							</div>
							<div class="col-sm-6">
								<div class="mb-3">
									<label for="lastName" class="form-label">Last Name</label>
									<input type="text" class="form-control addressInput" id="lastName" name="lastName">
									<div id="lastNameError" class="form-text text-danger addressError"></div>
								</div>
							</div>
							<div class="col-sm-12">
								<div class="mb-3">
									<label for="address" class="form-label">Address</label>
									<textarea class="form-control addressInput" id="address" name="address" maxlength="64" autocomplete="on"></textarea>
									<div id="addressError" class="form-text text-danger addressError"></div>
								</div>
							</div>
							<div class="col-sm-12">
								<div class="mb-3">
									<label for="landmark" class="form-label">Landmark</label>
									<input type="text" class="form-control addressInput" id="landmark" name="landmark" maxlength="64">
									<div id="landmarkError" class="form-text text-danger addressError"></div>
								</div>
							</div>
							<div class="col-sm-6">
								<div class="mb-3">
									<label for="city" class="form-label">City</label>
									<input type="text" class="form-control addressInput" id="city" name="city">
									<div id="cityError" class="form-text text-danger addressError"></div>
								</div>
							</div>
							<div class="col-sm-6">
								<div class="mb-3">
									<label for="state" class="form-label">State</label>
									<input type="text" class="form-control addressInput" id="state" name="state">
									<div id="stateError" class="form-text text-danger addressError"></div>
								</div>
							</div>
							<div class="col-sm-6">
								<div class="mb-3">
									<label for="pincode" class="form-label">Pincode</label>
									<input type="text" class="form-control addressInput" id="pincode" name="pincode" maxlength="6">
									<div id="pincodeError" class="form-text text-danger addressError"></div>
								</div>
							</div>
							<div class="col-sm-6">
								<div class="mb-3">
									<label for="phone" class="form-label">Phone</label>
									<input type="text" class="form-control addressInput" id="phone" name="phone" maxlength="10" autocomplete="on">
									<div id="phoneError" class="form-text text-danger addressError"></div>
								</div>
							</div>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
						<button type="submit" name="addressFormSubmit" class="btn btn-primary">Save Address</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<!--- Profile Modal --->
	<div class="modal fade" id="profileModal" tabindex="-1" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h1 class="modal-title fs-5">EDIT PROFILE</h1>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				</div>
				<form method="post" onsubmit="processProfileForm()">
					<div class="modal-body px-4">
						<div class="mb-3">
							<label for="userFirstName" class="form-label">First Name</label>
							<input type="text" class="form-control profileInput" id="userFirstName" value="#session.firstName#">
							<div id="userFirstNameError" class="form-text text-danger profileError"></div>
						</div>
						<div class="mb-3">
							<label for="userLastName" class="form-label">Last Name</label>
							<input type="text" class="form-control profileInput" id="userLastName" value="#session.lastName#">
							<div id="userLastNameError" class="form-text text-danger profileError"></div>
						</div>
						<div class="mb-3">
							<label for="userEmail" class="form-label">Email</label>
							<input type="text" class="form-control profileInput" id="userEmail" name="email" value="#session.email#" autocomplete="on">
							<div id="userEmailError" class="form-text text-danger profileError"></div>
						</div>
						<div class="mb-3">
							<label for="userPhone" class="form-label">Phone number</label>
							<input type="text" class="form-control profileInput" id="userPhone" name="phone" maxlength="10" value="#session.phone#" autocomplete="on">
							<div id="userPhoneError" class="form-text text-danger profileError"></div>
						</div>
					</div>
					<div class="modal-footer">
						<div id="profileError" class="profileError text-danger"></div>
						<div>
							<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
							<button type="submit" class="btn btn-primary" id="profileSubmitBtn" disabled>Save changes</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
	</cfoutput>
