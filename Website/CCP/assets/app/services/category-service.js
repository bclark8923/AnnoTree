(function( ng, app ) {
    
    "use strict";

    // I provide a repository for the categories.
    app.service(
        "categoryService",
        function( $q, _, $http, apiRoot ) {


            function getTrees() {
                return $http.get(apiRoot.getRoot() + '/2/tree');
            }

            // I get all of the categories.
            function getCategories() {

                var deferred = $q.defer();
                
                deferred.resolve( ng.copy( cache ) );

                return( deferred.promise );

            }


            // I get the category with the given ID.
            function getCategoryByID( id ) {

                var deferred = $q.defer();
                var category = _.findWithProperty( cache, "id", id );

                if ( category ) {

                    deferred.resolve( ng.copy( category ) );

                } else {

                    deferred.reject();

                }

                return( deferred.promise );

            }


            // ---------------------------------------------- //
            // ---------------------------------------------- //


            // Set up the categories data cache. For this demo, we'll just use static data.
            var cache = [
                {
                    id: "cats",
                    name: "Cats",
                    description: "Cats are graceful and cunning."
                },
                {
                    id: "dogs",
                    name: "Dogs",
                    description: "Dogs are super awesome and adorable."
                }
            ];


            // ---------------------------------------------- //
            // ---------------------------------------------- //


            // Return the public API.
            return({
                getTrees: getTrees,
                getCategories: getCategories,
                getCategoryByID: getCategoryByID
            });


        }
    );

})( angular, AnnoTree );
