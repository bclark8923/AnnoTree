(function(ng, app) {
    "use strict";

    app.controller("tree.LeavesController", function(
        $scope, $location, $http, $routeParams, apiRoot, constants
    ) {
        function loadLeavesData() {
            //alert($scope.activeBranch.name);
            var branchID = $scope.activeBranch.id;
            /*
            if ($scope.activeBranch === undefined) {
                branchID = $routeParams.branchID;
            } else {
                branchID = $scope.activeBranch.id;
            }
            */
            var promise = $http.get(apiRoot.getRoot() + '/services/' + $routeParams.treeID + '/branch/' + branchID);
            
            promise.then(
                function(response) {
                    var leaves = response.data.leaves;
                    for (var i = 0; i < leaves.length; i++) {
                        if (leaves[i].annotations !== undefined && leaves[i].annotations.length > 0) {
                            leaves[i].annotation = leaves[i].annotations[leaves[i].annotations.length - 1].path;
                        } else {
                            leaves[i].annotation = "img/noImageBG.png";
                        }
                    }
                    $scope.leaves = leaves;
                },
                function(response) {
                    $location.path("/forestFire"); //TODO: should redirect to app page and tell them why
                }
            );
        }
        
        $scope.$on('newLeafCreated', function(evt, leafData) {
            $scope.leaves.push(leafData);
        });

        $scope.$evalAsync(loadLeavesData());
        console.log('leaves');
    });
})(angular, AnnoTree);
