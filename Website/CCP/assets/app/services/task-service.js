(function( ng, app ) {
    
    "use strict";

    app.service("taskService",
        function( $http, apiRoot ) {

            function getTasks(treeID) {
                //$("#loadingScreen").show();
                return $http.get(apiRoot.getRoot() + '/services/' + treeID + '/tasks');
            }

            function createTask(treeID, taskDescription) {
                //$("#loadingScreen").show();
                return $http.post(apiRoot.getRoot() + '/services/tasks', {treeid: treeID, description: taskDescription, status: 1});
            }

            function createTaskLeaf(treeID, leafID, taskDescription) {
                //$("#loadingScreen").show();
                return $http.post(apiRoot.getRoot() + '/services/tasks', {treeid: treeID, description: taskDescription, status: 1, leafid: leafID});
            }

            function updateTask(taskID, leafID, taskDescription, statusID, assignedTo, dueDate) {
                //$("#loadingScreen").show();
                return $http.put(apiRoot.getRoot() + '/services/tasks/' + taskID, {description: taskDescription, 
                                                                         status: statusID, 
                                                                         leafid: leafID,
                                                                         assignedTo: assignedTo,
                                                                         dueDate: dueDate
                                                                        });
            }

            // ---------------------------------------------- //
            // ---------------------------------------------- //


            // Return the public API.
            return({
                getTasks: getTasks,
                createTask: createTask,
                createTaskLeaf: createTaskLeaf,
                updateTask: updateTask
            });


        }
    );

})( angular, AnnoTree );
