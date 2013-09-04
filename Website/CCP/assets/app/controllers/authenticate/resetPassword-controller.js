(function(ng, app) {
    "use strict";

    app.controller("authenticate.ResetPasswordController",
        function( $scope, $location, requestContext, authenticateService, constants) {
            function setError(msg) {
                $scope.errorText = msg;
                $scope.errorMessage = true;
                $scope.password = '';
                $scope.confirmPassword = '';
            }

            $scope.resetPassword = function() {
                var token = ($location.search()).token;
                var password = $scope.password;
                var confirmPassword = $scope.confirmPassword;
                var numberTest = new RegExp('[0-9]');
                var invalidCharTest = new RegExp('[^A-Za-z0-9!@#\$%\^7\*\(\)]');

                if (password.length < 6) {
                    setError('Password should contain at least six characters where one character is a number');
                } else if (password != confirmPassword) {
                    setError('Passwords do not match');
                } else if (!numberTest.test(password)) {
                    setError('Password must contain at least one number');
                } else if (invalidCharTest.test(password)) {
                    setError('Valid password characters are alphanumeric or !@#$%^&*()');
                } else {
                    $('#authenticateWorking').addClass('active');
                    var promise = authenticateService.resetPassword(password, token);
                    
                    promise.then(
                        function(response) {
                            $scope.textMessage = 'Your password has been successfully reset.  Please login to continue.';
                            $scope.returnToLogin = true;
                            $scope.passwordInput = false;
                            $scope.errorMessage = false;
                            $scope.resetPasswordButton = false;
                            $scope.requestPassword = false;
                            $('#authenticateWorking').removeClass('active'); //TODO angular way
                        },
                        function(response) {
                            if (response.status != 500  && response.status != 502) {
                                setError(response.data.txt);
                                if (response.data.error == 1 || response.data.error == 2) {
                                    $scope.requestPassword = true;
                                }
                            } else {
                               setError(constants.servicesDown());
                            } 
                            $('#authenticateWorking').removeClass('active'); //TODO angular way
                        }
                    );
                }
            }

            var renderContext = requestContext.getRenderContext( "authenticate.resetPassword" );
            $scope.subview = renderContext.getNextSection();
            $scope.$on("requestContextChanged", function() {
                if (!renderContext.isChangeRelevant()) {
                    return;
                }
                $scope.subview = renderContext.getNextSection();
            });

            $scope.errorMessage = false;
            $scope.passwordInput = true;
            $scope.resetPasswordButton = true;
            $scope.returnToLogin = false;
            $scope.requestPassword = false;
            $scope.textMessage = 'Enter your new password';
            $scope.setWindowTitle("AnnoTree");
        }
    );
})(angular, AnnoTree);
