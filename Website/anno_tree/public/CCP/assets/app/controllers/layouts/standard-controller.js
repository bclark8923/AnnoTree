(function( ng, app ){

	"use strict";

	app.controller(
		"layouts.StandardController",
		function( $scope, $cookies, $location, authenticateService, requestContext, _ ) {


			// --- Define Controller Methods. ------------------- //

			$scope.logout = function() {

				var promise = authenticateService.logout();

				promise.then(
					function( response ) {

						$location.path('authenticate/login');

					},
					function( response ) {

						$scope.openModalWindow( "error", "Sorry, the logout service is currently down." );

					}
				);
			}

			// ...


			// --- Define Scope Methods. ------------------------ //


			// ...


			// --- Define Controller Variables. ----------------- //


			// Get the render context local to this controller (and relevant params).
			var renderContext = requestContext.getRenderContext( "standard" );

			
			// --- Define Scope Variables. ---------------------- //


			// The subview indicates which view is going to be rendered on the page.
			$scope.subview = renderContext.getNextSection();

			// Get the current year for copyright output.
			$scope.copyrightYear = ( new Date() ).getFullYear();

            $scope.user = $cookies['name'];


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


			// ...


		}
	);

})( angular, AnnoTree );