(function( ng, app ){

	"use strict";

	app.controller(
		"forest.ForestController",
		function( $scope, $cookies, $rootScope, requestContext, forestService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function loadTrees( forests ) {

				for(var i = 0; i < forests.length; i++) {
					forests[i].trees.push($scope.newTreeHolder);
				}

               	$scope.forests = forests;

				window.Gumby.init();
			}


			// I load the "remote" data from the server.
			function loadRemoteData() {

				$scope.isLoading = true;

				var promise = forestService.getTrees();

				promise.then(
					function( response ) {

						$scope.isLoading = false;

						loadTrees( response.data.forests );

					},
					function( response ) {

						if(response.status != 401 && response.data.error != 0) {
							$scope.openModalWindow( "error", "Get Forest Failed :(." );
						}
					}
				);

			}


			// --- Define Scope Methods. ------------------------ //

			function addTree(newTree) {

				for(var i = 0; i < $scope.forests.length; i++) { 
					if($scope.forests[i].id == newTree.forest_id) {
						$scope.forests[i].trees.pop();
						$scope.forests[i].trees.push(newTree);
						$scope.forests[i].trees.push($scope.newTreeHolder);
						break;
					}
				}

				$("#newTreeClose").click();

				$scope.invalidAddTree = false;

				//window.Gumby.init();

			}

			$scope.newTree = function() {

				var treeName = $scope.treeName;
				var treeDescription = $scope.treeDescription;
				var formValid = $scope.createTreeForm.$valid;
				var forestID = $(".newTreeLinkClass.active").attr('id').split("-")[1];

				//validate form
				if(!formValid) {
					$scope.invalidAddTree = true;
					if(!treeName) {
						$("#invalidAddTree").html("Please fill out a tree name.");
					}
					else if(!treeDescription) {
						$("#invalidAddTree").html("Please fill out a tree description.");
					} else {
						//shouldn't happen
						$("#invalidAddTree").html("Please enter valid information.");
					}
				} else {
					//return;
					var promise = forestService.createTree(forestID, treeName, treeDescription);

					promise.then(
						function( response ) {

							$scope.isLoading = false;

							addTree( response.data );

						},
						function( response ) {

							$("#invalidAddTree").html("The tree failed to add. Please try again later.");

						}
					);
				}
			}

			function addForest(newForest) {

				newForest.trees = [];
				newForest.trees.push($scope.newTreeHolder);
				$scope.forests.push(newForest);

				//$scope.$apply();
				$("#newForestClose").click();
				$scope.invalidAddForest = false;

				window.Gumby.init();

			}

			$scope.newForest = function() {
				var forestName = $scope.forestName;
				var forestDescription = $scope.forestDescription;
				var formValid = $scope.createForestForm.$valid;

				//validate form
				if(!formValid) {
					$scope.invalidAddForest = true;
					if(!forestName) {
						$("#invalidAddForest").html("Please fill out a forest name.");
					}
					else if(!forestDescription) {
						$("#invalidAddForest").html("Please fill out a forest description.");
					} else {
						//shouldn't happen
						$("#invalidAddForest").html("Please enter valid information.");
					}
				} else {
					var promise = forestService.createForest(forestName, forestDescription);

					promise.then(
						function( response ) {

							$scope.isLoading = false;

							addForest( response.data );

						},
						function( response ) {

							$("#invalidAddForest").html("The forest failed to add. Please try again later.");

						}
					);
				}
			}

			// ...


			// --- Define Controller Variables. ----------------- //


			// Get the render context local to this controller (and relevant params).
			var renderContext = requestContext.getRenderContext( "standard.forest" );

			
			// --- Define Scope Variables. ---------------------- //


			// I flag that data is being loaded.
			$scope.isLoading = true;

			// I hold the categories to render.
            $scope.forests = [];

			// The subview indicates which view is going to be rendered on the page.
			$scope.subview = renderContext.getNextSection();

			$scope.newTreeHolder = { 
								id: "-1",
						   		name: "New Tree",
							   	description: "Click here to add a new tree to this forest.",
							   	logo: "img/tree01.png"
							};
			

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
			loadRemoteData();

			window.Gumby.init();

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