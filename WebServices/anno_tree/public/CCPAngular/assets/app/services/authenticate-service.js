(function( ng, app ) {
	
	"use strict";

	app.service("authenticateService",
		function( $http, apiRoot ) {

			function signup(name, email, password) {
				//return $http.post(apiRoot.getRoot() + '/user/signup', {signUpName: name, signUpEmail: email, signUpPassword: password});
				return $http({
				    method: 'POST',
				    url: apiRoot.getRoot() + '/user/signup',
				    data: {signUpName: name, signUpEmail: email, signUpPassword: password},
				    headers: {'Content-Type': 'application/x-www-form-urlencoded'}
				});
			}

			function login() {
				return $http.get(apiRoot.getRoot() + '/2/tree');
			}

			function requestPassword() {
				return $http.get(apiRoot.getRoot() + '/2/tree');
			}

			function resetPassword() {
				return $http.get(apiRoot.getRoot() + '/2/tree');
			}
			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				signup: signup,
				login: login,
				requestPassword: requestPassword,
				resetPassword: resetPassword
			});


		}
	);

})( angular, AnnoTree );