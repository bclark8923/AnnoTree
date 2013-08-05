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
                        leaves[i].annotation = leaves[i].annotations[leaves[i].annotations.length - 1].path;
                    } else {
                        leaves[i].annotation = "img/noImageBG.png";
                    }
                }
                $rootScope.leaves = leaves;
                $rootScope.leaves.push($scope.newLeafHolder);
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

                            $timeout(function() {$("#loadingScreen").hide();}, 0);    
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
                if (newLeaf.annotations.length == 0) {
                    newLeaf.annotation = "img/noImageBG.png";
                }
                $rootScope.leaves.push(newLeaf);
                $rootScope.leaves.push($scope.newLeafHolder);

                $("#newLeafClose").click();

                $scope.invalidAddLeaf = false;
                
                if(!$scope.$$phase) {
                    $scope.$apply();
                }
                //$scope.$apply();
                $scope.closeNewLeafModal();

                /*$route.reload();

                if(!$scope.$$phase) {
                    $scope.$apply();
                }*/

            }

            $scope.openModifyTreeModal = function (tree) {
                $("#modifyTreeModal").modal('show');
                if (settingsPane.isOpen) {
                    settingsPane.closeFast();
                }
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
                $("#modifyTreeModal").modal('hide');
                $("#invalidModifyTree").html('');
                $rootScope.modifyTree = null;
                $scope.invalidModifyTree = false; 
                $("#loadingScreen").hide();
            }
            
            $scope.modifyTreeFn = function() {

                var treeName = $rootScope.modifyTree.name;
                var treeDescription = "NULL";
                var treeID = $rootScope.modifyTree.id;
                var formValid = $scope.modifyTreeForm.$valid;

                //validate form
                if(!formValid) {
                    $scope.invalidModifyTree = true;
                    if(!treeName) {
                        $("#invalidModifyTree").html("Please fill out a tree name.");
                    } else {
                        //shouldn't happen
                        $("#invalidModifyTree").html("Please enter valid information.");
                    }
                } else {
                    $('#modifyTreeModalWorking').addClass('active');
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
                    $('#modifyTreeModalWorking').removeClass('active');
                }
            }

            $scope.deleteCallback = function() {
                $("#deleteCallbackModal").modal('show');
            }

            $scope.deleteTree = function() {
                //return;
                var treeID = $rootScope.modifyTree.id;
                var promise = treeService.deleteTree(treeID);

                promise.then(
                    function( response ) {
                        $('#deleteCallbackModal').modal('hide');
                        $('#modifyTreeModal').modal('hide');
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
                $("#newLeafModal").modal('show');
            }

            $scope.closeNewLeafModal = function () {
                $("#newLeafModal").modal('hide');
                $("#invalidAddLeaf").html('');
                $("#leafName").val('');
                $("#annotationImage").val('');
                $('#annotationImage').replaceWith($('#annotationImage').clone());
                $scope.invalidAddLeaf = false;
                $scope.filesListing = [];
                $("#newLeafModalWorking").removeClass('active');
                $('#filesName').html('No files selected (optional)');
            }

            function newAnnotation(leafID) {
                $scope.files = [];
                var annotationImageElement = document.getElementById('annotationImage');
                var files = annotationImageElement.files;
                //console.log('files:', files)
                for (var i = 0; i < files.length; i++) {
                    $scope.files.push(files[i]);
                }

                var fd = new FormData();
                for (var i in $scope.files) {
                    fd.append("uploadedFile", $scope.files[i]);
                }
                var xhr = new XMLHttpRequest();

                //xhr.upload.addEventListener("progress", uploadProgress, false)
                xhr.addEventListener("load", uploadComplete, false);
                xhr.addEventListener("error", uploadFailed, false);
                xhr.addEventListener("abort", uploadCanceled, false);
                leafService.createAnnotation(leafID, fd, xhr);

                $scope.isLoading = false;
            }

            function uploadComplete(evt) {
                /* This event is raised when the server send back a response */
                //alert(evt.target.responseText); 
                if (this.status == 415 || this.status == 406) {
                    var jsonResp = JSON.parse(this.response);
                    leafService.deleteLeaf($scope.newLeafData.id);
                    $("#invalidAddLeaf").html("Only images can be uploaded at this time");
                    $scope.invalidAddLeaf = true;
                    $("#newLeafModalWorking").removeClass('active');
                } else if (this.status == 413) {
                   leafService.deleteLeaf($scope.newLeafData.id);
                   $("#invalidAddLeaf").html("Image is too large. Only images less then 10MB may be uploaded at this time.");
                    $scope.invalidAddLeaf = true;
                    $("#newLeafModalWorking").removeClass('active');
                } else {
                    var annotationObject = jQuery.parseJSON( evt.target.responseText );
                    $scope.newLeafData.annotations.push(annotationObject);
                    $scope.newLeafData.annotation = annotationObject.path;
                    addLeaf( $scope.newLeafData );
                }
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
                if(!formValid) {
                    $scope.invalidAddLeaf = true;
                    if (!leafName) {
                        $("#invalidAddLeaf").html("Please fill out a leaf name.");
                    } else {
                        //shouldn't happen
                        $("#invalidAddLeaf").html("Please enter valid information.");
                    }
                } else {
                    if (annotationImageElement.files.length > 0 && annotationImageElement.files[0].size > 10485760) {
                       $("#invalidAddLeaf").html("Image is too large. Only images less then 10MB may be uploaded at this time.");
                        $scope.invalidAddLeaf = true; 
                        $('#annotationImage').replaceWith($('#annotationImage').clone());
                        $('#filesName').html('No files selected (optional)');
                    } else {
                        $('#newLeafModalWorking').addClass('active');
                        var promise = leafService.createLeaf(branchID, leafName, leafDescription);

                        promise.then(
                            function( response ) {
                                $scope.invalidAddLeaf = false;

                                $scope.newLeafData = response.data;
                                $scope.newLeafData.annotations = [];

                                $scope.noLeaves = "";
                                $scope.noLeavesNL = "";
                                $("#noLeavesDiv").hide();
                                $("#treeElementsDiv").show();
                                $("#createAnnotation").attr('action', '/services/' + response.data.id + '/annotation');
                                //addAnnotation(response.data.id);
                                if (annotationImageElement.files.length > 0) {
                                    newAnnotation(response.data.id);
                                } else {
                                    addLeaf( $scope.newLeafData);
                                }
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
            }

            $scope.removeFromTree = function(user) {
                var promise = treeService.removeUser($scope.treeInfo.id, user.id);
                $scope.removeUser = user;

                promise.then(
                    function( response ) {

                        //if existing, push
                        var index = $scope.treeInfo.users.indexOf($scope.removeUser);
                        $scope.treeInfo.users.splice(index, 1);
                        //else alert user was invited

                    },
                    function( response ) {
                        //alert('broked');
                        //return;
                        var errorData = "Our Remove User From Tree Service is currently down, please try again later.";
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
                            alert(errorData);
                        } else if(response.data.status != 401 && errorNumber != 0) {
                            //go to Fail Page
                            //$location.path("/forestFire");
                            alert(errorData);
                        }

                    }
                );
            }

            $scope.addUser = function() {
                $scope.addedUser.email = $scope.addUserID;
                var email = $('#userList').val();
                $('#modifyUsersModalWorking').addClass('active');
                var promise = treeService.addUser($scope.treeInfo.id, email);

                promise.then(
                    function( response ) {

                        //if existing, push
                        $scope.addedUser.first_name = response.data.firstName;
                        $scope.addedUser.last_name = response.data.lastName;
                        $scope.addedUser.id = response.data.id;
                        var user = {};
                        user.first_name = response.data.firstName;
                        user.last_name = response.data.lastName;
                        user.id = response.data.id;
                        user.email = email;
                        $scope.treeInfo.users.push(user);
                        $scope.addUserID = "";
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
                            alert(errorData);
                        } else if(response.data.status != 401 && errorNumber != 0) {
                            //go to Fail Page
                            //$location.path("/forestFire");
                            alert(errorData);
                        }

                    }
                );
                $('#modifyUsersModalWorking').removeClass('active');
            }
            
            $scope.mobileGoToHome = function() {
                if (settingsPane.isOpen) {
                    settingsPane.closeFast();
                } 
                $location.path("/app");
            }
            
            $scope.mobileGoToDocs = function(treeID) {
                if (settingsPane.isOpen) {
                    settingsPane.closeFast();
                } 
                $location.path("/app/" + treeID + "/docs");
            }
            
            $scope.openModifyUsersModal = function () {
                if (settingsPane.isOpen) {
                    settingsPane.closeFast();
                } 
                
                var promise = treeService.getKnownPeople();
                promise.then(
                    function( response ) {
                        $("#modifyUsersModal").modal('show');

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
                                $scope.addUserID = ui.item.user.email;
                                return false;
                            }
                        });
                    },
                    function( response ) {
                        alert('Our add and remove users service is currently down. Please try again later.');
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
                            alert(errorData);
                        } else if(response.data.status != 401 && errorNumber != 0) {
                            //go to Fail Page
                            //$location.path("/forestFire");
                            alert(errorData);
                        }
                    }
                );
                /*$rootScope.modifyTree = tree;
                $rootScope.originalName = tree.name;
                $rootScope.originalDescription = tree.description;*/
            }

            $scope.closeModifyUsersModal = function () {
                $("#modifyUsersModal").modal('hide');
                /*$("#invalidModifyUser").html('');
                $rootScope.modifyTree = null;
                $scope.invalidModifyTree = false; 
                $("#loadingScreen").hide();*/
            }

            // --- Define Controller Variables. ----------------- //

            // Get the render context local to this controller (and relevant params).
            var renderContext = requestContext.getRenderContext( "standard.tree" );
            
            // --- Define Scope Variables. ---------------------- //

            // I flag that data is being loaded.
            $scope.isLoading = true;
            $scope.leafCreate = true;
            $scope.annoCreate = true;

            // I hold the categories to render.
            $rootScope.leaves = [];
            $scope.addedUser = {};
            $scope.noLeaves = "";
            $scope.noLeavesNL = "";
            $scope.newLeafHolder = { 
                id: "-1",
                name: "New Leaf",
                description: "Click here to add a new leaf to this tree.",
                logo: "img/logo.png"
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
            $scope.filesListing = [];
            $("#annotationImage").change(function() {
                var file = $('#annotationImage').val().replace(/C:\\fakepath\\/i, '');
                if (file == '') {
                    file = 'No file selected (optional)';
                }
                $('#filesName').html(file);
            });

            // Load the "remote" data.
            $scope.$evalAsync(loadTreeData());
        }
    );
})( angular, AnnoTree );
