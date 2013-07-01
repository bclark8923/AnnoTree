(function( ng, app ){

	"use strict";

	app.controller(
		"forest.LeafController",
		function( $scope, $cookies, $rootScope, $location, $timeout, $route, $routeParams,  requestContext, forestService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function loadLeaf( leaf ) {
				var leafImage = "img/leaf01.png";
				if(leaf.annotations.length > 0) {
					leafImage = leaf.annotations[0].path
				}
               	$scope.leafImage = leafImage;
			}


			// I load the "remote" data from the server.
			function loadLeafData() {

				$scope.isLoading = true;

				var promise = forestService.getLeaf($routeParams.leafID);

				promise.then(
					function( response ) {

						$scope.isLoading = false;
						
						loadLeaf( response.data );

 						$timeout(function() { window.Gumby.init() }, 0);

					},
					function( response ) {

						var errorData = "Our Create Tree Service is currently down, please try again later.";
						var errorNumber = parseInt(response.data.error);
						if(response.data.status == 406) {
							switch(errorNumber)
							{
								case 1:
									errorData = "This user does not exist in our system. Please contact Us.";
									break;
								default:
									//go to Fail Page
							}
						} else if(response.data.status == 204) {
							switch(errorNumber)
							{
								case 2:
									errorData = "This user currently has no forests."; // load a sample page maybe?
									break;
								default:
									//go to Fail Page
							}
						} else {
							//go to Fail Page
						}
					}
				);

			}


			// --- Define Scope Methods. ------------------------ //

			

			// ...


			// --- Define Controller Variables. ----------------- //


			// Get the render context local to this controller (and relevant params).
			var renderContext = requestContext.getRenderContext( "standard.tree.leaf" );

			
			// --- Define Scope Variables. ---------------------- //


			// I flag that data is being loaded.
			$scope.isLoading = true;

			// I hold the categories to render.
			$scope.leafImage = "";

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
			loadLeafData();

			Gumby.init();

		}
	);

 })( angular, AnnoTree );
 
 AnnoTree.filter('treeRowFilter', function() {
    return function(arrayLength) {
        arrayLength = Math.ceil(arrayLength);
        var arr = new Array(arrayLength), i = 0;
        for (; i < arrayLength; i++) {
            arr[i] = i;
        }
        return arr;
    };
});
/**/