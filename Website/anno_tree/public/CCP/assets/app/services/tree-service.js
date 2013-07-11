(function( ng, app ) {
	
	"use strict";

	app.service("treeService",
		function( $http, apiRoot ) {

			function getTree(treeID) {
				$("#loadingScreen").show();
				return $http.get(apiRoot.getRoot() + '/tree/' + treeID);
			}

			function createTree(forestID, treeName, treeDescription) {
				$("#loadingScreen").show();
				return $http.post(apiRoot.getRoot() + '/' + forestID + '/tree', {name: treeName, description: treeDescription});
			}

			function updateTree(treeID, treeName, treeDescription) {
				$("#loadingScreen").show();
				return $http.put(apiRoot.getRoot() + '/tree/' + treeID, {name: treeName, description: treeDescription});
			}

			function deleteTree(treeID) {
				return $http.delete(apiRoot.getRoot() + '/tree/' + treeID);
			}

			function getKnownPeople() {
				//$("#loadingScreen").show();
				return $http.get(apiRoot.getRoot() + '/user/knownpeople');
			}

			function addUser(treeID, userID) {
				//$("#loadingScreen").show();
				return $http.put(apiRoot.getRoot() + '/tree/' + treeID + "/user", {userToAdd: userID});
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
				addUser: addUser
			});


		}
	);

})( angular, AnnoTree );