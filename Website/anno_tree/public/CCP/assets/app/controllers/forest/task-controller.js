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
					$scope.tasks[taskIndex].checked = NO;
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

				var promise;
				if($routeParams.leafID) {
					promise = forestService.createTaskLeaf($routeParams.treeID, $routeParams.leafID, $scope.newTask);
				} else {
					promise = forestService.createTask($routeParams.treeID, $scope.newTask);
				}

				promise.then(
					function( response ) {

						$scope.isLoading = false;

						$scope.tasks.push(response.data);

						$scope.newTask = "";

					},
					function( response ) {

						var errorData = "Our Create Task Service is currently down, please try again later.";
						var errorNumber = parseInt(response.data.error);
						if(response.data.status == 406) {
							switch(errorNumber)
							{
								case 0:
									errorData = "Please add a name to the task";
									break;
								case 1:
									errorData = "The tree you are trying to add a task to no longer exists";
									break;
								case 2:
									errorData = "The status you tried to apply does not exist";
									break;
								case 3:
									errorData = "Please enter valid characters (alphanumeric) only";
									break;
								default:
									//go to Fail Page
									$location.path("/forestFire");
							}
						} else if(response.data.status != 401 && errorNumber != 0) {
							//go to Fail Page
							$location.path("/forestFire");
						}

						$location.path("/forestFire");
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
						} else if(response.data.status != 401 && errorNumber != 0) {
							//go to Fail Page
							$location.path("/forestFire");
						}
						$location.path("/forestFire");
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