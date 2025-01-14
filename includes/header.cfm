<header class="header d-flex align-items-center justify-content-between fixed-top bg-success ps-2 pe-3">
	<a class="d-flex align-items-center text-decoration-none" href="/">
		<img class=" p-2 me-2" src="assets/images/shopping-cart-logo.png" height="45" alt="Logo Image">
		<div class="text-white fw-semibold">SHOPPING CART</div>
	</a>
	<cfif structKeyExists(session, "roleId") AND session.roleId EQ 1>
		<a class="text-white text-decoration-none fs-4" href="adminDashboard.cfm">
			ADMIN DASHBOARD
		</a>
	</cfif>
	<nav class="d-flex align-items-center justify-content-between gap-4">
		<cfif structKeyExists(session, "userId")>
			<a class="text-white text-decoration-none" href="components/shoppingCart.cfc?method=logOut">
				<i class="fa-solid fa-right-from-bracket"></i>
				Logout
			</a>
		<cfelse>
			<a class="text-white text-decoration-none" href="signup.cfm">
				<i class="fa-solid fa-right-from-bracket"></i>
				Login
			</a>
		</cfif>
	</nav>
</header>
