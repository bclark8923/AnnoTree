(function( ng, app ){

	"use strict";

	app.controller(
		"authenticate.SignupController",
		function( $scope, requestContext, authenticateService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function applyRemoteData( userTrees ) {

				//$scope.categories = _.sortOnProperty( categories, "name", "asc" );
                   
                   //$scope.userTrees = _.sortOnProperty( userTrees.data, "name", "asc");

			}


			// I load the "remote" data from the server.
			$scope.validateSignUp = function() {

				var name = $scope.signUpName;
				var email = $scope.signUpEmail;
				var password = $scope.signUpPassword;
				/*var valid = signUpForm.$valid;
				return 1;*/
				//validate for

				//submit signup
				if(true) {
					var promise = authenticateService.signup(name, email, password);

					promise.then(
						function( response ) {

							$scope.isLoading = false;

							applyRemoteData( response );

						},
						function( response ) {

							$scope.openModalWindow( "error", "Our Sign Up Service is currently down, please try again later." );

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

			// I hold the categories to render.
			$scope.categories = [];
            $scope.userTrees = [];

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

			// Load the "remote" data.
			//loadRemoteData();


		}
	);

 })( angular, AnnoTree );