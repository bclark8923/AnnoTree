(function( ng, app ) {
	
	"use strict";

	app.service("taskService",
		function( $http, apiRoot ) {

			function getTasks(forestID, treeID) {
				return $http.get(apiRoot.getRoot() + '/' + forestID + '/' + treeID + '/tasks');
			}

			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				getTasks: getTasks
			});


		}
	);

})( angular, AnnoTree );