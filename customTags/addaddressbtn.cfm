<div>
	<button type="button" class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#addressFormModal">
		<i class="fa-solid fa-plus"></i>
		Add New Address
	</button>
</div>

<div class="modal fade" id="addressFormModal" tabindex="-1" aria-hidden="true">
	<div class="modal-dialog modal-lg">
		<div class="modal-content">
			<div class="modal-header">
				<h1 class="modal-title fs-5">ADD ADDRESS</h1>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<form method="post" name="addressForm" id="addressForm">
				<div class="modal-body px-4">
					<div class="row">
						<div class="col-sm-6">
							<div class="mb-3">
								<label for="firstName" class="form-label">First Name</label>
								<input type="text" class="form-control addressInput" id="firstName" name="firstName" maxlength="32">
								<div id="firstNameError" class="form-text text-danger addressError"></div>
							</div>
						</div>
						<div class="col-sm-6">
							<div class="mb-3">
								<label for="lastName" class="form-label">Last Name</label>
								<input type="text" class="form-control addressInput" id="lastName" name="lastName" maxlength="32">
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
								<input type="text" class="form-control addressInput" id="city" name="city" maxlength="64">
								<div id="cityError" class="form-text text-danger addressError"></div>
							</div>
						</div>
						<div class="col-sm-6">
							<div class="mb-3">
								<label for="state" class="form-label">State</label>
								<input type="text" class="form-control addressInput" id="state" name="state" maxlength="64">
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
				<div class="modal-footer d-flex gap-2">
					<div id="addAddressError" class="addressError text-danger"></div>
					<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
					<button type="button" name="addressFormSubmit" class="btn btn-primary" onclick="processAddressForm()">Save</button>
				</div>
			</form>
		</div>
	</div>
</div>
