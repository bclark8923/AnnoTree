(function( ng, app ){

    "use strict";

    app.controller(
        "authenticate.AuthenticateController",
        function( $scope, requestContext, authenticateService, _ ) {


            var renderContext = requestContext.getRenderContext( "authenticate" );

            $scope.isLoading = true;
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
            $('#signUpModal').modal('show');
        }
    );
 })( angular, AnnoTree );
