(function( ng, app ) {
    
    "use strict";

    app.service("treeService",
        function( $http, apiRoot ) {

            function getTree(treeID) {
                $("#loadingScreen").show();
                return $http.get(apiRoot.getRoot() + '/services/tree/' + treeID);
            }

            function createTree(forestID, treeName, treeDescription) {
                $("#loadingScreen").show();
                return $http.post(apiRoot.getRoot() + '/services/' + forestID + '/tree', {name: treeName, description: treeDescription});
            }

            function updateTree(treeID, treeName, treeDescription) {
                //$("#loadingScreen").show();
                return $http.put(apiRoot.getRoot() + '/services/tree/' + treeID, {name: treeName, description: treeDescription});
            }

            function deleteTree(treeID) {
                return $http.delete(apiRoot.getRoot() + '/services/tree/' + treeID);
            }

            function getKnownPeople() {
                //$("#loadingScreen").show();
                return $http.get(apiRoot.getRoot() + '/services/user/knownpeople');
            }

            function addUser(treeID, userID) {
                //$("#loadingScreen").show();
                return $http.put(apiRoot.getRoot() + '/services/tree/' + treeID + "/user", {userToAdd: userID});
            }

            function removeUser(treeID, userID) {
                //$("#loadingScreen").show();
                return $http.delete(apiRoot.getRoot() + '/services/tree/' + treeID + "/user/" + userID);
            }

            // ---------------------------------------------- //
            // ---------------------------------------------- //


            // Return the public API.
            return({
                getTree: getTree,
                createTree: createTree,
                updateTree: updateTree,
                deleteTree: deleteTree,
                getKnownPeople: getKnownPeople,
                addUser: addUser,
                removeUser: removeUser
            });


        }
    );

})( angular, AnnoTree );
