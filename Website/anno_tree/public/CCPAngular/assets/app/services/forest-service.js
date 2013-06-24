(function( ng, app ) {
	
	"use strict";

	app.service("forestService",
		function( $http, apiRoot ) {

			function getTrees() {
				return $http.get(apiRoot.getRoot() + '/2/tree');
			}

			// ---------------------------------------------- //
			// ---------------------------------------------- //


			// Return the public API.
			return({
				getTrees: getTrees
			});


		}
	);

})( angular, AnnoTree );