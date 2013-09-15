(function(ng, app){
    "use strict";

    app.controller("docs.MainController", function(
        $scope, requestContext
    ) {
        var renderContext = requestContext.getRenderContext("standard.docs");
        $scope.subview = renderContext.getNextSection();
        $scope.$on("requestContextChanged", function() {
            if (!renderContext.isChangeRelevant()) {
               return;
            }
            $scope.subview = renderContext.getNextSection();
        });
        
        $("#loadingScreen").hide();
        console.log('docs');
    });
})(angular, AnnoTree);
