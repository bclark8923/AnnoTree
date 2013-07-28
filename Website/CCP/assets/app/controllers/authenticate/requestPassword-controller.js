(function( ng, app ){
    "use strict";

    app.controller(
        "authenticate.RequestpasswordController",
        function( $scope, $location, requestContext, authenticateService, _ ) {

            // --- Define Controller Methods. ------------------- //
            
            // --- Define Scope Methods. ------------------------ //
            $scope.requestPassword = function() {
                var email = $scope.email;
                if (email) { // email is valid
                    $('#authenticateWorking').addClass('active');
                    var promise = authenticateService.requestPassword(email);
                    
                    promise.then(
                        function(response) { //worked
                            $("#textMsg").html('Please check ' + email + ' to reset your password.');
                            $scope.resetEmailSent = true;
                            $scope.returnToLogin = true;
                            $scope.invalidEmail = false;
                            $scope.emailInput = false;
                            $scope.resetButtons = false;
                        },
                        function(response) { //didn't work
                            var errorData = "Our password reset service is currently down, please try again later.";
                            var errorNumber = parseInt(response.data.error);
                            if (response.status == 406 && errorNumber == 1) {
                                errorData = 'That email address does not exist in our system.';
                            } else if (response.status != 401 && errorNumber != 0) {
                                //go to Fail Page
                                $location.path("/forestFire");
                            }
                            $("#invalidEmail").html(errorData);
                            $scope.invalidEmail = true;
                        }
                    );
                    $('#authenticateWorking').removeClass('active');
                } else { // email is not valid
                    $scope.invalidEmail = true;
                }
            }

            // --- Define Controller Variables. ----------------- //

            // Get the render context local to this controller (and relevant params).
            var renderContext = requestContext.getRenderContext( "authenticate.requestPassword" );
            
            // --- Define Scope Variables. ---------------------- //
            
            // The subview indicates which view is going to be rendered on the page.
            $scope.subview = renderContext.getNextSection();
            $scope.invalidEmail = false;
            $scope.resetEmailSent = false;
            $scope.emailInput = true;
            $scope.resetButtons = true;
            $scope.returnToLogin = false;
            // --- Bind To Scope Events. ------------------------ //

            // I handle changes to the request context.
            $scope.$on(
                "requestContextChanged",
                function() {
                    // Make sure this change is relevant to this controller.
                    if ( ! renderContext.isChangeRelevant() ) {
                        return;
                    }

                    // Update the view that is being rendered.
                    $scope.subview = renderContext.getNextSection();
                }
            );

            // --- Initialize. ---------------------------------- //

            // Set the window title.
            $scope.setWindowTitle( "AnnoTree" );
        }
    );
})( angular, AnnoTree );
