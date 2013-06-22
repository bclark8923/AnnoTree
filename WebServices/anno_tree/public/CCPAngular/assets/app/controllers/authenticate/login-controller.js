(function( ng, app ){

	"use strict";

	app.controller(
		"authenticate.LoginController",
		function( $scope, $cookies, $location, requestContext, authenticateService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function completeLogin( response ) {

				var date = new Date().getTime();
				$cookies.sessionid = response.data.id;
				$cookies.username = response.data.first_name + " " + response.data.last_name;
				$cookies.userid = response.data.id;
				$cookies.avatar = response.data.profile_image_path;

				$location.path("app");
			}


			$scope.validateLogin = function() {

				var email = $scope.loginEmail;
				var password = $scope.loginPassword;

				if(true) {
					var promise = authenticateService.login(email, password);

					promise.then(
						function( response ) {

							$scope.isLoading = false;

							completeLogin( response );

						},
						function( response ) {

							$scope.openModalWindow( "error", "Our login service is currently down, please try again later." );

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