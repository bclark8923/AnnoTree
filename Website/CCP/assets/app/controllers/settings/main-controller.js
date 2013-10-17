(function(ng, app){
    "use strict";

    app.controller("settings.MainController", function(
        $scope, requestContext
    ) {
        var renderContext = requestContext.getRenderContext("standard.settings");
        $scope.subview = renderContext.getNextSection();
        $scope.$on("requestContextChanged", function() {
            if (!renderContext.isChangeRelevant()) {
               return;
            }
            $scope.subview = renderContext.getNextSection();
        });

        $("#loadingScreen").hide();
    });
})(angular, AnnoTree);
