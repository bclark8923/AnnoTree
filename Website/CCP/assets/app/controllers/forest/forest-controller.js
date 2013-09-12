(function(ng, app){
    "use strict";

    app.controller("forest.ForestController",
        function($scope, $cookies, $rootScope, $location, $timeout, $route, $http, requestContext, branchService, apiRoot, constants) {
            function loadForestData() {
                var promise = $http.get(apiRoot.getRoot() + '/services/forest');

                promise.then(
                    function(response) {
                        if (response.status == 200) {
                            $scope.forests = response.data.forests;
                        }
                    },
                    function(response) {
                        $location.path("/forestFire"); //TODO: better way to handle this
                    }
                );
            }

            $scope.changeForestOwnerFn = function() {
                var newOwnerID = $scope.changeForestOwnerSelect;

                if (newOwnerID == 'nochange') {
                    setChangeForestOwnerError('Please select a new owner');
                } else if (newOwnerID == $scope.modifyForestRef.owner.id) {
                    setChangeForestOwnerError($scope.modifyForestRef.owner.first_name + ' ' + $scope.modifyForestRef.owner.last_name + ' is already the forest owner');
                } else {
                    $scope.changeForestOwnerWorking = true;
                    var promise = $http.put(apiRoot.getRoot() + '/services/forest/' + $scope.modifyForestRef.id + '/owner', {
                        owner: newOwnerID
                    });

                    promise.then(
                        function(response) {
                            for (var i = 0; i < $scope.forests.length; i++) {
                                if ($scope.forests[i].id == $scope.modifyForestRef.id) {
                                    $scope.forests[i].owner = response.data;
                                    break;
                                }
                            }
                            $scope.changeForestOwnerWorking = false;
                            $('#changeForestOwnerModal').modal('hide'); //TODO: angular way
                            $('#modifyForestModal').modal('hide'); //TODO: angular way
                        },
                        function(response) {
                            if (response.status != 500 && response.status != 502) {
                                setChangeForestOwnerError(response.data.txt);
                            } else {
                                setChangeForestOwnerError(constants.servicesDown());
                            }
                            $scope.changeForestOwnerWorking = false;
                        }
                    ); 
                }
            }
            
            function setChangeForestOwnerError(msg) {
                $scope.changeForestOwnerErrorText = msg;
                $scope.changeForestOwnerErrorMessage = true;
            }
            
            //TODO: use ngOptions when roles and permissions are created
            $scope.openChangeForestOwnerModal = function() {
                $('#changeForestOwnerModal').appendTo('body').modal('show'); //TODO: angular way
                $scope.changeForestOwnerErrorMessage = false;
                $scope.changeForestOwnerWorking = true;
                var promise = $http.get(apiRoot.getRoot() + '/services/forest/' + $scope.modifyForestRef.id + '/users');
                
                promise.then(
                    function(response) {
                        $rootScope.potentialForestOwners = response.data.users;
                        $scope.changeForestOwnerWorking = false;
                        $scope.changeForestOwnerSelect = 'nochange';
                    },
                    function(response) {
                        if (response.status != 500 && response.status != 502) {
                            setChangeForestOwnerError(response.data.txt);
                        } else {
                            setChangeForestOwnerError(constants.servicesDown());
                        }
                        $scope.changeForestOwnerWorking = false;
                    }
                );
            } 

            $scope.openNewTreeModal = function(forestID) {
                $scope.newTreeErrorMessage = false;
                $scope.newTreeWorking = false;
                $scope.newTreeName = '';
                $("#newTreeModal").appendTo('body').modal('show');
                $scope.newTreeForestID = forestID;
            }
           
            function setNewTreeError(msg) {
                $scope.newTreeErrorText = msg;
                $scope.newTreeErrorMessage = true;
            }

            $scope.newTreeFn = function() {
                var treeName = $scope.newTreeName;
                var treeDescription = "NULL";
                var forestID = $scope.newTreeForestID;

                if (!treeName) {
                    setNewTreeError("Please enter a tree name.");
                } else if (!nameTest.test(treeName)){
                    setNewTreeError("A tree name must include at least one alphanumeric character");
                } else {
                    $scope.newTreeWorking = true;
                    var promise = $http.post(apiRoot.getRoot() + '/services/' + forestID + '/tree', {
                        name: treeName
                    });

                    promise.then(
                        function(response) {
                            var newTree = response.data;
                            for (var i = 0; i < $scope.forests.length; i++) { 
                                if ($scope.forests[i].id == newTree.forest_id) {
                                    $scope.forests[i].trees.push(newTree);
                                    break;
                                }
                            }
                            $scope.newTreeWorking = false;
                            $("#newTreeModal").modal('hide'); //TODO: angular way
                        },
                        function(response) {
                            if (response.status != 500 && response.status != 502) {
                                setNewTreeError(response.data.txt);
                            } else {
                                setNewTreeError(constants.servicesDown());
                            }
                            $scope.newTreeWorking = false;
                        }
                    );
                    $('#newTreeModalWorking').removeClass('active');
                }
            }

            $scope.openModifyForestModal = function(forest) {
                $scope.modifyForestWorking = false;
                $scope.modifyForestErrorMessage = false;
                $scope.modifyForestRef = forest;
                $scope.modifyForestName = angular.copy(forest.name);
                for (var i = 0; i < $scope.forests.length; i++) {
                    if ($scope.forests[i].id == forest.id) {
                        if ($scope.forests[i].owner === undefined) {
                            $scope.forestOwner = 'No current owner';
                        } else {
                            $scope.forestOwner = $scope.forests[i].owner;
                        }
                        break;
                    }
                }
                $("#modifyForestModal").appendTo('body').modal('show'); //TODO:angular way
            }

            function setModifyForestError(msg) {
                $scope.modifyForestErrorText = msg;
                $scope.modifyForestErrorMessage = true;
            }

            $scope.modifyForestFn = function() {
                var forestID = $scope.modifyForestRef.id;
                var forestName = $scope.modifyForestName;

                if (!forestName) {
                    setModifyForestError("Please enter a forest name");
                } else if (!nameTest.test(forestName)) {
                    setModifyForestError("A forest name must include at least one alphanumeric character");
                } else {
                    $scope.modifyForestWorking = true;
                    var promise = $http.put(apiRoot.getRoot() + '/services/forest/' + forestID, {
                        name: forestName
                    });

                    promise.then(
                        function(response) {
                            $scope.modifyForestWorking = false;
                            $scope.modifyForestRef.name = forestName;
                            $scope.invalidModifyForest = false;
                            $("#modifyForestModal").modal('hide'); //TODO:angular way 
                        },
                        function(response) {
                            if (response.status != 500 && response.status != 502) {
                                setModifyForestError(response.data.txt);
                            } else {
                                setModifyForestError(constants.servicesDown());
                            }
                            $scope.modifyForestWorking = false;
                        }
                    );
                }
            }

            $scope.deleteForestCallback = function() {
                $scope.deleteForestWorking = false;
                $scope.deleteForestErrorMessage = false;
                $("#deleteCallbackModal").appendTo('body').modal('show'); //TODO:angular way 
            }
            
            function setDeleteForestError(msg) {
                $scope.deleteForestErrorText = msg;
                $scope.deleteForestErrorMessage = true;
            }

            $scope.deleteForest = function() {
                $scope.deleteForestWorking = true;
                var promise = $http.delete(apiRoot.getRoot() + '/services/forest/' + $scope.modifyForestRef.id);

                promise.then(
                    function(response) {
                        for (var i = 0; i < $scope.forests.length; i++) { 
                            if ($scope.forests[i].id == $scope.modifyForestRef.id) {
                                $scope.forests.splice(i, 1);
                                break;
                            }
                        }
                        $scope.deleteForestWorking = false;
                        $("#deleteCallbackModal").modal('hide'); //TODO:angular way 
                        $("#modifyForestModal").modal('hide'); //TODO:angular way 
                    },
                    function(response) {
                        if (response.status != 500 && response.status != 502) {
                            setDeleteForestError(response.data.txt);
                        } else {
                            setDeleteForestError(constants.servicesDown());
                        }
                        $scope.deleteForestWorking = false;
                    }
                );
            }

            $scope.openNewForestModal = function() {
                $scope.newForestName = '';
                $scope.newForestErrorMessage = false;
                $scope.newForestModalWorking = false;
                $("#newForestModal").appendTo('body').modal('show'); //TODO:angular way 
            }
            
            function setNewForestError(msg) {
                $scope.newForestErrorText = msg;
                $scope.newForestErrorMessage = true;
            }

            $scope.newForest = function() {
                var forestName = $scope.newForestName;

                if (!forestName) {
                    setNewForestError("Please enter a forest name");
                } else if (!nameTest.test(forestName)) {
                    setNewForestError("A forest name must include at least one alphanumeric character");
                } else {
                    $scope.newForestModalWorking = true;

                    var promise = $http.post(apiRoot.getRoot() + '/services/forest/', {
                        name: forestName
                    });

                    promise.then(
                        function(response) {
                            $scope.newForestErrorMessage = false;
                            var newForest = response.data;
                            newForest.owner = angular.copy($scope.user);
                            newForest.trees = [];
                            $scope.forests.push(newForest);
                            $scope.newForestModalWorking = false;
                            $('#newForestModal').modal('hide');  //TODO:angular way 
                        },
                        function(response) {
                            if (response.status != 500 && response.status != 502) {
                                setNewForestError(response.data.txt);
                            } else {
                                setNewForestError(constants.servicesDown());
                            }
                            $scope.newForestModalWorking = false;
                        }
                    );
                }
            }

            $scope.forests = [];
            var nameTest = new RegExp('[A-Za-z0-9]');
            
            var renderContext = requestContext.getRenderContext("standard.forest");
            $scope.subview = renderContext.getNextSection();
            $scope.$on("requestContextChanged", function() {
                if (!renderContext.isChangeRelevant()) {
                    return;
                }
                $scope.subview = renderContext.getNextSection();
            });

            $scope.$evalAsync(loadForestData());
            $("#loadingScreen").hide();  //TODO:angular way 
            console.log('forest');
        }
    );
})(angular, AnnoTree);
