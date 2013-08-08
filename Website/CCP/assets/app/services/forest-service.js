(function( ng, app ) {
    
    "use strict";

    app.service("forestService",
        function( $http, apiRoot ) {

            function getForests() {
                $("#loadingScreen").show();
                return $http.get(apiRoot.getRoot() + '/services/forest');
            }

            function updateForest(forestID, forestName, forestDescription) {
                $("#loadingScreen").show();
                return $http.put(apiRoot.getRoot() + '/services/forest/' + forestID, {name: forestName, description: forestDescription});
            }

            function createForest(forestName, forestDescription) {
                $("#loadingScreen").show();
                return $http.post(apiRoot.getRoot() + '/services/forest', {name: forestName, description: forestDescription});
            }

            function deleteForest(forestID) {
                return $http.delete(apiRoot.getRoot() + '/services/forest/' + forestID);
            }

            function getForestUsers(forestID) {
                return $http.get(apiRoot.getRoot() + '/services/forest/' + forestID + '/users');
            }

            function updateForestOwner(ownerID, forestID) {
                return $http.put(apiRoot.getRoot() + '/services/forest/' + forestID + '/owner', {owner: ownerID});
            }
            // ---------------------------------------------- //
            // ---------------------------------------------- //


            // Return the public API.
            return({
                getForests: getForests,
                updateForest: updateForest,
                createForest: createForest,
                deleteForest: deleteForest,
                getForestUsers: getForestUsers,
                updateForestOwner: updateForestOwner
            });
        }
    );
}) ( angular, AnnoTree );
