(function( ng, app ) {
    
    "use strict";

    app.service("authenticateService",
        function( $http, $location, $cookies, apiRoot ) {

            function signup(name, email, password) {
                return $http.post(apiRoot.getRoot() + '/services/user/signup', {signUpName: name, signUpEmail: email, signUpPassword: password});
            }

            function login(email, password) {
                return $http.post(apiRoot.getRoot() + '/services/user/login', {loginEmail: email, loginPassword: password});
            }

            function logout() {
                return $http.post(apiRoot.getRoot() + '/services/user/logout');
            }

            function resetPassword(email, password, token) {
                return $http.post(apiRoot.getRoot() + '/services/user/reset/' + token, {email: email, password: password});
            }

            function requestPassword(email) {
                return $http.post(apiRoot.getRoot() + '/services/user/reset', {email: email});
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