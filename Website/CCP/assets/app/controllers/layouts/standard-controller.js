(function( ng, app ){
    "use strict";

    app.controller(
        "layouts.StandardController",
        function( $scope, localStorageService, $location, authenticateService, requestContext, feedbackService, _ ) {


            // --- Define Controller Methods. ------------------- //

            // --- Define Scope Methods. ------------------------ //
            $scope.openUserScreen = function() {
                if ($('#userSettings').hasClass('active')) {
                    $('#userSettings').removeClass('active');
                } else {
                    $('#userSettings').addClass('active');
                }
            }

            $scope.logout = function() {

                var promise = authenticateService.logout();

                promise.then(
                    function( response ) {

                        $location.path('authenticate/login');

                    },
                    function( response ) {

                        $scope.openModalWindow( "error", "Sorry, the logout service is currently down." );

                    }
                );
            }
            $scope.openHelpModal = function() {
                if (settingsPane.isOpen) {
                    settingsPane.closeFast();
                }
                $("#helpModal").modal('show');
            }; 
            
            $scope.openFeedbackModal = function() {
                if (settingsPane.isOpen) {
                    settingsPane.closeFast();
                }
                $("#feedbackModal").modal('show');
            };

            $scope.closeFeedbackModal = function() {
                $("#feedbackModal").modal('hide');
                $scope.feedback = "";
                $scope.invalidFeedback = false;
                $scope.feedbackSubmitButton = true;
                $scope.feedbackArea = true;
                $scope.feedbackAbout = true;
                $scope.feedbackThanks = false;
            };

            $scope.submitFeedback = function() {
                var feedback = $scope.feedback;
                var formValid = $scope.feedbackForm.$valid;

                if (!formValid) {
                    $scope.invalidSubmitFeedback = true;
                    $("#invalidSubmitFeedback").html('Please enter feedback');
                } else {
                    var promise = feedbackService.submitFeedback(feedback);

                     promise.then(
                        function(response) {
                            //worked
                            //$scope.closeFeedbackModal();
                            $scope.feedbackThanks = true;
                            $scope.feedbackArea = false;
                            $scope.feedbackAbout = false;
                            $scope.feedbackSubmitButton = false;
                            $scope.invalidSubmitFeedback = false;
                        },
                        function(response) {
                            //didn't work
                            $scope.invalidSubmitFeedback = true;
                            var errorData = "Our feedback service is currently down, please try again later.";
                            var errorNumber = parseInt(response.data.error);
                            if(response.data.status != 401 && errorNumber != 0) {
                                //go to Fail Page
                                $location.path("/forestFire");
                            }
                            $("#invalidSubmitFeedback").html(errorData);
                        }
                    );
                }
            };

            // --- Define Controller Variables. ----------------- //

            // Get the render context local to this controller (and relevant params).
            var renderContext = requestContext.getRenderContext( "standard" );

            
            // --- Define Scope Variables. ---------------------- //

            // The subview indicates which view is going to be rendered on the page.
            $scope.subview = renderContext.getNextSection();

            // Get the current year for copyright output.
            $scope.copyrightYear = ( new Date() ).getFullYear();

            $scope.invalidFeedback = false;
            $scope.feedbackThanks = false;
            $scope.feedbackSubmitButton = true;
            $scope.feedbackArea = true;
            $scope.feedbackAbout = true;

            $scope.user = {name : localStorageService.get('username'), avatar : localStorageService.get('useravatar')};

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
            $scope.setWindowTitle( "AnnoTree" );
            if ($location.path() == "/app/ft") {
                $("#helpModal").modal('show');
            }
        }
    );
}) ( angular, AnnoTree );
