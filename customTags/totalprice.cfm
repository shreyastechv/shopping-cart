<!--- Attribute Params --->
<cfparam name="attributes.totalPrice" default=0>
<cfparam name="attributes.totalActualTax" default=0>
<cfparam name="attributes.totalTax" default=0>

 <cfoutput>
	<p class="d-flex justify-content-between">
		<span>Total Price:</span>
		<span class="fw-bold">Rs. <span id="totalPrice">#attributes.totalPrice#</span></span>
	</p>
	<p class="d-flex justify-content-between">
		<span>Total Tax:</span>
		<span class="fw-bold">Rs. <span id="totalTax">#attributes.totalTax#</span></span>
	</p>
	<p class="d-flex justify-content-between">
		<span>Actual Price:</span>
		<span class="fw-bold">Rs. <span id="totalActualPrice">#attributes.totalActualPrice#</span></span>
	</p>
 </cfoutput>