(function( ng, app ){

	"use strict";

	app.controller(
		"forest.ForestController",
		function( $scope, $cookies, $rootScope, $location, $timeout, $route, requestContext, forestService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function loadTrees( forests ) {

				for(var i = 0; i < forests.length; i++) {
					forests[i].trees.push($scope.newTreeHolder);
				}

               	$scope.forests = forests;
			}


			// I load the "remote" data from the server.
			function loadForestData() {

				$scope.isLoading = true;

				var promise = forestService.getTrees();

				promise.then(
					function( response ) {

						$scope.isLoading = false;

						loadTrees( response.data.forests );

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
									$location.path("/forestFire");
							}
						} else if(response.data.status == 204) {
							switch(errorNumber)
							{
								case 2:
									errorData = "This user currently has no forests."; // load a sample page maybe?
									break;
								default:
									//go to Fail Page
									$location.path("/forestFire");
							}
						} else {
							//go to Fail Page
							$location.path("/forestFire");
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

				$location.path("/app");

				$route.reload();


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
 				
 							$timeout(function() { Gumby.initialize('switches') }, 0);

						},
						function( response ) {
							var errorData = "Our Create Tree Service is currently down, please try again later.";
							var errorNumber = parseInt(response.data.error);
							if(response.data.status == 406) {
								switch(errorNumber)
								{
									case 0:
										errorData = "Please fill out all of the fields";
										break;
									case 1:
										errorData = "This user does not exist in our system. Please contact Us.";
										break;
									case 2:
										errorData = "The forest you attempted to add to no longer exists.";
										break;
									case 4:
										errorData = "Please enter a valid forest name.";
										break;
									default:
										//go to Fail Page
								}
							} else if(response.data.status == 403) {
								switch(errorNumber)
								{
									case 3:
										errorData = "You currently don't have permission to create a tree in this forest.";
										break;
									default:
										//go to Fail Page
										$location.path("/forestFire");
								}
							} else {
								//go to Fail Page
								$location.path("/forestFire");
							}
							$("#invalidAddTree").html(errorData);

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

				$location.path("/app");

				$route.reload();

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
 				
 							$timeout(function() { Gumby.initialize('switches') }, 0);

						},
						function( response ) {
							var errorData = "Our Create Forest Service is currently down, please try again later.";
							var errorNumber = parseInt(response.data.error);
							if(response.data.status == 406) {
								switch(errorNumber)
								{
									case 0:
										errorData = "Please fill out all of the fields";
										break;
									case 1:
										errorData = "This user does not exist in our system. Please contact Us.";
										break;
									case 2:
										errorData = "Please enter a valid forest name.";
										break;
									default:
										//go to Fail Page
										$location.path("/forestFire");	
								}
							} else {
								//go to Fail Page
								$location.path("/forestFire");
							}
							$("#invalidAddForest").html(errorData);

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
            $scope.branchID = -1;

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
			$scope.$evalAsync(loadForestData());

			Gumby.init();

		}
	);

 })( angular, AnnoTree );
/**/