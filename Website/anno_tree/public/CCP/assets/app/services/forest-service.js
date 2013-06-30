(function( ng, app ) {
	
	"use strict";

	app.service("forestService",
		function( $http, apiRoot ) {

			function getTrees() {
				return $http.get(apiRoot.getRoot() + '/forest');
			}

			function createForest(forestName, forestDescription) {
				return $http.post(apiRoot.getRoot() + '/forest', {name: forestName, description: forestDescription});
			}
/*
			function createForest(forestName, forestDescription) {
				return $http.post(apiRoot.getRoot() + '/forest', {name: forestName, description: forestDescription});
			}
*/
			function getTree(treeID) {
				return $http.get(apiRoot.getRoot() + '/tree/' + treeID);
			}

			function createTree(forestID, treeName, treeDescription) {
				return $http.post(apiRoot.getRoot() + '/' + forestID + '/tree', {name: treeName, description: treeDescription});
			}

			function getLeaf(forestID, treeID, leafID) {
				return $http.get(apiRoot.getRoot() + '/' + forestID + '/' + treeID + '/' + leafID);
			}

			function createLeaf(branchID, leafName, leafDescription) {
				return $http.post(apiRoot.getRoot() + '/' + branchID + '/leaf', {name: leafName, description: leafDescription});
			}

			function createAnnotation(leafID, formData, xhr) {
		        xhr.open("POST", apiRoot.getRoot() + "/"+leafID+"/annotation");
		        xhr.send(formData);
		        return;
			}

			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				getTrees: getTrees,
				createForest: createForest,
				getTree: getTree,
				createTree: createTree,
				getLeaf: getLeaf,
				createLeaf: createLeaf,
				createAnnotation: createAnnotation
			});


		}
	);

})( angular, AnnoTree );