(function(ng, app) {
    "use strict";

    app.controller("authenticate.SignupController",
        function($scope, localStorageService, $location, requestContext, authenticateService) {
            function setError(msg) {
                $scope.signUpPassword = '';
                $scope.signUpConfirmPassword = '';
                $scope.errorText = msg;
                $scope.errorMessage = true;
            }

            $scope.validateSignUp = function() {
                var name = $scope.signUpName;
                var email = $scope.signUpEmail;
                var password = $scope.signUpPassword;
                var confirmPassword = $scope.signUpConfirmPassword;
                var formValid = $scope.signUpForm.$valid;
                var numberTest = new RegExp('[0-9]');
                var invalidCharTest = new RegExp('[^A-Za-z0-9!@#\$%\^7\*\(\)]');

                if (!formValid) {
                    if (!name) {
                        setError('Please fill out your name');
                    } else if (!email) {
                        setError('Please enter a valid email');;
                    } else if (!password) {
                        setError('Please enter a password');
                    } else {
                        setError('Please fill out all required fields');;
                    }
                } else if (password.length < 6) {
                    setError('Password should contain at least six characters');
                } else if (confirmPassword != password) {
                    setError('Passwords do not match');
                } else if (!numberTest.test(password)) {
                    setError('Password must contain at least one number');
                } else if (invalidCharTest.test(password)) {
                    setError('Valid password characters are alphanumeric or !@#$%^&*()');
                } else {
                    $('#authenticateWorking').addClass('active'); // TODO: angular way
                    var promise = authenticateService.signup(name, email, password);

                    promise.then(
                        function(response) {
                            $scope.errorMessage = false;
                            // this should just redirect to main app where the user information is then loaded
                            //set session information TODO: remove this
                            $('#authenticateWorking').removeClass('active'); // TODO: angular way
                            //localStorageService.add('username', response.data.first_name + ' ' + response.data.last_name);
                            //localStorageService.add('useravatar', response.data.profile_image_path);
                            $location.path("/app/ft");
                        },
                        function( response ) {
                            if (response.status != 500  && response.status != 502) {
                                setError(response.data.txt);
                            } else {
                               setError('AnnoTree is currently down.  Try again in a few minutes or contact us at support@annotree.com');
                            }
                            $('#authenticateWorking').removeClass('active'); // TODO: angular way
                        }
                    );
                }
            }

            var renderContext = requestContext.getRenderContext("authenticate.signup");
            $scope.subview = renderContext.getNextSection();
            $scope.$on("requestContextChanged", function() {
                if (!renderContext.isChangeRelevant()) {
                    return;
                }
                $scope.subview = renderContext.getNextSection();
            });
            
            $scope.errorMessage = false;
            $scope.setWindowTitle("AnnoTree");
        }
    );
})(angular, AnnoTree);
