(function( ng, app ){

    "use strict";

    app.controller(
        "authenticate.LoginController",
        function( $scope, $rootScope, localStorageService, $location, requestContext, authenticateService, _ ) {

            function completeLogin( response ) {
                //set session information
                localStorageService.add('username', response.data.first_name + ' ' + response.data.last_name);
                localStorageService.add('useravatar', response.data.profile_image_path);
                $rootScope.user = response.data;
                $location.path("app");
            }


            $scope.validateLogin = function() {

                $scope.$broadcast('$validate');
                

                var email = $scope.loginEmail;
                var password = $scope.loginPassword;
                var loginValid = $scope.loginForm.$valid;

                if(!loginValid) {
                    $scope.invalidLogin = true;
                    if(!email) {
                        $("#validateError").html("Please enter a valid email.");
                    }
                    else if(!password) {
                        $("#validateError").html("Please enter a valid password.");
                    } else {
                        $("#validateError").html("Please enter valid information.");
                    }
                }
                else {
                    //send API call
                    $('#authenticateWorking').addClass('active');
                    var promise = authenticateService.login(email, password);

                    promise.then(
                        function( response ) {

                            $scope.isLoading = false;
                            completeLogin( response );

                        },
                        function( response ) {

                            $scope.invalidLogin = true;
                            var errorData = "Our Login Service is currently down, please try again later.";
                            var errorNumber = parseInt(response.data.error);
                            if(response.status == 406) {
                                switch(errorNumber)
                                {
                                    //TODO:use error messages from web services
                                    case 0:
                                        errorData = "Please fill out all of the fields.";
                                        break;
                                    case 1:
                                        errorData = "This email does not exist in our system.";
                                        break;
                                    default:
                                        //TODO: move this into a function
                                        $location.path("/forestFire");
                                        break;
                                }
                            } else if (response.status == 401) {
                                switch(errorNumber)
                                {
                                    case 1:
                                        errorData = "Invalid Email/Password information.";
                                        break;
                                    default:
                                        $location.path("/forestFire");
                                        break;
                                }
                            } else {
                                $location.path("/forestFire");
                            }
                            $("#validateError").html(errorData);

                            //Function for popping up alerts
                            //$scope.openModalWindow( "error", "Our login service is currently down, please try again later." );

                        }
                    );
                    $('#authenticateWorking').removeClass('active');
                }
            }


            var renderContext = requestContext.getRenderContext( "authenticate.login" );

            $scope.isLoading = true;
            $scope.invalidLogin = false;
            $scope.subview = renderContext.getNextSection();
            
            $scope.$on(
                "requestContextChanged",
                function() {
                    if ( ! renderContext.isChangeRelevant() ) {return;}
                    $scope.subview = renderContext.getNextSection();
                }
            );

            //TODO:Move into main section
            $("#loadingScreen").hide();
            $scope.setWindowTitle( "AnnoTree" );
        }
    );
})( angular, AnnoTree );
