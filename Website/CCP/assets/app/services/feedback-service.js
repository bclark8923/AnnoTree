(function(ng, app) {
    "use strict";

    app.service("feedbackService",
        function($http, apiRoot) {

            function submitFeedback(feedback) {
                return $http.post(apiRoot.getRoot() + '/services/user/feedback', {
                    feedback: feedback
                });
            }

            return({
                submitFeedback: submitFeedback
            });
        }
    );
})(angular, AnnoTree);
