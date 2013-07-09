(function( ng, app ){

	"use strict";

	app.controller(
		"forest.TaskController",
		function( $scope, $cookies, $rootScope, $location, $timeout, $route, $routeParams,  requestContext, forestService, _ ) {


			// --- Define Controller Methods. ------------------- //


			$scope.toggleCheck = function (task) {
				var task = $rootScope.tasks[$rootScope.tasks.indexOf(task)];
				$rootScope.newStatus = 1;
				if(task.status == 1) {
					$rootScope.newStatus = 2;
				} 
				//send update to Service
				$rootScope.updatingTask = $rootScope.tasks.indexOf(task);
				var promise = forestService.updateTask(task.id, task.leaf_id, task.description, $rootScope.newStatus, "", "");
				promise.then(
					function( response ) {

						if($rootScope.updatingTask == -1) {
							$location.path("/forestFire");
						} else {
							$rootScope.tasks[$rootScope.updatingTask].status = $rootScope.newStatus;
							$rootScope.tasks[$rootScope.updatingTask].checked = false;
						}
						$("#loadingScreen").hide();

					},
					function( response ) {

						var errorData = "Our Update Task Service is currently down, please try again later.";
						var errorNumber = parseInt(response.data.error);
						if(response.data.status == 406) {
							switch(errorNumber)
							{
								case 0:
									errorData = "Please add a name to the task";
									break;
								case 1:
									errorData = "Please have at least one alphanumeric character";
									break;
								case 2:
									errorData = "The task you tried to update no longer exists";
									break;
								case 3:
									errorData = "You don't have access to modify this tree";
									break;
								case 4:
									errorData = "Invalid task status";
									break;
								case 5:
									errorData = "You assigned this to a person that does not exist";
									break;
								case 6:
									errorData = "The leaf you tried to assign to no longer exists";
									break;
								default:
									//go to Fail Page
									//$location.path("/forestFire");
							}
							alert(errorData);
						} else if(response.data.status != 401 && errorNumber != 0) {
							//go to Fail Page
							//$location.path("/forestFire");
							//alert(errorData);
						}
						$("#loadingScreen").hide();
					}
				);
		    };

		    $scope.showTaskOpen = function(task) {
				if($routeParams.leafID) {
					
					if(task.status == 1 && $routeParams.leafID == task.leaf_id) {
						return true;
					} else {
						return false;
					}
				} else {
					if(task.status == 1) {
						return true;
					} else {
						return false;
					}
				}
		    }

		    $scope.showTaskClosed = function(task) {
				if($routeParams.leafID) {
					
					if(task.status == 2 && $routeParams.leafID == task.leaf_id) {
						return true;
					} else {
						return false;
					}
				} else {
					if(task.status == 2) {
						return true;
					} else {
						return false;
					}
				}
		    }

		    $scope.showAddTask = function() {
		    	$('.newTaskButton').hide();
		    	$(".addTaskButton").show();
		    	$(".doneTaskButton").show();
		    	$(".addTask").show();
		    }

		    $scope.doneAddTask = function() {
		    	$('.newTaskButton').show();
		    	$(".addTaskButton").hide();
		    	$(".doneTaskButton").hide();
		    	$(".addTask").hide();
		    }

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

						$rootScope.isLoading = false;

						$rootScope.tasks.push(response.data);

						$scope.newTask = "";
						$("#loadingScreen").hide();

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
									//$location.path("/forestFire");
							}
							alert(errorData);
						} else if(response.data.status != 401 && errorNumber != 0) {
							//go to Fail Page
							$location.path("/forestFire");
							//alert(errorData);
						}
				$("#loadingScreen").hide();

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

						$rootScope.tasks = response.data.tasks;

					},
					function( response ) {

						var errorData = "Our Load Task Service is currently down, please try again later.";
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
            $rootScope.tasks = [];
            $rootScope.updatingTask = -1;
			$rootScope.newStatus = -1;

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