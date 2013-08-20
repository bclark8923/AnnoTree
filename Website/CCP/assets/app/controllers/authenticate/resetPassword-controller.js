(function( ng, app ){

    "use strict";

    app.controller(
        "authenticate.ResetpasswordController",
        function( $scope, $location, requestContext, authenticateService, _ ) {

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
                                //TODO:same thing
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


            var renderContext = requestContext.getRenderContext( "authenticate.resetPassword" );

            $scope.subview = renderContext.getNextSection();
            $scope.$on(
                "requestContextChanged",
                function() {
                    if ( ! renderContext.isChangeRelevant() ) {
                        return;
                    }
                    $scope.subview = renderContext.getNextSection();
                }
            );

            $scope.errorMsg = false;
            $scope.emailInput = true;
            $scope.passwordInput = true;
            $scope.resetPasswordButton = true;
            $scope.returnToLogin = false;
            $scope.requestPassword = false;

            $scope.setWindowTitle( "AnnoTree" );
        }
    );
})( angular, AnnoTree );
