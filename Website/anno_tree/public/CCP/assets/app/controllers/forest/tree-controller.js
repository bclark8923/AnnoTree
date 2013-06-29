(function( ng, app ){

	"use strict";

	app.controller(
		"forest.TreeController",
		function( $scope, $cookies, $rootScope, $location, $timeout, $route, requestContext, forestService, _ ) {


			// --- Define Controller Methods. ------------------- //


			// I apply the remote data to the local view model.
			function loadLeafs( leaves ) {

               	$scope.leaves = leaves;
			}


			// I load the "remote" data from the server.
			function loadRemoteData() {

				$scope.isLoading = true;

				var promise = forestService.getTree(500,500);

				promise.then(
					function( response ) {

						$scope.isLoading = false;

						loadTrees( response.data.branches[0].leaves );

 						$timeout(function() { window.Gumby.init() }, 0);

					},
					function( response ) {

						var fakeStuff = {
				          logo: 'img/logo.png',
				          id: '2',
				          branches: [
				                        {
				                          id: '2',
				                          description: 'This is a branch created by the automated Mojolicious test suite',
				                          name: 'Test Suite Branch',
				                          tree_id: '2',
				                          created_at: '2013-06-28 20:55:58',
				                          leaves: [
				                                      {
				                                      	id: '1',
				                                        owner: '3',
				                                        created_at: '2013-06-28 20:55:58',
				                                        description: 'This is a leaf created by the automated Mojolicious test suite',
				                                        name: 'Test Suite Leaf',
				                                        annotation: 'img/leaf01small.png'
				                                      },
				                                      {
				                                      	id: '2',
				                                        owner: '3',
				                                        created_at: '2013-06-28 20:55:58',
				                                        description: 'This is a leaf created by the automated Mojolicious test suite',
				                                        name: 'Test Suite Leaf 2',
				                                        annotation: 'img/leaf02small.png'
				                                      }
				                                    ]
				                        }
				                      ],
				          name: 'Test Suite Tree',
				          description: 'This is a tree created by the automated Mojolicious test suite',
				          forest_id: '6',
				          created_at: '2013-06-28 20:55:58'
				        };

				        $scope.treeInfo = fakeStuff;

				        loadLeafs(fakeStuff.branches[0].leaves);

				        return;

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

			function addLeaf(newLeaf) {

				$scope.leaves.push(newLeaf);

				$("#newTreeClose").click();

				$scope.invalidAddTree = false;

				$location.path("/app");

				$route.reload();

			}

			$scope.annotationImage = {};
			$scope.$watch('annotationImage', function(){
			    //this seems to be a fake array, because for (i in files) will traverse on the "length" attribute as well,
			    //and it doesn't have a forEach method
			    // scope.files = document.getElementById('fileToUpload').files
			    //...so we need to copy the files to a new array
			    $scope.files = []
			    var annotim = document.getElementById('annotationImage');
			    var files = annotim.files
			    console.log('files:', files)
			    for (var i = 0; i < files.length; i++) {
			        $scope.files.push(files[i])
			    }
			    //$scope.progressVisible = false
			})

			$scope.newLeafTest = function() {
			    $scope.files = []
			    var annotim = document.getElementById('annotationImage');
			    var files = annotim.files
			    console.log('files:', files)
			    for (var i = 0; i < files.length; i++) {
			        $scope.files.push(files[i])
			    }
				var fd = new FormData()
		        for (var i in $scope.files) {
		            fd.append("uploadedFile", $scope.files[i]);
		        }
		        var xhr = new XMLHttpRequest();
		        //xhr.upload.addEventListener("progress", uploadProgress, false)
		        //xhr.addEventListener("load", uploadComplete, false)
		        //xhr.addEventListener("error", uploadFailed, false)
		        //xhr.addEventListener("abort", uploadCanceled, false)
		        //return;
		        xhr.open("POST", "http://23.21.235.254:3000/3/annotation");
		        //$scope.progressVisible = true
		        xhr.send(fd);

				//alert($scope.annotationImage);
			}

			$scope.newLeaf = function() {

				var leafName = $scope.leafName;
				var leafAnnotation = $scope.leafAnnotation;
				var formValid = $scope.createTreeForm.$valid;
				var branchID = $scope.leaves[0].branch_id;

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
								}
							} else {
								//go to Fail Page
							}
							$("#invalidAddTree").html(errorData);

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
			$scope.$evalAsync(loadRemoteData());

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