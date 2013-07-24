(function( ng, app ) {
    
    "use strict";

    app.service("deleteService",
        function( $http, apiRoot ) {

            function setFn(fn) {
                $scope.fn = fn;
            }

            function deleteFn() {
                $scope.fn();
            }
            // ---------------------------------------------- //
            // ---------------------------------------------- //


            // Return the public API.
            return({
                setFn: setFn,
                deleteFn: deleteFn
            });


        }
    );

})( angular, AnnoTree );
