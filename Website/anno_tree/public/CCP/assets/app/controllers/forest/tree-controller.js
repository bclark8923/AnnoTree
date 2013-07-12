(function( ng, app ){

	"use strict";

	app.controller(
		"forest.TreeController",
		function( $scope, $cookies, $rootScope, $location, $timeout, $route, $routeParams,  requestContext, treeService, branchService, leafService, localStorageService, _ ) {


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
				$rootScope.leaves.push($scope.newLeafHolder);

               	/*if(leaves.length == 0) {
               		$scope.noLeaves	= "Click the cog in the top left to get your API key to tie into your mobile app!";
					$scope.noLeavesNL = "Or click \"New Leaf\" in the top right to add a leaf now.";
               	}*/
			}


			// I load the "remote" data from the server.
			function loadTreeData() {

				$scope.isLoading = true;

				var promise = treeService.getTree($routeParams.treeID);

				promise.then(
					function( response ) {

						$scope.isLoading = false;

				        $scope.treeInfo = response.data;
				        localStorageService.add('curTree', response.data);
						
						if(response.data.branches.length == 0) {
							$location.path("/forestFire");
						} else {
							loadLeaves( response.data.branches[0].leaves );

	 						$timeout(function() { window.Gumby.init(); $("#loadingScreen").hide();}, 0);	
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

				$rootScope.leaves.pop();
				$rootScope.leaves.push(newLeaf);
				$rootScope.leaves.push($scope.newLeafHolder);

				$("#newLeafClose").click();

				$scope.invalidAddLeaf = false;

				/*$route.reload();

				if(!$scope.$$phase) {
					$scope.$apply();
				}*/

			}

			$scope.openModifyTreeModal = function (tree) {
				$("#modifyTreeModal").addClass('active');
				$rootScope.modifyTree = tree;
				$rootScope.originalName = tree.name;
				$rootScope.originalDescription = tree.description;
			}

			$scope.cancelModifyTreeModal = function() {
				$rootScope.modifyTree.name = $rootScope.originalName;
				$rootScope.modifyTree.description = $rootScope.originalDescription;
				$scope.closeModifyTreeModal();	
			}

			$scope.closeModifyTreeModal = function () {
				$("#modifyTreeModal").removeClass('active');
				$("#invalidModifyTree").html('');
				$rootScope.modifyTree = null;
				$scope.invalidModifyTree = false; 
				$("#loadingScreen").hide();
			}
			
			$scope.modifyTreeFn = function() {

				var treeName = $rootScope.modifyTree.name;
				var treeDescription = $rootScope.modifyTree.description;
				var treeID = $rootScope.modifyTree.id;
				var formValid = $scope.modifyTreeForm.$valid;

				//validate form
				if(!formValid) {
					$scope.invalidModifyTree = true;
					if(!treeName) {
						$("#invalidModifyTree").html("Please fill out a tree name.");
					}
					else if(!treeDescription) {
						$("#invalidModifyTree").html("Please fill out a tree description.");
					} else {
						//shouldn't happen
						$("#invalidModifyTree").html("Please enter valid information.");
					}
				} else {
					var promise = treeService.updateTree(treeID, treeName, treeDescription);

					promise.then(
						function( response ) {
							$scope.isLoading = false;
							$scope.invalidModifyTree = false;
							$scope.closeModifyTreeModal();
						},
						function( response ) {
							$scope.invalidModifyTree = true;
							var errorData = "Our Create Tree Service is currently down, please try again later.";
							var errorNumber = parseInt(response.data.error);
							if(response.data.status == 406) {
								switch(errorNumber)
								{
									case 0:
										errorData = "Please fill out all of the fields";
										break;
									case 1:
										errorData = "The name needs at least one alphanumeric character";
										break;
									case 2:
										errorData = "The tree you attempted to modify to no longer exists.";
										break;
									case 3:
										errorData = "You do not have permission to modify this tree.";
										break;
									default:
										//go to Fail Page
										//$location.path("/forestFire");
								}
							} else if(response.data.status != 401 && errorNumber != 0) {
								//go to Fail Page
								$location.path("/forestFire");
							}
							$("#invalidModifyTree").html(errorData);

						}
					);
				}
			}

			$scope.deleteCallback = function() {
				$("#deleteCallbackModal").addClass('active');
			}

			$scope.deleteTree = function() {
				//return;
				var treeID = $rootScope.modifyTree.id;
				var promise = treeService.deleteTree(treeID);

				promise.then(
					function( response ) {

						$scope.isLoading = false;
						$location.path('/app');

					},
					function( response ) {
						var errorData = "Our Modify Leaf Service is currently down, please try again later.";
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
						$("#invalidModifyLeaf").html(errorData);

					}
				);
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
		        leafService.createAnnotation(leafID, fd, xhr);
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
					var promise = leafService.createLeaf(branchID, leafName, leafDescription);

					promise.then(
						function( response ) {

							$scope.isLoading = false;

							$scope.newLeafData = response.data;
							$scope.newLeafData.annotations = [];

							$scope.noLeaves = "";
							$scope.noLeavesNL = "";
							$("#noLeavesDiv").hide();
							$("#treeElementsDiv").show();

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

			$scope.addUser = function() {
				var promise = treeService.addUser($scope.treeInfo.id, $scope.addUserID);

				promise.then(
					function( response ) {

						//if existing, push
						$scope.treeInfo.users.push($scope.addedUser);

						//else alert user was invited

					},
					function( response ) {
						//alert('broked');
						//return;
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
						alert(errorData);

					}
				);
			}

			$scope.openModifyUsersModal = function () {
				var promise = treeService.getKnownPeople();
				promise.then(
					function( response ) {

						$("#modifyUsersModal").addClass('active');

						var users = [];
						var existingUsers = $scope.treeInfo.users;
						for(var i = 0; i < response.data.users.length; i++) {
							//if not already on tree
							var skip = false;
							for(var j = 0; j < existingUsers.length; j++) {
								if(existingUsers[j].email == response.data.users[i].email) {
									skip = true;
								}
							}
							if(skip){ continue; }
							users.push({user: response.data.users[i], label:response.data.users[i].first_name + ' ' + response.data.users[i].last_name + ' ' + response.data.users[i].email, value: response.data.users[i].email} );
						}
						$( "#userList" ).autocomplete({
					      minLength: 1,
					      source: users,
					      select: function( event, ui ) {
					        $( "#userList" ).val( ui.item.value );
					 		$scope.addedUser = ui.item.user;
					        return false;
					      }
					    })
					    .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
					      return $( "<li>" )
					        .append( "<a>" + item.label + "</a>" )
					        .appendTo( ul );
					    };

					},
					function( response ) {
						alert('Our add users service is currently down. Please try again later.');
						return;
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
						alert(errorData);

					}
				);
				/*$rootScope.modifyTree = tree;
				$rootScope.originalName = tree.name;
				$rootScope.originalDescription = tree.description;*/
			}

			$scope.closeModifyUsersModal = function () {
				$("#modifyUsersModal").removeClass('active');
				/*$("#invalidModifyUser").html('');
				$rootScope.modifyTree = null;
				$scope.invalidModifyTree = false; 
				$("#loadingScreen").hide();*/
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
            $scope.noLeaves = "";
			$scope.noLeavesNL = "";
			$scope.newLeafHolder = { 
								id: "-1",
						   		name: "New Leaf",
							   	description: "Click here to add a new leaf to this tree.",
							   	logo: "img/tree01.png"
							};

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
