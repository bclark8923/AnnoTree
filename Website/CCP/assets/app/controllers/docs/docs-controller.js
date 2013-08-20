(function( ng, app ){

    "use strict";

    app.controller(
        "docs.HomeController",
        function( $scope, $cookies, $rootScope, $location, $timeout, $route, requestContext, forestService, _ ) {


            var renderContext = requestContext.getRenderContext( "standard.tree.docs" );
            $scope.subview = renderContext.getNextSection();

            $scope.$on(
                "requestContextChanged",
                function() {
                    if ( ! renderContext.isChangeRelevant() ) {
                   return;
                    }
                    $scope.subview = renderContext.getNextSection();

                }
            );

            $scope.setWindowTitle( "AnnoTree" );
            $("#loadingScreen").hide();
        }
    );

 })( angular, AnnoTree );
