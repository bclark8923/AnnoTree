(function( ng, app ) {
	
	"use strict";

	app.service("forestService",
		function( $http, apiRoot ) {

			function getTrees() {
				return $http.get(apiRoot.getRoot() + '/forest');
			}
/*
			function createForest(forestName, forestDescription) {
				return $http.post(apiRoot.getRoot() + '/forest', {name: forestName, description: forestDescription});
			}
*/
			function getTree(forestID, treeID) {
				return $http.get(apiRoot.getRoot() + '/' + forestID + '/' + treeID);
			}

			function createTree(treeName, treeDescription) {
				return $http.post(apiRoot.getRoot() + '/' + forestID + '/tree', {name: treeName, description: treeDescription});
			}

			function getLeaf(forestID, treeID, leafID) {
				return $http.get(apiRoot.getRoot() + '/' + forestID + '/' + treeID + '/' + leafID);
			}

			function createLeaf(forestID, treeID, leafName) {
				return $http.post(apiRoot.getRoot() + '/' + forestID + '/' + treeID + '/leaf', {name: leafName});
			}

			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				getTrees: getTrees,
				//createForest: createForest,
				getTree: getTree,
				createTree: createTree,
				getLeaf: getLeaf,
				createLeaf: createLeaf
			});


		}
	);

})( angular, AnnoTree );