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
                    }
                    break;
                }
            }
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
       
        $scope.showLeaf = function(evt, leafID) {
            if (!assignTest.test(evt.target.id)) {
                $scope.$broadcast('showLeaf', leafID);
            }
        }
        
        function createAssignPopoverBody(leafID, branchID) {
            var body = '<select style="form-control" id="assignSelect">';
            body += '<option value="0" selected>Choose who to assign</option>';
            for (var i = 0; i < $scope.tree.users.length; i++) {
                var isAssigned = false;
                for (var b = 0; b < $scope.branches.length; b++) {
                    if ($scope.branches[b].id == branchID) {
                        for (var l = 0; l < $scope.branches[b].leaves.length; l++) {
                            if ($scope.branches[b].leaves[l].id == leafID) {
                                for (var a = 0; a < $scope.branches[b].leaves[l].assigned.length; a++) {
                                    if ($scope.branches[b].leaves[l].assigned[a].id == $scope.tree.users[i].id) {
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
                    body += '<option value="' + $scope.tree.users[i].id + '">' + createName($scope.tree.users[i]) + '</option>';
                }
            }
            body += '</select>';

            return body;
        }
        
        function createName(user) {
            var name = '';
            if (user.first_name != null) {
                name += user.first_name + ' ';
            }
            if (user.last_name != null) {
                name += user.last_name;
            }
            if (name == '') {
                name += user.email;
            }
            return name;
        }
        
        function createAssignedUserPopoverBody() {
            var container = $('<div style="text-align:center"></div>');
            container.append($('<button type="button" id="assignRemove" class="btn btn-danger"><strong>Unassign</strong></button>'));
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
                    content: createAssignedUserPopoverBody(),
                    placement: 'top',
                    container: 'body'
                });
                if (assignPopover != null) {
                    assignPopover.popover('destroy');
                    assignPopover = null; 
                }
                $(evt.target).popover('show');
                selectedAssignedUser = "" + user.id + leafID;
                $('#assignRemove').click(function() {
                    //alert(leafID + " " + user.id);
                    $http.delete(apiRoot.getRoot() + '/services/leaf/' + leafID + '/assign/' + user.id); //TODO: check for success/failure 
                    for (var b = 0; b < $scope.branches.length; b++) {
                        if ($scope.branches[b].id == branchID) {
                            for (var l = 0; l < $scope.branches[b].leaves.length; l++) {
                                if ($scope.branches[b].leaves[l].id == leafID) {
                                    for (var a = 0; a < $scope.branches[b].leaves[l].assigned.length; a++) {
                                        if ($scope.branches[b].leaves[l].assigned[a].id == user.id) {
                                            $scope.branches[b].leaves[l].assigned.splice(a, 1);
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
            } else {
                assignedUserPopover.popover('destroy');
                assignedUserPopover = null; 
            }
        }

        var assignPopover = null;
        var selectedAssign = "";
        $scope.openAssign = function(evt, leafID, branchID) {
            if (selectedAssign != "" + leafID + branchID && assignPopover != null) {
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
                selectedAssign = "" + leafID + branchID;
                $('#assignSelect').change(function(evt) {
                    var userID = $('#assignSelect').val();
                    $http.put(apiRoot.getRoot() + '/services/leaf/' + leafID + '/assign', {
                        assign: userID
                    }); //TODO: check for success/failure
                    //alert($('#assignSelect').val() + " " + leafID);
                    $("#assignSelect option[value='" + userID  + "']").remove();
                    for (var i = 0; i < $scope.tree.users.length; i++) {
                        if ($scope.tree.users[i].id == userID) {
                            for (var b = 0; b < $scope.branches.length; b++) {
                                if ($scope.branches[b].id == branchID) {
                                    for (var l = 0; l < $scope.branches[b].leaves.length; l++) {
                                        if ($scope.branches[b].leaves[l].id == leafID) {
                                            $scope.branches[b].leaves[l].assigned.push($scope.tree.users[i]);
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
            } else {
                assignPopover.popover('destroy');
                assignPopover = null;
            }
        }
        
        $scope.hidePopovers = function() {
            if (assignPopover != null) {
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
        
        var assignTest = new RegExp('assign');
        $(window).resize(setScroll);
        $scope.$watch('activeBranch', function(oldValue, newValue) {loadBranchData()}, true);
        $scope.$watch('branches', function(oldValue, newValue) {setScroll()}, true);
        $scope.$evalAsync(loadBranchData());
        console.log('sub-branches');
    });
})(angular, AnnoTree);
