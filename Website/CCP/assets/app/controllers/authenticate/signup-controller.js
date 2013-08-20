(function( ng, app ){

    "use strict";

    app.controller(
        "authenticate.SignupController",
        function( $scope, localStorageService, $location, requestContext, authenticateService, _ ) {



            function completeSignup ( response ) {

                localStorageService.add('username', response.data.first_name + ' ' + response.data.last_name);
                localStorageService.add('useravatar', response.data.profile_image_path);


                $location.path("/app/ft");
            }



            $scope.validateSignUp = function() {
                

                $scope.invalidSignUp = false;


                $scope.$broadcast('$validate');
                

                var name = $scope.signUpName;
                var email = $scope.signUpEmail;
                var password = $scope.signUpPassword;
                var confirmPassword = $scope.signUpConfirmPassword;
                var formValid = $scope.signUpForm.$valid;

                if(!formValid) {
                    $scope.invalidSignUp = true;
                    if(!name) {
                        $("#validateError").html("Please fill out your name.");
                    }
                    else if(!email) {
                        $("#validateError").html("Please enter a valid email.");
                    }
                    else if(!password) {
                        $("#validateError").html("Please enter a valid password.");
                    } else {

                        $("#validateError").html("Please enter valid information.");
                    }
                } else if (password.length < 6) {
                    $("#validateError").html("Password should contain at least six characters and one number");
                    $scope.invalidSignUp = true;
                } else if (confirmPassword != password) {
                    $("#validateError").html("Passwords do not match");
                    $("#signUpPassword").val("");
                    $("#confirmPassword").val("");
                    $scope.invalidSignUp = true;
                } else {

                    $('#authenticateWorking').addClass('active');
                    var promise = authenticateService.signup(name, email, password);

                    promise.then(
                        function( response ) {

                            $scope.isLoading = false;
                            completeSignup ( response );

                        },
                        function( response ) {
                            $scope.invalidSignUp = true;
                            var errorData = "Our Sign Up Service is currently down, please try again later.";
                            var errorNumber = parseInt(response.data.error);
                            //TODO:fix this
                            if(response.status == 406) {
                                switch(errorNumber)
                                {
                                    case 0:
                                        errorData = "Please fill out all of the fields";
                                        break;
                                    case 1:
                                        errorData = "Please check your email format.";
                                        break;
                                    case 2:
                                        errorData = "A user with this email already exists.";
                                        break;
                                    case 3:
                                        errorData = "Your password must be at least 6 characters in length.";
                                        break;
                                    case 4:
                                        errorData = "Your password must contain at least one number.";
                                        break;
                                    case 5:
                                        errorData = "A nonvalid character was used, valid characters are alphanumeric and !@#$%^&*()";
                                    case 6:
                                        errorData = response.data.txt;
                                        break;
                                    default:
                                        $location.path("/forestFire");
                                }
                            } else {
                                //go to Fail Page
                                $location.path("/forestFire");
                            }
                            $("#validateError").html(errorData);

                        }
                    );
                    $('#authenticateWorking').removeClass('active');
                }
            }

            var renderContext = requestContext.getRenderContext( "authenticate.signup" );
            $scope.isLoading = true;
            $scope.invalidSignUp = false;
            $scope.subview = renderContext.getNextSection();
            
            $scope.$on(
                "requestContextChanged",
                function() {
                    if ( ! renderContext.isChangeRelevant() ) { return;}
                    $scope.subview = renderContext.getNextSection();
                }
            );
            $scope.setWindowTitle( "AnnoTree" );
        }
    );
 })( angular, AnnoTree );
