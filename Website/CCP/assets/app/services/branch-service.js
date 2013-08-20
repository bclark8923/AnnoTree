(function( ng, app ) {
    
    "use strict";

    app.service("branchService",
        function( $http, apiRoot ) {

            function createBranch(treeID, branchName, branchDescription) {
                $("#loadingScreen").show();
                return $http.post(apiRoot.getRoot() + '/services/' + treeID + '/branch', {name: branchName, description: branchDescription});
            }

            return({
                createBranch: createBranch
            });


        }
    );

})( angular, AnnoTree );
