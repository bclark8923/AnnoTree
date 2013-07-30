(function( ng, app ) {
    
    "use strict";

    app.service("leafService",
        function( $http, apiRoot ) {

            function getLeaf(leafID) {
                $("#loadingScreen").show();
                return $http.get(apiRoot.getRoot() + '/services/leaf/' + leafID);
            }
            
            function addLeafComment(leafID, comment) {
                $("#loadingScreen").show();
                return $http.post(apiRoot.getRoot() + '/services/comments/leaf/' + leafID, {comment: comment});
            }

            function createLeaf(branchID, leafName, leafDescription) {
                //$("#loadingScreen").show();
                return $http.post(apiRoot.getRoot() + '/services/' + branchID + '/leaf', {name: leafName, description: leafDescription});
            }

            function updateLeaf(leafID, branchID, leafName, leafDescription) {
                $("#loadingScreen").show();
                return $http.put(apiRoot.getRoot() + '/services/leaf/' + leafID, {name: leafName, description: leafDescription, branchid: branchID});
            }

            function deleteLeaf(leafID) {
                return $http.delete(apiRoot.getRoot() + '/services/leaf/' + leafID);
            }

            function createAnnotation(leafID, formData, xhr) {
                //$("#loadingScreen").show();
                /* 
                return $http({
                    method: 'POST',
                    url: apiRoot.getRoot() + "/services/" + leafID + "/annotation",
                    data: formData,
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'}
                });
                */ 
                xhr.open("POST", apiRoot.getRoot() + "/services/" + leafID + "/annotation");
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
                createAnnotation: createAnnotation,
                addLeafComment: addLeafComment
            });


        }
    );

})( angular, AnnoTree );
