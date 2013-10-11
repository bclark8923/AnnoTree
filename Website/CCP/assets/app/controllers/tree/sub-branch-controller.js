(function(ng, app) {
    "use strict";

    app.controller("tree.SubBranchController", function(
        $scope, $location, $http, $routeParams, $timeout, apiRoot, dataService
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
                    $scope.parentBranch = response.data; //.branches;
                    leafFilter($scope.leafDisplay.value);
                    setScroll();
                    if ($routeParams.leafID) {
                        $scope.$broadcast('showLeaf',$routeParams.leafID);
                    }
                },
                function(response) {
                    $location.path("/forestFire"); //TODO: should redirect to app page and tell them why
                }
            );
        }
        
        function setScroll() {
            if ($(window).outerWidth() > 767) {
                $timeout(function() {
                    var height = $(window).outerHeight();
                    $('.branchColumnLeaves').css('height', height - 135);
                    $('#branchColumnHolder').css('overflow-y', 'hidden');
                }, 0);
            } else {
                $('#branchColumnHolder').css('overflow-y', 'auto');
                $('.branchColumnLeaves').css('max-height', '100%');
            }
        }
               
        $scope.$on('newLeafCreated', function(evt, leafData) {
            for (var i = 0; i < $scope.parentBranch.branches.length; i++) {
                if ($scope.parentBranch.branches[i].id == leafData.branch_id) {
                    if ($scope.leafDisplay.value == 1) {
                        var user = dataService.getUser();
                        $http.put(apiRoot.getRoot() + '/services/leaf/' + leafData.id + '/assign', {
                            assign: user.id
                        });
                        leafData.assigned.push(user);
                    }
                    $scope.numLeaves[i]++;
                    leafData.show = true;
                    $scope.parentBranch.branches[i].leaves.push(leafData);
                    break;
                }
            }
            if(!$scope.$$phase) {
                $scope.$apply();
            }
        }); 
       
        $scope.showLeaf = function(evt, leafID) {
            if (!assignTest.test(evt.target.id)) {
                $scope.$broadcast('showLeaf', leafID);
            }
        }
        
        function createAssignPopoverBody(leafID, branchID) {
            var body = $('<select style="form-control" id="assignSelect"></select>');
            body.append($('<option value="0" selected>Choose who to assign</option>'));
            var usersToAssign = false;
            for (var i = 0; i < $scope.tree.users.length; i++) {
                var isAssigned = false;
                for (var b = 0; b < $scope.parentBranch.branches.length; b++) {
                    if ($scope.parentBranch.branches[b].id == branchID) {
                        for (var l = 0; l < $scope.parentBranch.branches[b].leaves.length; l++) {
                            if ($scope.parentBranch.branches[b].leaves[l].id == leafID) {
                                for (var a = 0; a < $scope.parentBranch.branches[b].leaves[l].assigned.length; a++) {
                                    if ($scope.parentBranch.branches[b].leaves[l].assigned[a].id == $scope.tree.users[i].id) {
                                        isAssigned = true;
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
                if (!isAssigned) {
                    body.append($('<option value="' + $scope.tree.users[i].id + '">' + createName($scope.tree.users[i]) + '</option>'));
                    usersToAssign = true;
                }
            }
            if (usersToAssign) {
                body.change(function(evt) {
                    var userID = $('#assignSelect').val();
                    $http.put(apiRoot.getRoot() + '/services/leaf/' + leafID + '/assign', {
                        assign: userID
                    }); //TODO: check for success/failure
                    $("#assignSelect option[value='" + userID  + "']").remove();
                    for (var i = 0; i < $scope.tree.users.length; i++) {
                        if ($scope.tree.users[i].id == userID) {
                            for (var b = 0; b < $scope.parentBranch.branches.length; b++) {
                                if ($scope.parentBranch.branches[b].id == branchID) {
                                    for (var l = 0; l < $scope.parentBranch.branches[b].leaves.length; l++) {
                                        if ($scope.parentBranch.branches[b].leaves[l].id == leafID) {
                                            $scope.parentBranch.branches[b].leaves[l].assigned.push($scope.tree.users[i]);
                                            $scope.$apply();
                                            break;
                                        }
                                    }
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    if ($('#assignSelect option').length == 1) {
                        $('#assignSelect').replaceWith(function() {
                            return $('<span>All users have been assigned</span>');
                        })
                    }
                });
            } else {
                body = "All users have been assigned";
            }
            return body;
        }
        
        function createName(user) {
            var name = '';
            if (user.first_name != null && user.first_name != '') {
                name += user.first_name + ' ';
            }
            if (user.last_name != null && user.last_name != '') {
                name += user.last_name;
            }
            if (name == '') {
                name += user.email;
            }
            return name;
        }
        
        function createAssignedUserPopoverBody(leafID, user, branchID) {
            var container = $('<div style="text-align:center"></div>');
            var button = $('<button type="button" id="assignRemove" class="btn btn-danger"><strong>Unassign</strong></button>');
            button.click(function() {
                $http.delete(apiRoot.getRoot() + '/services/leaf/' + leafID + '/assign/' + user.id); //TODO: check for success/failure 
                for (var b = 0; b < $scope.parentBranch.branches.length; b++) {
                    if ($scope.parentBranch.branches[b].id == branchID) {
                        for (var l = 0; l < $scope.parentBranch.branches[b].leaves.length; l++) {
                            if ($scope.parentBranch.branches[b].leaves[l].id == leafID) {
                                for (var a = 0; a < $scope.parentBranch.branches[b].leaves[l].assigned.length; a++) {
                                    if ($scope.parentBranch.branches[b].leaves[l].assigned[a].id == user.id) {
                                        var curUser = dataService.getUser();
                                        if ($scope.parentBranch.branches[b].leaves[l].assigned[a].id == curUser.id && $scope.leafDisplay.value == 1) {
                                            $scope.numLeaves[b]--;
                                            $scope.parentBranch.branches[b].leaves[l].show = false;
                                        }
                                        $scope.parentBranch.branches[b].leaves[l].assigned.splice(a, 1);
                                        $scope.hidePopovers();
                                        $scope.$apply();
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                        break;
                    }
                } 
            });
            container.append(button);
            return container;
        }

        var assignedUserPopover = null;
        var selectedAssignedUser = "";
        $scope.openAssignedUser = function(evt, leafID, user, branchID) {
            if (selectedAssignedUser != "" + user.id + leafID && assignedUserPopover != null) {
                assignedUserPopover.popover('destroy');
                assignedUserPopover = null;
            }
            if (assignedUserPopover == null) {
                assignedUserPopover = $(evt.target).popover({
                    title: createName(user),
                    html: true,
                    trigger: 'manual',
                    content: createAssignedUserPopoverBody(leafID, user, branchID),
                    placement: 'top',
                    container: 'body'
                });
                if (assignPopover != null) {
                    assignPopover.popover('destroy');
                    assignPopover = null; 
                }
                $(evt.target).popover('show');
                selectedAssignedUser = "" + user.id + leafID;

            } else {
                assignedUserPopover.popover('destroy');
                assignedUserPopover = null; 
            }
        }

        function hideIfDoneAssigning() {
            if ($scope.leafDisplay.value == 2) {
                for (var b = 0; b < $scope.parentBranch.branches.length; b++) {
                    if ($scope.parentBranch.branches[b].id == selectAssignBranchID) {
                        for (var l = 0; l < $scope.parentBranch.branches[b].leaves.length; l++) {
                            if ($scope.parentBranch.branches[b].leaves[l].id == selectAssignLeafID) {
                                if ($scope.parentBranch.branches[b].leaves[l].assigned.length > 0) {
                                    $scope.numLeaves[b]--;
                                    $scope.parentBranch.branches[b].leaves[l].show = false;
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
            }
            if(!$scope.$$phase) {
                $scope.$apply();
            }
        }

        var assignPopover = null;
        var selectAssignLeafID = null, selectAssignBranchID = null;
        $scope.openAssign = function(evt, leafID, branchID) {
            if ("" + selectAssignLeafID + selectAssignBranchID != "" + leafID + branchID && assignPopover != null) {
                hideIfDoneAssigning();
                assignPopover.popover('destroy');
                assignPopover = null; 
            }
            if (assignPopover == null) {
                assignPopover = $(evt.target).popover({
                    title: 'Leaf Assignment',
                    html: true,
                    trigger: 'manual',
                    content: createAssignPopoverBody(leafID, branchID),
                    placement: 'top',
                    container: 'body'
                });
                if (assignedUserPopover != null) {
                    assignedUserPopover.popover('destroy');
                    assignedUserPopover = null; 
                }
                $(evt.target).popover('show');
                selectAssignLeafID = leafID;
                selectAssignBranchID = branchID;
            } else {
                hideIfDoneAssigning();
                assignPopover.popover('destroy');
                assignPopover = null;
            }
        }
        
        $scope.hidePopovers = function() {
            if (assignPopover != null) {
                hideIfDoneAssigning();
                assignPopover.popover('destroy');
                assignPopover = null;
            }
            if (assignedUserPopover != null) {
                assignedUserPopover.popover('destroy');
                assignedUserPopover = null;  
            }        
        }

        $(document).on("click", function (evt) {
            var inPopover = $(evt.target).closest('.popover').length > 0;
            
            if (!inPopover && !assignTest.test(evt.target.id)) {
                $scope.hidePopovers();
            }
        });

        $scope.$on('leafRename', function(evt, leafID, name, branchID) {
            for (var b = 0; b < $scope.parentBranch.branches.length; b++) {
                if ($scope.parentBranch.branches[b].id == branchID) {
                    for (var i = 0; i < $scope.parentBranch.branches[b].leaves.length; i++) {
                        if ($scope.parentBranch.branches[b].leaves[i].id == leafID) {
                            $scope.parentBranch.branches[b].leaves[i].name = name;
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
            for (var b = 0; b < $scope.parentBranch.branches.length; b++) {
                if ($scope.parentBranch.branches[b].id == branchID) {
                    for (var i = 0; i < $scope.parentBranch.branches[b].leaves.length; i++) {
                        if (dropPriority) {
                            $scope.parentBranch.branches[b].leaves[i].priority--;
                        }
                        if ($scope.parentBranch.branches[b].leaves[i].id == leafID) {
                            spliceIndex = i;
                            dropPriority = true;
                        }
                    }
                    $scope.parentBranch.branches[b].leaves.splice(spliceIndex, 1);
                    $scope.numLeaves[b]--;
                    break;
                }
            }
        });

        function leafFilter(displayCode) {
            var user = dataService.getUser();
            for (var b = 0; b < $scope.parentBranch.branches.length; b++) {
                $scope.numLeaves[b] = 0;
                for (var l = 0; l < $scope.parentBranch.branches[b].leaves.length; l++) {
                    if (displayCode == 0) {
                        $scope.parentBranch.branches[b].leaves[l].show = true;
                        $scope.numLeaves[b]++;
                    } else if (displayCode == 1){
                        $scope.parentBranch.branches[b].leaves[l].show = false;
                        for (var a = 0; a < $scope.parentBranch.branches[b].leaves[l].assigned.length; a++) {
                            if ($scope.parentBranch.branches[b].leaves[l].assigned[a].id == user.id) {
                                $scope.parentBranch.branches[b].leaves[l].show = true;
                                $scope.numLeaves[b]++;
                                break;
                            }
                        }
                    } else if (displayCode == 2) {
                        $scope.parentBranch.branches[b].leaves[l].show = false;
                        if ($scope.parentBranch.branches[b].leaves[l].assigned.length == 0) {
                            $scope.parentBranch.branches[b].leaves[l].show = true;
                            $scope.numLeaves[b]++;
                        }
                    }
                }
            }
        }
        
        $scope.$on('filterLeaves', function(evt, displayCode) {
            leafFilter(displayCode);
        });
        
        $scope.numLeaves = [];
        var assignTest = new RegExp('assign');
        $(window).resize(setScroll);
        $scope.$watch('activeBranch', function(newValue, oldValue) {loadBranchData()}, true);
        $scope.$watch('parentBranch', function(newValue, oldValue) {
            setScroll()
        }, true);
        $scope.$evalAsync(loadBranchData());
        console.log('sub-branches');
    });
})(angular, AnnoTree);
