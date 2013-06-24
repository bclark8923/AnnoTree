(function( ng, app ){

	"use strict";

	app.controller(
		"authenticate.LoginController",
		function( $scope, $cookies, $location, requestContext, authenticateService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function completeLogin( response ) {
				//set session information
				var date = new Date().getTime();
				$cookies.sessionid = response.data.id;
				$cookies.username = response.data.first_name + " " + response.data.last_name;
				//$cookies.userid = response.data.id;
				$cookies.avatar = response.data.profile_image_path;

				//redirect to app
				$location.path("app");
			}


			$scope.validateLogin = function() {
				
				//Mark the form as valid
				$scope.invalidLogin = false;

				//check for validation
				$scope.$broadcast('$validate');
				
				//obtain the values
				var email = $scope.loginEmail;
				var password = $scope.loginPassword;
				var formValid = $scope.loginForm.$valid;

				//validate form
				if(!formValid) {
					$scope.invalidLogin = true;
					if(!email) {
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
					//send API call
					var promise = authenticateService.login(email, password);

					promise.then(
						function( response ) {

							$scope.isLoading = false;
							//complete login
							completeLogin( response );

						},
						function( response ) {
							//error responses from API
							$scope.invalidLogin = true;
							var errorData = "Our Login Service is currently down, please try again later.";
							var errorNumber = parseInt(response.data.error);
							switch(errorNumber)
							{
								case 0:
									errorData = "Invalid Email/Password information.";
									break;
								case 1:
									errorData = "We did not find a user with this email.";
									break;
								case 6:
									errorData = "Please fill out all of the fields";
									break;
								default:
									//stuff
							}
							$("#validateError").html(errorData);
							//$scope.openModalWindow( "error", "Our login service is currently down, please try again later." );

						}
					);
				}
			}


			// --- Define Scope Methods. ------------------------ //


			// ...


			// --- Define Controller Variables. ----------------- //


			// Get the render context local to this controller (and relevant params).
			var renderContext = requestContext.getRenderContext( "authenticate.login" );

			
			// --- Define Scope Variables. ---------------------- //


			// I flag that data is being loaded.
			$scope.isLoading = true;

			//set the form to valid
			$scope.invalidLogin = false;


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