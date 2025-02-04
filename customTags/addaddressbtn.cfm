<div>
	<button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addressFormModal">
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
			<form method="post">
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
					<button type="button" name="addressFormSubmit" class="btn btn-primary" onclick="processAddressForm()">Save Address</button>
				</div>
			</form>
		</div>
	</div>
</div>

<script>
	function processAddressForm() {
		event.preventDefault();

		// Remove error msgs and red borders from inputs
		$(".addressInput").removeClass("border-danger");
		$(".addressError").empty();

		let valid = true;
		const firstName = $("#firstName");
		const firstNameError = $("#firstNameError");
		const lastName = $("#lastName");
		const lastNameError = $("#lastNameError");
		const address = $("#address");
		const addressError = $("#addressError");
		const landmark = $("#landmark");
		const landmarkError = $("#landmarkError");
		const city = $("#city");
		const cityError = $("#cityError");
		const state = $("#state");
		const stateError = $("#stateError");
		const pincode = $("#pincode");
		const pincodeError = $("#pincodeError");
		const phone = $("#phone");
		const phoneError = $("#phoneError");

		if (firstName.val().trim().length === 0) {
			firstName.addClass("border-danger");
			firstNameError.text("First name is required.")
			valid = false;
		} else if (/\d/.test(firstName.val().trim())) {
			firstName.addClass("border-danger");
			firstNameError.text("First name should not contain any digits")
			valid = false;
		}

		if (lastName.val().trim().length === 0) {
			lastName.addClass("border-danger");
			lastNameError.text("Last name is required.")
			valid = false;
		} else if (/\d/.test(lastName.val().trim())) {
			lastName.addClass("border-danger");
			lastNameError.text("Last name is required.")
			valid = false;
		}

		if (address.val().trim().length === 0) {
			address.addClass("border-danger");
			addressError.text("Address is required.")
			valid = false;
		}

		if (landmark.val().trim().length === 0) {
			landmark.addClass("border-danger");
			landmarkError.text("Landmark is required.")
			valid = false;
		}

		if (city.val().trim().length === 0) {
			city.addClass("border-danger");
			cityError.text("City is required.")
			valid = false;
		}

		if (state.val().trim().length === 0) {
			state.addClass("border-danger");
			stateError.text("State is required.")
			valid = false;
		}

		if (pincode.val().trim().length === 0) {
			pincode.addClass("border-danger");
			pincodeError.text("Pincode is required.")
			valid = false;
		} else if (!/^\d{6}$/.test(pincode.val().trim())) {
			pincode.addClass("border-danger");
			pincodeError.text("Pincode should be 6 digits")
			valid = false;
		}

		if (phone.val().trim().length === 0) {
			phone.addClass("border-danger");
			phoneError.text("Phone number is required.")
			valid = false;
		} else if (!/^\d{10}$/.test(phone.val().trim())) {
			phone.addClass("border-danger");
			phoneError.text("Phone number should be 10 digits")
			valid = false;
		}

		if (!valid) return;

		$.ajax({
			type: "POST",
			url: "./components/shoppingCart.cfc",
			data: {
				method: "addAddress",
				firstName: firstName.val().trim(),
				lastName: lastName.val().trim(),
				addressLine1: address.val().trim(),
				addressLine2: landmark.val().trim(),
				city: city.val().trim(),
				state: state.val().trim(),
				pincode: pincode.val().trim(),
				phone: phone.val().trim()
			},
			success: function() {
				location.reload();
			}
		});
	}
</script>
