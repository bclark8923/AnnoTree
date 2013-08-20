(function( ng, app ){
    "use strict";

    app.controller(
        "authenticate.RequestpasswordController",
        function( $scope, $location, requestContext, authenticateService, _ ) {
            $scope.requestPassword = function() {
                var email = $scope.email;
                if (email) {
                    $('#authenticateWorking').addClass('active');
                    var promise = authenticateService.requestPassword(email);
                    
                    promise.then(
                        function(response) { //success case
                            $("#textMsg").html('Please check ' + email + ' to reset your password.');
                            $scope.resetEmailSent = true;
                            $scope.returnToLogin = true;
                            $scope.invalidEmail = false;
                            $scope.emailInput = false;
                            $scope.resetButtons = false;
                        },
                        function(response) { //failure case
                            var errorData = "Our password reset service is currently down, please try again later.";
                            var errorNumber = parseInt(response.data.error);
                            //TODO:Change this to use ccp
                            if (response.status == 406 && errorNumber == 1) {
                                errorData = 'That email address does not exist in our system.';
                            } else if (response.status != 401 && errorNumber != 0) {
                                //TODO:YOU ALREADY KNOW
                                $location.path("/forestFire");
                            }
                            //TODO:Make this angular
                            $("#invalidEmail").html(errorData);
                            $scope.invalidEmail = true;
                        }
                    );
                    //TODO:Make this angular
                    $('#authenticateWorking').removeClass('active');
                } else { // email is not valid
                    $scope.invalidEmail = true;
                }
            }

            var renderContext = requestContext.getRenderContext( "authenticate.requestPassword" );

            $scope.subview = renderContext.getNextSection();
            $scope.invalidEmail = false;
            $scope.resetEmailSent = false;
            $scope.emailInput = true;
            $scope.resetButtons = true;
            $scope.returnToLogin = false;

            //TODO:see if you can pass scope into directive
            $scope.$on(
                "requestContextChanged",
                function() {
                    if ( ! renderContext.isChangeRelevant() ) {
                        return;
                    }
                    $scope.subview = renderContext.getNextSection();
                }
            );
            $scope.setWindowTitle( "AnnoTree" );
        }
    );
})( angular, AnnoTree );
