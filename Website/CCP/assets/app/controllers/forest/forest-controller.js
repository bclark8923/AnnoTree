(function( ng, app ){

    "use strict";

    app.controller(
        "forest.ForestController",
        function( $scope, $cookies, $rootScope, $location, $timeout, $route, requestContext, forestService, treeService, branchService, _ ) {
 

            // --- Define Controller Methods. ------------------- //


            // I apply the remote data to the local view model.
            function loadTrees( forests ) {

                for(var i = 0; i < forests.length; i++) {
                    forests[i].trees.push($scope.newTreeHolder);
                }

                $rootScope.forests = forests;
            }


            // I load the "remote" data from the server.
            function loadForestData() {

                $scope.isLoading = true;

                var promise = forestService.getForests();

                promise.then(
                    function( response ) {
                        if(response.status == 204) {
                            $scope.noForests = "Looks like you don't have a forest yet."
                            $scope.noForestsNL = "Click \"New Forest\" in the top right to get started!";
                        } else {

                            loadTrees( response.data.forests );

                        }
                        
                        $scope.isLoading = false;
                        
                        $timeout(function() { window.Gumby.init(); $("#loadingScreen").hide(); }, 0);

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
                        } else if(response.data.status != 401 && errorNumber != 0)  {
                            //go to Fail Page
                            $location.path("/forestFire");
                        }
                    }
                );

            }


            // --- Define Scope Methods. ------------------------ //

            function addTree(newTree) {

                for(var i = 0; i < $rootScope.forests.length; i++) { 
                    if($rootScope.forests[i].id == newTree.forest_id) {
                        $rootScope.forests[i].trees.pop();
                        $rootScope.forests[i].trees.push(newTree);
                        $rootScope.forests[i].trees.push($scope.newTreeHolder);
                        break;
                    }
                }

                $scope.closeNewTreeModal();

            }

            $scope.openNewTreeModal = function (forest) {
                $("#newTreeModal").addClass('active');
                $rootScope.curForestAdd = forest.id;
            }

            $scope.closeNewTreeModal = function () {
                $("#newTreeModal").removeClass('active');
                $("#invalidAddTree").html('');
                $("#treeName").val('');
                $("#treeDescription").val('');
                $scope.invalidAddTree = false; 
                $rootScope.curForestAdd = -1;
                $("#loadingScreen").hide();
            }

            $scope.newTree = function() {

                var treeName = $scope.treeName;
                var treeDescription = $scope.treeDescription;
                var formValid = $scope.createTreeForm.$valid;
                var forestID = $rootScope.curForestAdd;
                if(forestID == -1) {
                    formValid = false;
                }

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
                    var promise = treeService.createTree(forestID, treeName, treeDescription);

                    promise.then(
                        function( response ) {
                    
                            var branchName = "Loose Leaves";
                            var branchDescription = "A collection of loose leaves sent to this tree.";
                            var promise = branchService.createBranch(response.data.id, branchName, branchDescription);
                            $scope.newTreeData = response.data;

                            promise.then(
                                function(response) {
                                    //worked

                                    $scope.isLoading = false;
                                    $scope.invalidAddTree = false;

                                    addTree( $scope.newTreeData );
                                },
                                function(response) {
                                    //delete tree
                                    $scope.invalidAddTree = true;
                                    var errorData = "Our Create Branch Service is currently down, please try again later.";
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
                                                errorData = "The tree you attempted to add to no longer exists.";
                                                break;
                                            case 4:
                                                errorData = "Please enter a valid branch name.";
                                                break;
                                            default:
                                                //go to Fail Page
                                                //$location.path("/forestFire");
                                        }
                                        alert(errorData);
                                    } else if(response.data.status != 401 && errorNumber != 0) {
                                        //go to Fail Page
                                        $location.path("/forestFire");
                                    }
                                    $("#invalidAddTree").html(errorData);
                                    
                                    //if this breaks at all we have a problem on our end
                                    //$location.path("/forestFire");
                                    //alert(errorData);

                                }
                            );
                
                            $timeout(function() { Gumby.initialize('switches') }, 0);

                        },
                        function( response ) {
                            $scope.invalidAddTree = true;
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
                                        //$location.path("/forestFire");
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
                            } else if(response.data.status != 401 && errorNumber != 0) {
                                //go to Fail Page
                                $location.path("/forestFire");
                            }
                            $("#invalidAddTree").html(errorData);

                        }
                    );
                }
            }


            $scope.openModifyForestModal = function (forest) {
                $("#modifyForestModal").addClass('active');
                $rootScope.modifyForest = forest;
                $rootScope.originalName = forest.name;
            }

            $scope.cancelModifyForestModal = function () {
                $rootScope.modifyForest.name = $rootScope.originalName;
                $scope.closeModifyForestModal();
            }

            $scope.closeModifyForestModal = function () {
                $("#modifyForestModal").removeClass('active');
                $("#invalidModifyForest").html('');
                $rootScope.modifyForest = null;
                $scope.invalidModifyForest = false; 
                $("#loadingScreen").hide();
            }

            $scope.modifyForestFn = function() {
                var forestID = $rootScope.modifyForest.id;
                var forestName = $rootScope.modifyForest.name;
                var forestDescription = "NULL";
                var formValid = $scope.modifyForestForm.$valid;

                //validate form
                if(!formValid) {
                    $scope.invalidModifyForest = true;
                    if(!forestName) {
                        $("#invalidModifyForest").html("Please fill out a forest name.");
                    }
                    else if(!forestDescription) {
                        $("#invalidModifyForest").html("Please fill out a forest description.");
                    } else {
                        //shouldn't happen
                        $("#invalidModifyForest").html("Please enter valid information.");
                    }
                } else {
                    var promise = forestService.updateForest(forestID, forestName, forestDescription);

                    promise.then(
                        function( response ) {

                            $scope.isLoading = false;
                            $scope.invalidModifyForest = false;
                            $scope.closeModifyForestModal();
                            
                        },
                        function( response ) {
                            $scope.invalidModifyForest = true;
                            var errorData = "Our Modify Forest Service is currently down, please try again later.";
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
                                        //$location.path("/forestFire");    
                                }
                            } else if(response.data.status != 401 && errorNumber != 0) {
                                //go to Fail Page
                                $location.path("/forestFire");
                            }
                            $("#invalidModifyForest").html(errorData);

                        }
                    );
                }
            }

            $scope.deleteForestCallback = function() {
                $("#deleteCallbackModal").addClass('active');
            }

            $scope.deleteForest = function() {
                var forestID = $rootScope.modifyForest.id;
                var promise = forestService.deleteForest(forestID);

                promise.then(
                    function( response ) {

                        $scope.isLoading = false;

                        for(var i = 0; i < $rootScope.forests.length; i++) { 
                            if($rootScope.forests[i].id == $rootScope.modifyForest.id) {
                                $rootScope.forests.splice(i,1);
                                break;
                            }
                        }
                        $scope.closeModifyForestModal();
                        $("#deleteCallbackModal").removeClass('active');

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

            $scope.openNewForestModal = function () {
                $("#newForestModal").addClass('active');
            }

            $scope.closeNewForestModal = function () {
                $("#newForestModal").removeClass('active');
                $("#invalidAddForest").html('');
                $("#forestName").val('');
                $scope.invalidAddForest = false; 
                $("#loadingScreen").hide();
            }

            function addForest(newForest) {

                newForest.trees = [];
                newForest.trees.push($scope.newTreeHolder);
                $rootScope.forests.push(newForest);
                $scope.closeNewForestModal();

            }

            $scope.newForest = function() {
                var forestName = $scope.forestName;
                var forestDescription = "NULL";
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
                            $scope.invalidAddForest = false;
                            $scope.noForests = "";
                            $("#noForestsDiv").hide();

                            addForest( response.data );
                            //$scope.forests[0].name = "fuck";
                            $timeout(function() { Gumby.initialize('switches') }, 0);

                        },
                        function( response ) {
                            $scope.invalidAddForest = true;
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
                                        //$location.path("/forestFire");    
                                }
                            } else if(response.data.status != 401 && errorNumber != 0) {
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
            $rootScope.forests = [];
            $scope.branchID = -1;
            $scope.curForestAdd = -1;
            $scope.noForests = "";

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