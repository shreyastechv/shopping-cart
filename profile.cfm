<!--- Variables --->
<cfparam name="session.firstName" default="User">
<cfparam name="session.lastName" default="Name">
<cfparam name="session.email" default="User Email Id">
<cfparam name="session.phone" default="User Phone Number">

<!--- Get Data --->
<cfset variables.addresses = application.dataFetch.getAddress()>

<cfoutput>
	<div class="container my-5">
		<div class="card shadow-sm">
			<div class="card-body">
				<div class="d-flex justify-content-between align-items-center mb-3">
					<div class="d-flex justify-content-between align-items-center gap-2">
						<h4 class="fw-semibold mb-1">#session.firstName & " " & session.lastName#</h4>
						<p class="text-muted mb-0">#session.email#</p>
					</div>

					<div>
						<a href="/orders.cfm" class="btn btn-secondary m-2">
							<i class="fa-solid fa-rectangle-list"></i>
							View Previous Orders
						</a>
						<button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="##profileModal">
							<i class="fa-solid fa-user-pen"></i>
							Edit Profile
						</button>
					</div>
				</div>

				<h5 class="mt-4">Saved Addresses</h5>
				<cf_addresslist addresses="#variables.addresses.data#" currentPage="profile">
				<cf_addaddressbtn>
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
							<input type="text" class="form-control profileInput" id="userFirstName" maxlength="32" value="#session.firstName#">
							<div id="userFirstNameError" class="form-text text-danger profileError"></div>
						</div>
						<div class="mb-3">
							<label for="userLastName" class="form-label">Last Name</label>
							<input type="text" class="form-control profileInput" id="userLastName" maxlength="32" value="#session.lastName#">
							<div id="userLastNameError" class="form-text text-danger profileError"></div>
						</div>
						<div class="mb-3">
							<label for="userEmail" class="form-label">Email</label>
							<input type="text" class="form-control profileInput" id="userEmail" name="email" maxlength="100" value="#session.email#" autocomplete="on">
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
						<div class="d-flex gap-2">
							<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
							<button type="submit" class="btn btn-primary" id="profileSubmitBtn" disabled>Save changes</button>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
</cfoutput>
