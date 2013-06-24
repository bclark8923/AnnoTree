(function( ng, app ){

	"use strict";

	app.controller(
		"authenticate.SignupController",
		function( $scope, $cookies, $location, requestContext, authenticateService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function completeSignup ( response ) {
				//set session information
				var date = new Date().getTime();
				$cookies.sessionid = response.data.id;
				$cookies.username = response.data.first_name + " " + response.data.last_name;
				$cookies.userid = response.data.id;
				$cookies.avatar = response.data.profile_image_path;

				//redirect to app
				$location.path("app");
			}


			// I load the "remote" data from the server.
			$scope.validateSignUp = function() {
				
				//Mark the form as valid
				$scope.invalidSignUp = false;

				//check for validation
				$scope.$broadcast('$validate');
				
				//obtain the values
				var name = $scope.signUpName;
				var email = $scope.signUpEmail;
				var password = $scope.signUpPassword;
				var formValid = $scope.signUpForm.$valid;
				
				//validate form
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
						//shouldn't happen
						$("#validateError").html("Please enter valid information.");
					}
				}
				else {
					//Send signup api call
					var promise = authenticateService.signup(name, email, password);

					promise.then(
						function( response ) {

							$scope.isLoading = false;
							//complete signup
							completeSignup ( response );

						},
						function( response ) {
							//error responses from API
							$scope.invalidSignUp = true;
							var errorData = "Our Sign Up Service is currently down, please try again later.";
							var errorNumber = parseInt(response.data.error);
							switch(errorNumber)
							{
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
									errorData = "a nonvalid character was used, valid characters are alphanumeric and !@#$%^&*()";
									break;
								case 6:
									errorData = "Please fill out all of the fields";
									break;
								default:
									//stuff
							}
							$("#validateError").html(errorData);
							//$scope.openModalWindow( "error", errorData );

						}
					);
				}

			}


			// --- Define Scope Methods. ------------------------ //


			// ...


			// --- Define Controller Variables. ----------------- //


			// Get the render context local to this controller (and relevant params).
			var renderContext = requestContext.getRenderContext( "authenticate.signup" );

			
			// --- Define Scope Variables. ---------------------- //


			// I flag that data is being loaded.
			$scope.isLoading = true;

			//set the form to valid
			$scope.invalidSignUp = false;

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


			// Set the window title.
			$scope.setWindowTitle( "AnnoTree" );

		}
	);

 })( angular, AnnoTree );