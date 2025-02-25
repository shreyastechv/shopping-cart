// Remove error msgs and red borders from inputs on modal close
$("#addressFormModal").on("hidden.bs.modal", function () {
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

  valid &= validateName(firstName, "First name", firstNameError);
  valid &= validateName(lastName, "Last name", lastNameError);
  valid &= validateRequiredField(address, "Address", addressError);
  valid &= validateRequiredField(landmark, "Landmark", landmarkError);
  valid &= validateRequiredField(city, "City", cityError);
  valid &= validateRequiredField(state, "State", stateError);
  valid &= validatePincode(pincode, pincodeError);
  valid &= validatePhoneNumber(phone, phoneError);

  if (!valid) return;

  $.ajax({
    type: "POST",
    url: "./components/userManagement.cfc",
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
