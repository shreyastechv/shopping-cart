$("#addressFormModal").on("hidden.bs.modal", function () {
  // Remove error msgs and red borders from inputs
  $(".addressInput").removeClass("border-danger");
  $(".addressError").empty();
});

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
