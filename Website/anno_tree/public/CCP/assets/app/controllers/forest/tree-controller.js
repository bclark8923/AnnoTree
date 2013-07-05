(function( ng, app ){

	"use strict";

	app.controller(
		"forest.TreeController",
		function( $scope, $cookies, $rootScope, $location, $timeout, $route, $routeParams,  requestContext, forestService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function loadLeaves( leaves ) {

				for (var i = 0; i < leaves.length; i++) {
					if(leaves[i].annotations.length > 0) {
						leaves[i].annotation = leaves[i].annotations[0].path;
					} else {
						leaves[i].annotation = "img/tree01.png";
					}
				}
               	$rootScope.leaves = leaves;
			}


			// I load the "remote" data from the server.
			function loadTreeData() {

				$scope.isLoading = true;

				var promise = forestService.getTree($routeParams.treeID);

				promise.then(
					function( response ) {

						$scope.isLoading = false;

				        $scope.treeInfo = response.data;
						
						if(response.data.branches.length == 0) {
							$location.path("/forestFire");
						} else {
							loadLeaves( response.data.branches[0].leaves );

	 						$timeout(function() { window.Gumby.init() }, 0);	
						}
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
					}
				);

			}


			// --- Define Scope Methods. ------------------------ //

			function addLeaf(newLeaf) {

				$rootScope.leaves.push(newLeaf);

				$("#newLeafClose").click();

				$scope.invalidAddLeaf = false;

				/*$route.reload();

				if(!$scope.$$phase) {
					$scope.$apply();
				}*/

			}

			$scope.openNewLeafModal = function () {
				$("#newLeafModal").addClass('active');
			}

			$scope.closeNewLeafModal = function () {
				$("#newLeafModal").removeClass('active');
				$("#invalidAddLeaf").html('');
				$("#leafName").val('');
				$("#annotationImage").val('');
				$scope.invalidAddLeaf = false; 
				$("#loadingScreen").hide();
			}

			function newAnnotation(leafID) {
			    $scope.files = []
			    var annotationImageElement = document.getElementById('annotationImage');
			    var files = annotationImageElement.files
			    //console.log('files:', files)
			    for (var i = 0; i < files.length; i++) {
			        $scope.files.push(files[i])
			    }

				var fd = new FormData()
		        for (var i in $scope.files) {
		            fd.append("uploadedFile", $scope.files[i]);
		        }
		        var xhr = new XMLHttpRequest();

		        //xhr.upload.addEventListener("progress", uploadProgress, false)
		        xhr.addEventListener("load", uploadComplete, false)
		        xhr.addEventListener("error", uploadFailed, false)
		        xhr.addEventListener("abort", uploadCanceled, false)
		        forestService.createAnnotation(leafID, fd, xhr);
		    }

		    function uploadComplete(evt) {
		        /* This event is raised when the server send back a response */
		        //alert(evt.target.responseText);	
		        var annotationObject = jQuery.parseJSON( evt.target.responseText );
		        $scope.newLeafData.annotations.push(annotationObject);
		        $scope.newLeafData.annotation = annotationObject.path;
				addLeaf( $scope.newLeafData );
		    }

		    function uploadFailed(evt) {
		        /* This event is raised when the server send back a response */
		        alert(evt.target.responseText);
		        //delete new leaf
				$location.path("/forestFire");
		    }

		    function uploadCanceled(evt) {
		        /* This event is raised when the server send back a response */
		        alert(evt.target.responseText);
		        //delete new leaf
				$location.path("/forestFire");
		    }

			$scope.newLeaf = function() {

				var leafName = $scope.leafName;
				var leafDescription = "NULL";
			    var annotationImageElement = document.getElementById('annotationImage');
				var formValid = $scope.createLeafForm.$valid;
				var branchID = $scope.treeInfo.branches[0].id;

				//validate form
				if(!formValid || annotationImageElement.files.length == 0) {
					$scope.invalidAddLeaf = true;
					if(!leafName) {
						$("#invalidAddLeaf").html("Please fill out a leaf name.");
					} else if (annotationImageElement.files.length == 0) {
						$("#invalidAddLeaf").html("Please add an image.");
					} else {
						//shouldn't happen
						$("#invalidAddLeaf").html("Please enter valid information.");
					}
				} else {
					//return;
					var promise = forestService.createLeaf(branchID, leafName, leafDescription);

					promise.then(
						function( response ) {

							$scope.isLoading = false;

							$scope.newLeafData = response.data;
							$scope.newLeafData.annotations = [];

							newAnnotation(response.data.id);
 				
 							$timeout(function() { Gumby.initialize('switches') }, 0);

						},
						function( response ) {
							var errorData = "Our Create Leaf Service is currently down, please try again later.";
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
										errorData = "The branch you attempted to add to no longer exists.";
										break;
									case 4:
										errorData = "Please enter a valid leaf name.";
										break;
									default:
										//go to Fail Page
										//$location.path("/forestFire");
								}
							} else if(response.data.status != 401 && errorNumber != 0) {
								//go to Fail Page
								//$location.path("/forestFire");
								alert(errorData);
							}
							$("#invalidAddTree").html(errorData);

						}
					);
				}
			}

			// ...


			// --- Define Controller Variables. ----------------- //


			// Get the render context local to this controller (and relevant params).
			var renderContext = requestContext.getRenderContext( "standard.tree" );

			
			// --- Define Scope Variables. ---------------------- //


			// I flag that data is being loaded.
			$scope.isLoading = true;

			// I hold the categories to render.
            $rootScope.leaves = [];

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
			$scope.$evalAsync(loadTreeData());

			Gumby.init();

		}
	);

 })( angular, AnnoTree );
