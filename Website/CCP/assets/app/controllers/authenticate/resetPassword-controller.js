(function( ng, app ){

    "use strict";

    app.controller(
        "authenticate.ResetpasswordController",
        function( $scope, $location, requestContext, authenticateService, _ ) {

            // --- Define Controller Methods. ------------------- //
            
            // --- Define Scope Methods. ------------------------ //
            $scope.resetPassword = function() {
                var token = ($location.search()).token;
                var password = $scope.password;
                var confirmPassword = $scope.confirmPassword;
                if (typeof password === 'undefined') {
                    password = '';
                }

                if (password.length < 6) {
                    $("#errorMsg").html("Password should contain at least six characters where one character is a number");
                    $scope.errorMsg = true; 
                    
                } else if (password != confirmPassword) {
                    $("#errorMsg").html("Passwords do not match");
                    $("#newPassword").val("");
                    $("#confirmNewPassword").val("");
                    $scope.errorMsg = true; 
                } else { // password are valid
                    $('#authenticateWorking').addClass('active');
                    var promise = authenticateService.resetPassword(password, token);
                    
                    promise.then(
                        function(response) { // success
                            $('#textMsg').html('Your password has been successfully reset. Please login to continue.');
                            $scope.returnToLogin = true;
                            $scope.passwordInput = false;
                            $scope.emailInput = false;
                            $scope.errorMsg = false;
                            $scope.resetPasswordButton = false;
                            $scope.requestPassword = false;
                        },
                        function(response) { // not successful
                            var errorData = "Our password reset service is currently down, please try again later.";
                            var errorNumber = parseInt(response.data.error);
                            if (response.status == 406) {
                                errorData = response.data.txt;
                            } else if (response.status != 401 && errorNumber != 0) {
                                //go to Fail Page
                                $location.path("/forestFire");
                            }
                            $("#errorMsg").html(errorData);
                            $scope.errorMsg = true;
                            if (errorNumber == 1 || errorNumber == 2) {
                                $scope.requestPassword = true;
                            }
                        }
                    );
                    $('#authenticateWorking').removeClass('active');
                }
            }

            // --- Define Controller Variables. ----------------- //

            // Get the render context local to this controller (and relevant params).
            var renderContext = requestContext.getRenderContext( "authenticate.resetPassword" );
            
            // --- Define Scope Variables. ---------------------- //

            // The subview indicates which view is going to be rendered on the page.
            $scope.subview = renderContext.getNextSection();

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
            $scope.errorMsg = false;
            $scope.emailInput = true;
            $scope.passwordInput = true;
            $scope.resetPasswordButton = true;
            $scope.returnToLogin = false;
            $scope.requestPassword = false;

            // Set the window title.
            $scope.setWindowTitle( "AnnoTree" );
        }
    );
})( angular, AnnoTree );
