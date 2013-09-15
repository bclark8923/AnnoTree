(function(ng, app) {
    "use strict";

    app.controller("tree.SubBranchController", function(
        $scope, $location, $http, $routeParams, $timeout, apiRoot
    ) {
        function loadBranchData() {
            var branchID;
            if ($scope.activeBranch === undefined) {
                branchID = $routeParams.branchID;
            } else {
                branchID = $scope.activeBranch.id;
            }
            var promise = $http.get(apiRoot.getRoot() + '/services/' + $routeParams.treeID + '/parentbranch/' + branchID);
            
            promise.then(
                function(response) {
                    $scope.branches = response.data.branches;
                    setScroll();
                },
                function(response) {
                    $location.path("/forestFire"); //TODO: should redirect to app page and tell them why
                }
            );
        }
        
        $scope.subBranchDroppedLeaf = [];
        $scope.subBranchDrop = function(evt, ui) {
            var data = $scope.subBranchDroppedLeaf[0];
            $scope.subBranchDroppedLeaf = [];
            var regEx = /b(\d+)i(\d+)/;
            var match = regEx.exec(evt.target.id);
            var branchID = match[1];
            var priority = parseInt(match[2]);
            var oldBranchID = data.branch_id;
            var oldPriority = data.priority;
            var promise = $http.put(apiRoot.getRoot() + '/services/' + $routeParams.treeID + '/' + branchID + '/subchange/' + data.id, {
                newPriority: priority + 1,
                oldPriority: oldPriority,
                oldBranch: oldBranchID
            }); //TODO: check for success/failure
            for (var i = 0; i < $scope.branches.length; i++) {
                if ($scope.branches[i].id == branchID) {
                    data.priority = (priority + 1);
                    data.branch_id = branchID;
                    for (var l = priority - 1; l < $scope.branches[i].leaves.length; l++) {
                        if (l >= 0 && $scope.branches[i].leaves[l].priority >= data.priority) {
                            $scope.branches[i].leaves[l].priority++;
                        }
                        //alert($scope.branches[i].leaves[l].name + ' increased by 1');
                    }
                    $scope.branches[i].leaves.splice(priority, 0, data);
                    break;
                }
            }
            for (var i = 0; i < $scope.branches.length; i++) {
                if ($scope.branches[i].id == oldBranchID) {
                    for (var l = oldPriority - 1; l < $scope.branches[i].leaves.length; l++) {
                        if ($scope.branches[i].leaves[l].priority > oldPriority) {
                            $scope.branches[i].leaves[l].priority--;
                        }
                        //alert($scope.branches[i].leaves[l].name + ' decreased by 1');
                    }
                    break;
                }
            }
            /*
            var testData = "";
            for (var i = 0; i < $scope.branches.length; i++) {
                if ($scope.branches[i].id == branchID) { 
                    for (var l = 0; l < $scope.branches[i].leaves.length; l++) {
                        testData += $scope.branches[i].leaves[l].name + ' ' + $scope.branches[i].leaves[l].priority + "|";
                    } 
                }
            }
            alert(testData);
            */
        }

        function setScroll() {
            if ($(window).outerWidth() > 767) {
                $timeout(function() {
                    var height = $(window).outerHeight();
                    $('.branchColumnLeaves').css('max-height', height - 110);
                    $('#branchColumnHolder').css('overflow-y', 'hidden');
                }, 0);
            } else {
                $('#branchColumnHolder').css('overflow-y', 'scroll');
                $('.branchColumnLeaves').css('max-height', '100%');
            }
        }
               
        $scope.$on('newLeafCreated', function(evt, leafData) {
            for (var i = 0; i < $scope.branches.length; i++) {
                if ($scope.branches[i].id == leafData.branch_id) {
                    $scope.branches[i].leaves.push(leafData);
                    break;
                }
            } 
            $scope.$apply();
        }); 
       
        $scope.showLeaf = function(leafID) {
            $scope.$broadcast('showLeaf', leafID);
        }

        $scope.openAssign = function() {
            alert('this will assign someone eventually');
        }

        $scope.$on('leafRename', function(evt, leafID, name, branchID) {
            for (var b = 0; b < $scope.branches.length; b++) {
                if ($scope.branches[b].id == branchID) {
                    for (var i = 0; i < $scope.branches[b].leaves.length; i++) {
                        if ($scope.branches[b].leaves[i].id == leafID) {
                            $scope.branches[b].leaves[i].name = name;
                            break;
                        }
                    }
                    break;
                }
            }
        }); 

        $scope.$on('leafDelete', function(evt, leafID, branchID) {
            var dropPriority = false;
            var spliceIndex = 0;
            for (var b = 0; b < $scope.branches.length; b++) {
                if ($scope.branches[b].id == branchID) {
                    for (var i = 0; i < $scope.branches[b].leaves.length; i++) {
                        if (dropPriority) {
                            $scope.branches[b].leaves[i].priority--;
                        }
                        if ($scope.branches[b].leaves[i].id == leafID) {
                            spliceIndex = i;
                            dropPriority = true;
                        }
                    }
                    $scope.branches[b].leaves.splice(spliceIndex, 1);
                    break;
                }
            }
        });

        $(window).resize(setScroll);
        $scope.$watch('activeBranch', function(oldValue, newValue) {loadBranchData()}, true);
        $scope.$watch('branches', function(oldValue, newValue) {setScroll()}, true);
        $scope.$evalAsync(loadBranchData());
        console.log('sub-branches');
    });
})(angular, AnnoTree);
