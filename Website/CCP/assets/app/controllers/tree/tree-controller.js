(function( ng, app ) {
    "use strict";

    app.controller("tree.TreeController", function( 
        $scope, $location, $timeout, $route, $routeParams, $http, apiRoot, requestContext, dataService, constants
    ) {
        $scope.droppedLeaf = [];
        $scope.leafDrop = function(evt, ui) {
            var leafID = $scope.droppedLeaf[0].id;
            $scope.droppedLeaf = [];
            var branchID = this.branch.id;
            
            var promise = $http.put(apiRoot.getRoot() + '/services/' + $scope.tree.id + '/' + branchID + '/leaf/' + leafID);
            
            //TODO: figure out what to do on success/failure
            promise.then(
                function(response) {},
                function(response) {}
            );
        }

        function annotationNameChange() {
           $("#annotationImage").change(function() {
                var file = $('#annotationImage').val().replace(/C:\\fakepath\\/i, '');
                if (file == '') {
                    file = 'No file selected (optional)';
                }
                $('#filesName').html(file);
            }); 
        }

        function setActiveBranch(branch) {
            $scope.activeBranch = branch;
            if ($scope.activeBranch.sub_branches.length > 0) {
                $scope.subview = 'subBranches';
            } else {
                $scope.subview = 'looseLeaves';
            }
            if (!$routeParams.leafID) {
                $location.path("app/" + $scope.tree.forest_id + "/" + $scope.tree.id + "/" + $scope.activeBranch.id);
            }
        }
               
        $scope.$on('hideLeaf', function(evt) {
            $timeout(function() {
                $location.path("app/" + $scope.tree.forest_id + "/" + $scope.tree.id + "/" + $scope.activeBranch.id);
            }, 0);
        });

        $scope.changeBranch = function(branchID) {
            for (var i = 0; i < $scope.tree.branches.length; i++) {
                if ($scope.tree.branches[i].id == branchID) {
                    setActiveBranch($scope.tree.branches[i]);
                    break;
                }
            } 
        }

        function loadTreeData(treeID) {
            var promise = $http.get(apiRoot.getRoot() + '/services/tree/' + treeID);
            
            promise.then(
                function(response) {
                    $scope.tree = response.data;
                    for (var i = 0; i < $scope.tree.branches.length; i++) {
                        if ($routeParams.branchID) {
                            if ($scope.tree.branches[i].id == $routeParams.branchID) {
                                setActiveBranch($scope.tree.branches[i]);
                            } 
                        } else {
                            if ($scope.tree.branches[i].name == 'User Feedback') {
                                setActiveBranch($scope.tree.branches[i]);
                            }
                        }
                        if ($scope.tree.branches[i].name == 'User Feedback') {
                            $scope.tree.branches[i].icon = "icon-comments-alt";
                        } else if ($scope.tree.branches[i].name == 'Product Backlog') {
                            $scope.tree.branches[i].icon = "icon-folder-close-alt";
                        } else if ($scope.tree.branches[i].name == 'Bugs') {
                            $scope.tree.branches[i].icon = "icon-bug";
                        } else if ($scope.tree.branches[i].name == 'Archive') {
                            $scope.tree.branches[i].icon = "icon-archive";
                        } else {
                            $scope.tree.branches[i].icon = "";
                        }
                    }
                    $timeout(function() {
                        $("#loadingScreen").hide();
                    /*
                        $('.branch').droppable({
                            hoverClass: 'branchHover',
                            over: function(evt, ui) {
                                $('.card-col-placeholder').css('display', 'none');
                            },
                            out: function(evt, ui) {
                            }
                        });
                    */
                    }, 0);
                },
                function( response ) {
                    $location.path("/forestFire"); //TODO: should redirect to app page and tell them why
                }
            );
        }

        $scope.openNewLeafModal = function() {
            resetNewLeafUpload();
            $scope.newLeafWorking = false;
            $scope.newLeafName = '';
            $("#newLeafModal").appendTo('body').modal('show');
        }
        
        function addLeaf(newLeaf) {
            if (newLeaf.annotation == null) {
                newLeaf.annotation = "img/noImageBG.png";
            }
            newLeaf.assigned = [];
            $scope.$broadcast('newLeafCreated', newLeaf);

            $('#newLeafModal').modal('hide');
            //TODO: open new leaf's modal
        }

        //TODO:angular way or using jquery file upload
        function resetNewLeafUpload() {
            $('#newLeafAnnotation').html('No file selected (optional)');
            $('#annotationImage').replaceWith($('#annotationImage').clone());
            $('#annotationImage').change(function() {
                var file = $('#annotationImage').val().replace(/C:\\fakepath\\/i, '');
                if (file == '') {
                    file = 'No file selected (optional)';
                }
                $('#newLeafAnnotation').html(file);
            });
        }

        function setNewLeafError(msg) {
            $scope.newLeafErrorText = msg;
            $scope.newLeafErrorMessage = true;
            $scope.newLeafWorking = false;
        }

        $scope.newLeaf = function() {
            var leafName = $scope.newLeafName;
            var annotationImageElement = document.getElementById('annotationImage');
            var branchID = $scope.activeBranch.id;
            if ($scope.activeBranch.sub_branches !== undefined) {
                for (var i = 0; i < $scope.activeBranch.sub_branches.length; i++) {
                    if ($scope.activeBranch.sub_branches[i].priority == 1) {
                        branchID = $scope.activeBranch.sub_branches[i].id;
                        break;
                    }
                }
            }

            if (!leafName) {
                setNewLeafError("Please enter a leaf name");
            } else if (annotationImageElement.files.length > 0 && annotationImageElement.files[0].size > 10485760) {
                setNewLeafError("Image is too large. Only images less then 10MB may be uploaded at this time.");
                resetNewLeafUpload();
            } else {
                $scope.newLeafWorking = true;
                var promise = $http.post(apiRoot.getRoot() + '/services/' + branchID + '/leaf', {
                    name: leafName
                });
                
                promise.then(
                    function(response) {
                        $scope.newLeafData = response.data;
                        $scope.newLeafData.annotation = null;

                        if (annotationImageElement.files.length > 0) {
                            newAnnotation(response.data.id);
                            $scope.delLeaf = response.data.id;
                        } else {
                            addLeaf($scope.newLeafData);
                        }
                    },
                    function(response) {
                        if (response.status != 500 && response.status != 502) {
                            setNewLeafError(response.data.txt);
                        } else {
                            setNewLeafError(constants.servicesDown());
                        }
                    }
                );
            }
        }

        function newAnnotation(leafID) {
            var annotationImageElement = document.getElementById('annotationImage');
            var files = annotationImageElement.files;
            var fd = new FormData();
            fd.append("uploadedFile", files[0]);
            
            var xhr = new XMLHttpRequest();

            xhr.addEventListener("load", uploadComplete, false);
            xhr.addEventListener("error", uploadFailed, false);
            xhr.addEventListener("abort", uploadCanceled, false);
            xhr.open("POST", apiRoot.getRoot() + "/services/" + leafID + "/annotation");
            xhr.send(fd);
        }

        function uploadComplete(evt) {
            if (this.status == 415 || this.status == 406) {
                var jsonResp = JSON.parse(this.response);
                $http.delete(apiRoot.getRoot() + '/services/leaf/' + $scope.delLeaf);
                setNewLeafError("Only images can be uploaded at this time");
            } else if (this.status == 413) {
                $http.delete(apiRoot.getRoot() + '/services/leaf/' + $scope.delLeaf);
                setNewLeafError("Image is too large. Only images less then 10MB may be uploaded at this time.");
            } else {
                var annotationObject = jQuery.parseJSON(evt.target.responseText);
                $scope.newLeafData.annotation = annotationObject.path;
                addLeaf($scope.newLeafData);
            }
        }

        function uploadFailed(evt) {
            //TODO:add error message
            $location.path("/forestFire");
        }

        function uploadCanceled(evt) {
            $location.path("/forestFire");
        }

        $scope.openModifyTreeModal = function() {
            $scope.treeRenameShow = false;
            $scope.addUserErrorMessage = false;
            $scope.modifyTreeModalWorking = false;
            $scope.removeUserErrorMessage = false;
            $('#userList').val('');
            $("#modifyTreeModal").appendTo('body').modal('show');
            setUserAutocomplete();
        }

        function setUserAutocomplete() {
           var promise = $http.get(apiRoot.getRoot() + '/services/user/knownpeople');

            promise.then(
                function(response) {
                    var users = [];
                    var existingUsers = $scope.tree.users;
                    for (var i = 0; i < response.data.users.length; i++) {
                        //if not already on tree
                        var skip = false;
                        for(var j = 0; j < existingUsers.length; j++) {
                            if(existingUsers[j].email == response.data.users[i].email) {
                                skip = true;
                            }
                        }
                        if (skip){ continue; }
                        users.push({
                            user: response.data.users[i], 
                            label: response.data.users[i].first_name + ' ' + response.data.users[i].last_name + ' ' + response.data.users[i].email, 
                            value: response.data.users[i].email
                        });
                    }
                    $('#userList').attr('autocomplete','on');
                    $("#userList").autocomplete({
                        minLength: 0,
                        source: users,
                        appendTo: 'body',
                        select: function(event, ui) {
                            $("#userList").val(ui.item.value);
                            return false;
                        }
                    });
                },
                function(response) {} //TODO: handle failure
            );
        }

        $scope.showRenameTree = function() {
            $scope.treeRenameText = $scope.tree.name;
            $scope.treeRenameErrorMessage = false;
            $scope.treeRenameShow = true;
        }

        function setTreeRenameError(msg) {
            $scope.treeRenameErrorText = msg;
            $scope.treeRenameErrorMessage = true;
        }

        $scope.renameTree = function() {
            var treeName = $scope.treeRenameText;
            var treeID = $scope.tree.id;

            if (!treeName) {
                setTreeRenameError("Please enter a tree name");
            } else if (!nameTest.test(treeName)) {
                setTreeRenameError("A tree name must include at least one alphanumeric character");
            } else {
                var promise = $http.put(apiRoot.getRoot() + '/services/tree/' + treeID, {
                    name: treeName
                });

                $scope.tree.name = treeName;
                $scope.treeRenameShow = false;

                promise.then(
                    function(response) {}, //TODO: handle success and failure
                    function(response) {}
                );
            }
        }

        $scope.openDeleteTree = function() {
            $scope.deleteTreeModalWorking = false;
            $scope.deleteTreeErrorMessage = false;
            $("#deleteTreeModal").appendTo('body').modal('show');
        }

        function setDeleteTreeError(msg) {
            $scope.deleteTreeErrorText = msg;
            $scope.deleteTreeErrorMessage = true;
        }

        $scope.deleteTree = function() {
            var promise = $http.delete(apiRoot.getRoot() + '/services/tree/' + $scope.tree.id);
            $scope.deleteTreeModalWorking = true;
            promise.then(
                function(response) {
                    $('#deleteTreeModal').modal('hide');
                    $('#modifyTreeModal').modal('hide');
                    $location.path('/app');
                },
                function(response) {
                    if (response.status != 500 && response.status != 502) {
                        setDeleteTreeError(response.data.txt);
                    } else {
                        setDeleteTreeError(constants.servicesDown());
                    }
                }
            );
        }
        
        function setRemoveUserError(msg) {
            $scope.removeUserErrorText = msg;
            $scope.removeUserErrorMessage = true;
            $scope.modifyTreeModalWorking = false;
        }

        $scope.removeFromTree = function(user) {
            var promise = $http.delete(apiRoot.getRoot() + '/services/tree/' + $scope.tree.id + "/user/" + user.id);
            $scope.modifyTreeModalWorking = true;
            $scope.removeUser = user;

            promise.then(
                function(response) {
                    var index = $scope.tree.users.indexOf($scope.removeUser);
                    $scope.tree.users.splice(index, 1);
                    $scope.removeUserErrorMessage = false;
                    $scope.modifyTreeModalWorking = false;
                    
                    var curUser = dataService.getUser();
                    if (curUser.id == $scope.removeUser.id) {
                        $('#modifyTreeModal').modal('hide');
                        $location.path("/app");
                    }
                },
                function(response) {
                    if (response.status != 500 && response.status != 502) {
                        setRemoveUserError(response.data.txt);
                    } else {
                        setRemoveUserError(constants.servicesDown());
                    }
                }
            );
        }
        
        function validateEmail(email) { 
            var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            return re.test(email);
        }

        function setAddUserError(msg) {
            $scope.addUserErrorText = msg;
            $scope.addUserErrorMessage = true;
            $scope.modifyTreeModalWorking = false;
        }

        $scope.addUser = function() {
            $scope.invalidRemoveErrorShow = false;
            var email = $('#userList').val();
            
            if (!validateEmail(email)) {
                setAddUserError('Please enter a valid email');
            } else {
                $scope.modifyTreeModalWorking = true;
                var promise = $http.put(apiRoot.getRoot() + '/services/tree/' + $scope.tree.id + "/user", {
                    userToAdd: email
                });

                promise.then(
                    function(response) {
                        var user = response.data;
                        user.email = email;
                        $scope.tree.users.push(user);
                        $('#userList').val('');
                        $scope.modifyTreeModalWorking = false;
                    },
                    function(response) {
                        if (response.status != 500 && response.status != 502) {
                            setAddUserError(response.data.txt);
                        } else {
                            setAddUserError(constants.servicesDown());
                        }
                    }
                );
            }
        }
        
        $scope.openNewBranchModal = function() {
            $scope.selectedBranchType = 'grid';
            $scope.newBranchName = '';
            $scope.newBranchErrorMessage = false;
            $scope.newBranchModalWorking = false;
            $('#newBranchModal').appendTo('body').modal('show');
        }
        
        function setNewBranchError(msg) {
            $scope.newBranchErrorText = msg;
            $scope.newBranchErrorMessage = true;
            $scope.newBranchModalWorking = false;
        }

        $scope.newBranch = function() {
            var branchName = $scope.newBranchName;

            if (!branchName) {
                setNewBranchError('Please enter a branch name');
            } else if (!nameTest.test(branchName)) {
                setNewBranchError("A branch name must include at least one alphanumeric character");
            } else {
                $scope.newBranchModalWorking = true;
                var promise = $http.post(apiRoot.getRoot() + '/services/' + $scope.tree.id + '/branch', {
                    name: branchName,
                    type: $scope.selectedBranchType
                });
                
                promise.then(
                    function(response) {
                        var branch = response.data;
                        branch.icon = '';
                        $scope.tree.branches.push(branch);
                        $scope.newBranchModalWorking = true;
                        $('#newBranchModal').modal('hide');
                    },
                    function(response) {
                        if (response.status != 500 && response.status != 502) {
                            setNewBranchError(response.data.txt);
                        } else {
                            setNewBranchError(constants.servicesDown());
                        }
                    }
                ); 
            }
        }
        /*
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
        */
        var renderContext = requestContext.getRenderContext("standard.tree");
        $scope.subview = renderContext.getNextSection();
        $scope.$on("requestContextChanged", function() {
            if (!renderContext.isChangeRelevant()) {
                return;
            }
            $scope.subview = renderContext.getNextSection();
        });

        $('#modifyTreeModal').on('hidden.bs.modal', function() {
            $('#modifyTreeModal').appendTo('#treeIndex');
        });

        $('#deleteTreeModal').on('hidden.bs.modal', function() {
            $('#deleteTreeModal').appendTo('#treeIndex');
        });
        
        $('#newLeafModal').on('hidden.bs.modal', function() {
            $('#newLeafModal').appendTo('#treeIndex');
        });

        $('#newBranchModal').on('hidden.bs.modal', function() {
            $('#newBranchModal').appendTo('#treeIndex');
        });        
        
        $scope.leafDisplayOptions = [
            {name: 'All', value: 0},
            {name: 'Assigned To Me', value: 1},
            {name: 'Unassigned', value: 2}
        ];
        $scope.leafDisplay = $scope.leafDisplayOptions[0];

        $scope.$watch('leafDisplay', function() {
            //alert($scope.leafDisplay.name);
            $scope.$broadcast('filterLeaves', $scope.leafDisplay.value); 
        });
        //$scope.$evalAsync(loadTreeData());
        var nameTest = new RegExp('[A-Za-z0-9]');
        loadTreeData($routeParams.treeID) 
        console.log('tree');

    });
})(angular, AnnoTree);
