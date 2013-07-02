(function( ng, app ){

	"use strict";

	app.controller(
		"forest.TaskController",
		function( $scope, $cookies, $rootScope, $location, $timeout, $route, $routeParams,  requestContext, forestService, _ ) {


			// --- Define Controller Methods. ------------------- //


			$scope.toggleCheck = function (task) {
				var taskIndex = $scope.tasks.indexOf(task);
				if($scope.tasks[taskIndex].status == 1) {
					$scope.tasks[taskIndex].status = 2;
					//send update to Service
				} else {
					$scope.tasks[taskIndex].status = 1;
					//send update to Service
				}
		    };

			// I apply the remote data to the local view model.
			$scope.addTask = function() {

				$scope.isLoading = true;

				var taskDescription = "Hello";
				if(!$scope.newTask) {
					//error
					return;
				}

				var promise = forestService.createTask($routeParams.treeID, $scope.newTask);

				promise.then(
					function( response ) {

						$scope.isLoading = false;

						$scope.tasks.push(response.data);

						$scope.newTask = "";

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
						} else if(response.data.status != 401 && errorNumber != 0) {
							//go to Fail Page
							$location.path("/forestFire");
						}
					}
				);

			}

			// I load the "remote" data from the server.
			function loadTasksData() {

				$scope.isLoading = true;

				var promise = forestService.getTasks($routeParams.treeID);

				promise.then(
					function( response ) {

						$scope.isLoading = false;

						$scope.tasks = response.data.tasks;
						/*$scope.branchID = response.data.branches[0].id;
				        $scope.treeInfo = response.data;
						
						loadLeaves( response.data.branches[0].leaves );*/

 						//$timeout(function() { window.Gumby.init() }, 0);

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
						} else if(response.data.status != 401 && errorNumber != 0) {
							//go to Fail Page
							$location.path("/forestFire");
						}
					}
				);

			}
			// ...


			// --- Define Controller Variables. ----------------- //


			// Get the render context local to this controller (and relevant params).
			var renderContext = requestContext.getRenderContext( "standard.tree" );

			
			// --- Define Scope Variables. ---------------------- //


			// I flag that data is being loaded.
			$scope.isLoading = true;

			// I hold the categories to render.
            //$scope.tasks = [{id: "1", description: "Make sign up fields vertically aligned", status: "0"}, {id: "2", description: "Make the sign up button larger", status: "0"}, {id: "3", description: "Change sign up button to darker green", status: "1"}];
            $scope.tasks = [];

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
			$scope.$evalAsync(loadTasksData());

			Gumby.init();

		}
	);

 })( angular, AnnoTree );