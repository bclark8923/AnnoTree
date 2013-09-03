(function(ng, app){
    "use strict";

    app.controller("authenticate.RequestPasswordController",
        function($scope, $location, requestContext, authenticateService) {
            function setError(msg) {
                $scope.errorText = msg;
                $scope.errorMessage = true;
                $scope.email = '';
            }

            $scope.requestPassword = function() {
                var email = $scope.email;
                if (email) {
                    $('#authenticateWorking').addClass('active'); //TODO: angular way
                    var promise = authenticateService.requestPassword(email);
                    
                    promise.then(
                        function(response) {
                            $scope.textMsg = 'Please check ' + email + ' to reset your password.';
                            $scope.returnToLogin = true;
                            $scope.errorMessage = false;
                            $scope.emailInput = false;
                            $scope.resetButtons = false;
                            $('#authenticateWorking').removeClass('active'); //TODO:Make this angular
                        },
                        function(response) { //failure case
                            if (response.status != 500  && response.status != 502) {
                                setError(response.data.txt);
                            } else {
                               setError('AnnoTree is currently down.  Try again in a few minutes or contact us at support@annotree.com');
                            }
                        $('#authenticateWorking').removeClass('active'); //TODO:Make this angular
                        }
                    );
                    
                } else {
                    setError('Enter a valid email');
                }
            }

            var renderContext = requestContext.getRenderContext( "authenticate.requestPassword" );
            //TODO:see if you can pass scope into directive
            $scope.$on("requestContextChanged", function() {
                if (!renderContext.isChangeRelevant()) {
                    return;
                }
                $scope.subview = renderContext.getNextSection();
            });

            $scope.subview = renderContext.getNextSection();
            $scope.invalidEmail = false;
            $scope.emailInput = true;
            $scope.resetButtons = true;
            $scope.returnToLogin = false;
            $scope.textMessage = 'Enter your email and we will send you a reset link';
            $scope.setWindowTitle( "AnnoTree" );
        }
    );
})(angular, AnnoTree);
