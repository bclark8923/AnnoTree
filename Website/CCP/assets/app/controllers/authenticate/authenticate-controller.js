(function( ng, app ){

    "use strict";

    app.controller(
        "authenticate.AuthenticateController",
        function( $scope, requestContext, authenticateService, _ ) {


            // --- Define Controller Methods. ------------------- //


            // --- Define Scope Methods. ------------------------ //


            // ...


            // --- Define Controller Variables. ----------------- //


            // Get the render context local to this controller (and relevant params).
            var renderContext = requestContext.getRenderContext( "authenticate" );

            
            // --- Define Scope Variables. ---------------------- //


            // I flag that data is being loaded.
            $scope.isLoading = true;

            // I hold the categories to render.

            // The subview indicates which view is going to be rendered on the page.
            $scope.subview = renderContext.getNextSection();
            

            // --- Bind To Scope Events. ------------------------ //


            // I handle changes to the request context.
            $scope.$on(
                "requestContextChanged",
                function() {

                    // Make sure this change is relevant to this controller.
                    if ( ! renderContext.isChangeRelevant() ) {

                        return;

                    }

                    // Update the view that is being rendered.
                    $scope.subview = renderContext.getNextSection();

                }
            );


            // --- Initialize. ---------------------------------- //


            // Set the window title.
            $scope.setWindowTitle( "AnnoTree" );

            $("#loadingScreen").hide();
            $('#signUpModal').modal('show');
        }
    );

 })( angular, AnnoTree );
