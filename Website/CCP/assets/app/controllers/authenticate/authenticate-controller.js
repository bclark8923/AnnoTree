(function(ng, app) {
    "use strict";

    app.controller("authenticate.AuthenticateController",
        function($scope, requestContext) {
            var renderContext = requestContext.getRenderContext("authenticate");
            $scope.subview = renderContext.getNextSection();
            $scope.$on("requestContextChanged", function() {
                if (!renderContext.isChangeRelevant()) {
                    return;
                }
                $scope.subview = renderContext.getNextSection();
            });
            
            $scope.setWindowTitle("AnnoTree");
            $("#loadingScreen").hide();
        }
    );
})(angular, AnnoTree);
