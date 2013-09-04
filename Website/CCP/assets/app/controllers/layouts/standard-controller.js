(function(ng, app){
    "use strict";

    app.controller("layouts.StandardController",
        function($scope, $rootScope, $location, authenticateService, requestContext, feedbackService, constants) {
            var feedbackDefaultMessage = 'Let us know what features you want to see next, any problems you have while using AnnoTree, or anything else you feel that we should be aware of.';

            function loadUserData() {
                var promise = authenticateService.getUserInfo();
                promise.then(
                    function(response) {
                        $scope.user = response.data;
                    },
                    function(response) { 
                        //TODO: what to do on error? 
                        // there should never be a failure unless services are down
                    }
                ); 
            }

            function setFeedbackError(msg) {
                $scope.feedbackErrorText = msg;
                $scope.feedbackErrorMessage = true;
            }

            $scope.logout = function() {
                var promise = authenticateService.logout();

                promise.then(
                    function(response) {
                        $location.path('authenticate/login');
                    },
                    function(response) { 
                        //TODO: what to do when logout fails?
                        $location.path('authenticate/login');
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
                $("#feedbackModal").modal('show');
                $scope.feedbackText = '';
                $scope.feedbackErrorMessage = false;
                $scope.feedbackModalWorking = false;
                $scope.feedbackProvide = true;
                $scope.feedbackMessage = feedbackDefaultMessage;
            };

            $scope.submitFeedback = function() {
                var feedback = $scope.feedbackText;
                var formValid = $scope.feedbackForm.$valid;

                if (!formValid) {
                    setFeedbackError('Please provide feedback');
                } else {
                    $scope.feedbackModalWorking = true;
                    var promise = feedbackService.submitFeedback(feedback);

                    promise.then(
                        function(response) {
                            $scope.feedbackMessage = 'Thanks for submitting your feedback! We appreciate you taking the time to make AnnoTree better.';
                            $scope.feedbackProvide = false;
                            $scope.feedbackErrorMessage = false;
                            $scope.feedbackModalWorking = false;
                        },
                        function(response) {
                            if (response.status != 500  && response.status != 502) {
                                setFeedbackError(response.data.txt);
                            } else {
                                setFeedbackError(constants.servicesDown());
                            }
                            $scope.feedbackModalWorking = false;
                        }
                    );
                }
            };

            var renderContext = requestContext.getRenderContext("standard");
            $scope.subview = renderContext.getNextSection();
            $scope.$on("requestContextChanged", function() {
                if (!renderContext.isChangeRelevant()) {
                    return;
                }
                $scope.subview = renderContext.getNextSection();
                $scope.userSettingsBox = false;
            });
    
            $scope.feedbackModalWorking = false;
            $scope.userSettingsBox = false;
            $scope.feedbackErrorMessage = false;
            $scope.feedbackProvide = true;
            $scope.feedbackMessage = feedbackDefaultMessage;
            $scope.setWindowTitle('AnnoTree');

            $scope.$evalAsync(loadUserData());
            
            if ($location.path() == "/app/ft") {
                $("#helpModal").modal('show');
            }
        }
    );
})(angular, AnnoTree);
