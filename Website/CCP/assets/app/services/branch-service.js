(function( ng, app ) {
	
	"use strict";

	app.service("branchService",
		function( $http, apiRoot ) {

			function createBranch(treeID, branchName, branchDescription) {
				$("#loadingScreen").show();
				return $http.post(apiRoot.getRoot() + '/' + treeID + '/branch', {name: branchName, description: branchDescription});
			}

			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				createBranch: createBranch
			});


		}
	);

})( angular, AnnoTree );