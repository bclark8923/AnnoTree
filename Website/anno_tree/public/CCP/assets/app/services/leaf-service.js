(function( ng, app ) {
	
	"use strict";

	app.service("leafService",
		function( $http, apiRoot ) {

			function getLeaf(leafID) {
				$("#loadingScreen").show();
				return $http.get(apiRoot.getRoot() + '/leaf/' + leafID);
			}

			function createLeaf(branchID, leafName, leafDescription) {
				$("#loadingScreen").show();
				return $http.post(apiRoot.getRoot() + '/' + branchID + '/leaf', {name: leafName, description: leafDescription});
			}

			function updateLeaf(leafID, branchID, leafName, leafDescription) {
				$("#loadingScreen").show();
				return $http.put(apiRoot.getRoot() + '/leaf/' + leafID, {name: leafName, description: leafDescription, branchid: branchID});
			}

			function deleteLeaf(leafID) {
				return $http.delete(apiRoot.getRoot() + '/leaf/' + leafID);
			}

			function createAnnotation(leafID, formData, xhr) {
				$("#loadingScreen").show();
		        xhr.open("POST", apiRoot.getRoot() + "/"+leafID+"/annotation");
		        xhr.send(formData);
		        return;
			}

			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				getLeaf: getLeaf,
				createLeaf: createLeaf,
				updateLeaf: updateLeaf,
				deleteLeaf: deleteLeaf,
				createAnnotation: createAnnotation
			});


		}
	);

})( angular, AnnoTree );