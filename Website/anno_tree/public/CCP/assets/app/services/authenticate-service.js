(function( ng, app ) {
	
	"use strict";

	app.service("authenticateService",
		function( $http, $location, $cookies, apiRoot ) {

			function signup(name, email, password) {
				return $http.post(apiRoot.getRoot() + '/user/signup', {signUpName: name, signUpEmail: email, signUpPassword: password});
			}

			function login(email, password) {
				return $http.post(apiRoot.getRoot() + '/user/login', {loginEmail: email, loginPassword: password});
			}

			function logout() {
				return $http.post(apiRoot.getRoot() + '/user/logout');
			}

			function requestPassword() {
				return $http.get(apiRoot.getRoot() + '/2/tree');
			}

			function resetPassword() {
				return $http.get(apiRoot.getRoot() + '/2/tree');
			}

	        function isLoggedIn() {
	            if($cookies.sessionid) {
	                return true;
	            }

	            $location.path("login");
	        }
			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				signup: signup,
				login: login,
				logout: logout,
				requestPassword: requestPassword,
				resetPassword: resetPassword
			});


		}
	);

})( angular, AnnoTree );