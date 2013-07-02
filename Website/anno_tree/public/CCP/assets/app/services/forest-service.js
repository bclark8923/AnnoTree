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

			function createBranch(treeID, branchName, branchDescription) {
				return $http.post(apiRoot.getRoot() + '/' + treeID + '/branch', {name: branchName, description: branchDescription});
			}

			function getLeaf(leafID) {
				return $http.get(apiRoot.getRoot() + '/leaf/' + leafID);
			}

			function createLeaf(branchID, leafName, leafDescription) {
				return $http.post(apiRoot.getRoot() + '/' + branchID + '/leaf', {name: leafName, description: leafDescription});
			}

			function createAnnotation(leafID, formData, xhr) {
		        xhr.open("POST", apiRoot.getRoot() + "/"+leafID+"/annotation");
		        xhr.send(formData);
		        return;
			}

			function getTasks(treeID) {
				return $http.get(apiRoot.getRoot() + '/' + treeID + '/tasks');
			}

			function createTask(treeID, taskDescription) {
				return $http.post(apiRoot.getRoot() + '/tasks', {treeid: treeID, description: taskDescription, status: 1});
			}

			function createTaskLeaf(treeID, leafID, taskDescription) {
				return $http.post(apiRoot.getRoot() + '/tasks', {treeid: treeID, description: taskDescription, status: 1, leafid: leafID});
			}

			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				getTrees: getTrees,
				createForest: createForest,
				getTree: getTree,
				createTree: createTree,
				createBranch: createBranch,
				getLeaf: getLeaf,
				createLeaf: createLeaf,
				createAnnotation: createAnnotation,
				getTasks: getTasks,
				createTask: createTask,
				createTaskLeaf: createTaskLeaf
			});


		}
	);

})( angular, AnnoTree );