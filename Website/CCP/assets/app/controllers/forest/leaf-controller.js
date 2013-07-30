(function( ng, app ){
    "use strict";

    app.controller(
        "forest.LeafController",
        function( $scope, $cookies, $rootScope, $location, $timeout, $route, $routeParams,  requestContext, leafService, localStorageService, _ ) {


            // --- Define Controller Methods. ------------------- //

            $scope.openViewLeafModal = function (tree) {
                $("#viewLeafModal").addClass('active');
                $rootScope.modifyTree = tree;
            }

            $scope.closeViewLeafModal = function () {
                $("#viewLeafModal").removeClass('active');
            }


            // I apply the remote data to the local view model.
            function loadLeaf( leaf ) {
                var leafImage = "img/leaf01.png";
                if(leaf.annotations.length > 0) {
                    leafImage = leaf.annotations[0].path
                }
                leaf.image = leafImage;
                $scope.leaf = leaf;
                localStorageService.add('activeLeaf', leaf.name);
            }

            // I load the "remote" data from the server.
            function loadLeafData() {

                $scope.isLoading = true;

                var promise = leafService.getLeaf($routeParams.leafID);

                promise.then(
                    function( response ) {
                        $scope.isLoading = false;
                        loadLeaf( response.data );
                        $timeout(function() {$("#loadingScreen").hide(); }, 0);
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
            
            // --- Define Scope Methods. ------------------------ //
            $scope.addLeafComment = function() {
                var formValid = $scope.leafCommentForm.$valid;
                var comment = $scope.leafComment.comment;
                if (!formValid) {
                    if (!comment) {
                        $('#leafCommentError').html("You didn't write a comment!");
                        $scope.leafCommentError = true;
                    }
                } else {
                    var leafID = $scope.leaf.id;
                    var promise = leafService.addLeafComment(leafID, comment);

                    promise.then(
                        function( response ) {
                            $scope.isLoading = false;
                            $scope.leaf.comments = (response.data.comments);
                            $('#newComment').val('');
                        },
                        function( response ) {
                            var errorData;
                            var errorNumber = parseInt(response.data.error);
                            if(response.data.status == 406) {
                                errorData = response.data;
                            } else if(response.data.status != 401 && errorNumber != 0) {
                                errorData = "Our service are experiencing issues currently. Please try again in a few minutes.";
                            }
                            $("#leafCommentError").html(errorData);
                        }
                    );
                    $("#loadingScreen").hide();
                }
            }

            $scope.openModifyLeafModal = function () {
                $("#modifyLeafModal").addClass('active');
                $rootScope.modifyLeaf = $scope.leaf;
                $rootScope.originalName = $scope.leaf.name;
            }

            $scope.cancelModifyLeafModal = function() {
                $rootScope.modifyLeaf.name = $rootScope.originalName;
                $scope.closeModifyLeafModal();  
            }

            $scope.closeModifyLeafModal = function () {
                $("#modifyLeafModal").removeClass('active');
                $("#invalidModifyLeaf").html('');
                $rootScope.modifyLeaf = null;
                $scope.invalidModifyLeaf = false; 
                $("#loadingScreen").hide();
            }

            $scope.modifyLeafFn = function() {

                var leafName = $rootScope.modifyLeaf.name;
                var leafDescription = "NULL";
                var formValid = $scope.modifyLeafForm.$valid;
                var branchID = $rootScope.modifyLeaf.branch_id;
                var leafID = $rootScope.modifyLeaf.id;

                //validate form
                if(!formValid) {
                    $scope.invalidModifyLeaf = true;
                    if(!leafName) {
                        $("#invalidModifyLeaf").html("Please fill out a leaf name.");
                    } else {
                        //shouldn't happen
                        $("#invalidModifyLeaf").html("Please enter valid information.");
                    }
                } else {
                    //return;
                    var promise = leafService.updateLeaf(leafID, branchID, leafName, leafDescription);

                    promise.then(
                        function( response ) {

                            $scope.isLoading = false;
                            $scope.closeModifyLeafModal();

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
            }

            $scope.deleteCallback = function() {
                $("#deleteCallbackModal").addClass('active');
            }

            $scope.deleteLeaf = function() {
                //return;
                var leafID = $rootScope.modifyLeaf.id;
                var promise = leafService.deleteLeaf(leafID);

                promise.then(
                    function( response ) {

                        $scope.isLoading = false;
                        $scope.closeModifyLeafModal();
                        $location.path('/app/'+$routeParams.treeID);

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




            

            // ...


            // --- Define Controller Variables. ----------------- //


            // Get the render context local to this controller (and relevant params).
            var renderContext = requestContext.getRenderContext( "standard.tree.leaf" );

            
            // --- Define Scope Variables. ---------------------- //


            // I flag that data is being loaded.
            $scope.isLoading = true;

            // I hold the categories to render.
            $scope.leafImage = "";
            $scope.leafName = "";
            $scope.leafCommentError = false;

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

        }
    );
})( angular, AnnoTree );
