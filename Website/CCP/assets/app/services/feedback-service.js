(function( ng, app ) {
    
    "use strict";

    app.service("feedbackService",
        function( $http, $location, $cookies, apiRoot ) {

            function submitFeedback(feedback) {
                return $http.post(apiRoot.getRoot() + '/user/feedback', {feedback: feedback});
            }

            // Return the public API.
            return({
                submitFeedback: submitFeedback
            });
        }
    );
})( angular, AnnoTree );
