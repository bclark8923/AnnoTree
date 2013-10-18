(function(ng, app) {
    "use strict";

    app.controller("authenticate.SignupController",
        function($scope, $location, $http, apiRoot, requestContext, constants) {
            function setError(msg) {
                $scope.errorText = msg;
            }

            function validateEmail(email) { 
                var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                return re.test(email);
            }

            $scope.validateSignUp = function() {
                var name = $scope.signUpName;
                var email = $scope.signUpEmail;
                var password = $scope.signUpPassword;
                var formValid = $scope.signUpForm.$valid;
                var numberTest = new RegExp('[0-9]');

                if (!name) {
                    setError('Please fill out your name');
                } else if (!validateEmail(email)) {
                    setError('Please enter a valid email');
                } else if (!password) {
                    setError('Please enter a password');
                } else if (password.length < 6) {
                    setError('Password should contain at least six characters');
                } else if (!numberTest.test(password)) {
                    setError('Password must contain at least one number');
                } else {
                    $('#authenticateWorking').addClass('active'); // TODO: angular way
                    var promise = $http.post(apiRoot.getRoot() + '/services/user/signup', {
                        signUpName: name, 
                        signUpEmail: email, 
                        signUpPassword: password
                    });

                    promise.then(
                        function(response) {
                            $scope.errorText = '';
                            $('#authenticateWorking').removeClass('active'); // TODO: angular way
                            $location.path("/app/ft");
                        },
                        function(response) {
                            if (response.status != 500  && response.status != 502) {
                                setError(response.data.txt);
                            } else {
                               setError(constants.servicesDown());
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
            $scope.errorText = '';
            $scope.signUpEmail = ($location.search()).email || '';
        }
    );
})(angular, AnnoTree);
