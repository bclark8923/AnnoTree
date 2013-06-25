(function( ng, app ){

	"use strict";

	app.controller(
		"forest.ForestController",
		function( $scope, $cookies, requestContext, forestService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function loadTrees( forests ) {

				//$scope.categories = _.sortOnProperty( categories, "name", "asc" );
                   
                   $scope.forests = forests.forests;//_.sortOnProperty( trees.data, "name", "asc");
			}


			// I load the "remote" data from the server.
			function loadRemoteData() {

				$scope.isLoading = true;

				var promise = forestService.getTrees();

				promise.then(
					function( response ) {

						$scope.isLoading = false;

						loadTrees( response.data );

					},
					function( response ) {

						var fake = {
							forests : 	[
											{
												description: "A company for only the truly brave",
												name: "Silith.io",
												created_at: "2013-06-22 02:15:31",
												id: "1",
												trees: [
														{ 
															id: "1",
													   		name: "Test01",
														   	description: "description",
														   	logo: "img/user.png"
														},
														{ 
															id: "2",
													   		name: "Test02",
														   	description: "description",
														   	logo: "NULL"
														},
														{ 
															id: "1",
													   		name: "Test01",
														   	description: "description",
														   	logo: "NULL"
														},
														{ 
															id: "2",
													   		name: "Test02",
														   	description: "description",
														   	logo: "NULL"
														}
												]
											},
											{
												description: "The best iOS Game Studio EVER",
												name: "Shock Games Studios",
												created_at: "2011-06-22 02:15:31",
												id: "2",
												trees: [
														{ 
															id: "1",
													   		name: "Test01",
														   	description: "description",
														   	logo: "NULL"
														},
														{ 
															id: "2",
													   		name: "Test02",
														   	description: "description",
														   	logo: "NULL"
														},
												]
											}
										]
									};

						loadTrees( fake );
						//$scope.openModalWindow( "error", "For some reason we couldn't load the categories. Try refreshing your browser." );

					}
				);

			}


			// --- Define Scope Methods. ------------------------ //

			$scope.newTree = function() {

				var newTree = { 
								id: "17",
						   		name: "Test17",
							   	description: "fuuuuckkk",
							   	logo: "NULL"
							};
				var newForest = {
					description: "The best iOS Game Studio EVER",
					name: "Shock Games Studios",
					created_at: "2011-06-22 02:15:31",
					id: "2",
					trees: [
							{ 
								id: "1",
						   		name: "Test01",
							   	description: "description",
							   	logo: "NULL"
							},
							{ 
								id: "2",
						   		name: "Test02",
							   	description: "description",
							   	logo: "NULL"
							},
					]
				};

				$scope.forests[0].name = "fucked";
				$scope.forests[0].trees.push(newTree);
				//$scope.forests.push(newForest);

				$scope.$apply;
			}

			// ...


			// --- Define Controller Variables. ----------------- //


			// Get the render context local to this controller (and relevant params).
			var renderContext = requestContext.getRenderContext( "standard.forest" );

			
			// --- Define Scope Variables. ---------------------- //


			// I flag that data is being loaded.
			$scope.isLoading = true;

			// I hold the categories to render.
            $scope.forest = [];

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
			if(!$scope.subview) {
				window.Gumby.init();
			}

			loadRemoteData();

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
/*
$(document).ready(function() {
	  var width = 80;
	  settingsPane = new SlidingPane({
	    id: 'mobileOptions',
	    targetId: 'wrapper',
	    side: 'right',
	    width: 240,
	    duration: 0.75,
	    timingFunction: 'ease',
	    shadowStyle: '0px 0px 0px #000'
	  });
	
  $("#paneToggle").click(function() {
  	if($("#mobileOptions").length) {
    	settingsPane.toggle();
	}
  });
});*/