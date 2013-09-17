(function(ng, app) {
    "use strict";

    app.controller("tree.LeavesController", function(
        $scope, $location, $http, $routeParams, $timeout, apiRoot, constants
    ) {
        function loadLeavesData() {
            var branchID = $scope.activeBranch.id;

            var promise = $http.get(apiRoot.getRoot() + '/services/' + $routeParams.treeID + '/branch/' + branchID);
            
            promise.then(
                function(response) {
                    var leaves = response.data.leaves;
                    for (var i = 0; i < leaves.length; i++) {
                        if (leaves[i].annotation == null) {
                            leaves[i].annotation = "img/noImageBG.png";
                        }
                    }
                    $scope.leaves = leaves;
                    if ($routeParams.leafID) {
                        $scope.showLeaf($routeParams.leafID);
                    }
                },
                function(response) {
                    $location.path("/forestFire"); //TODO: should redirect to app page and tell them why
                }
            );
        }

        $scope.showLeaf = function(leafID) {
            $scope.$broadcast('showLeaf', leafID);
        }

        $scope.$on('newLeafCreated', function(evt, leafData) {
            $scope.leaves.push(leafData);
            if(!$scope.$$phase) {
                $scope.$apply();
            }
        });

        $scope.$on('newAnnotation', function(evt, leafID, path) {
            for (var i = 0; i < $scope.leaves.length; i++) {
                if ($scope.leaves[i].id == leafID) {
                    $scope.leaves[i].annotation = path;
                    break;
                }
            }
        });

        $scope.$on('leafRename', function(evt, leafID, name) {
            for (var i = 0; i < $scope.leaves.length; i++) {
                if ($scope.leaves[i].id == leafID) {
                    $scope.leaves[i].name = name;
                    break;
                }
            }
        });

        $scope.$on('leafDelete', function(evt, leafID) {
            var dropPriority = false;
            var spliceIndex = 0;
            for (var i = 0; i < $scope.leaves.length; i++) {
                if (dropPriority) {
                    $scope.leaves[i].priority--;
                }
                if ($scope.leaves[i].id == leafID) {
                    spliceIndex = i;
                    dropPriority = true;
                }
            }
            $scope.leaves.splice(spliceIndex, 1);
        });

        $scope.$evalAsync(loadLeavesData());
        console.log('leaves');
    });
})(angular, AnnoTree);
