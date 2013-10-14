(function(ng, app){
    "use strict";

    app.controller("settings.UserController", function(
        $scope, $http, requestContext, apiRoot, constants
    ) {
        var renderContext = requestContext.getRenderContext("standard.settings.user");
        $scope.subview = renderContext.getNextSection();
        $scope.$on("requestContextChanged", function() {
            if (!renderContext.isChangeRelevant()) {
               return;
            }
            $scope.subview = renderContext.getNextSection();
        });
       
        $('[data-toggle="tooltip"]').tooltip({
            trigger: 'hover',
            placement: 'auto bottom',
            container: 'body',
            show: true
        }); 

        function validateEmail(email) { 
            var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            return re.test(email);
        }
        
        function setScroll() {
            var height = $(window).outerHeight();
            document.getElementById('settingsScroll').style.height = (height - 45) + 'px';
        }
        $(window).resize(setScroll);
        
        function isModifyUserErrors() {
            var error = false;
            var name = $scope.name;
            var email = $scope.email;
            
            if (!nameTest.test(name)) {
                $scope.modifyUserNameErrorText = 'Your name must contain at least one alphabetic character';
                $scope.modifyUserNameErrorMessage = true;
                error = true;
            } else {
                $scope.modifyUserNameErrorMessage = false;
            }

            if (!validateEmail(email)) {
                $scope.modifyUserEmailErrorText = 'Enter a valid email';
                $scope.modifyUserEmailErrorMessage = true;
                error = true;
            } else {
                $scope.modifyUserEmailErrorMessage = false;
            }
            
            return error;
        }

        $scope.modifyUser = function() {
            if (!isModifyUserErrors()) {
                $scope.modifyUserNameErrorMessage = false;
                $scope.modifyUserEmailErrorMessage = false;
                $scope.updateProfile = true;

                var promise = $http.put(apiRoot.getRoot() + '/services/user', {
                    name: $scope.name,
                    email: $scope.email || ''
                });

                promise.then(
                    function(response) {
                        $scope.$emit('userProfileUpdate', response.data);
                        $scope.updateProfile = false;
                    },
                    function(response) {
                        if (response.status != 500 && response.status != 502) {
                            var error = response.data.error;
                            var txt = response.data.txt;
                            if (error == 0 || error == 2) {
                                $scope.modifyUserNameErrorText = txt;
                                $scope.modifyUserNameErrorMessage = true;
                            } else {
                                $scope.modifyUserEmailErrorText = txt;
                                $scope.modifyUserEmailErrorMessage = true;
                            }
                        } else {
                            $scope.modifyUserNameErrorText = constants.servicesDown();
                            $scope.modifyUserNameErrorMessage = true;
                        }
                        $scope.updateProfile = false;
                    }
                );
            }
        }
        
        function setChangePasswordError(msg) {
            $scope.changePasswordErrorText = msg;
            $scope.changePasswordErrorMessage = true;
            $scope.updatePassword = false;
            $scope.password = '';
        }

        $scope.changePassword = function() {
            var password = $scope.password;
            var numberTest = new RegExp('[0-9]');
            var invalidCharTest = new RegExp('[^A-Za-z0-9!@#\$%\^7\*\(\)]');
            $scope.changePasswordSuccessMessage = false;

            if (!password) {
                setChangePasswordError('Please enter a password');
            } else if (password.length < 6) {
                setChangePasswordError('Password should contain at least six characters');
            } else if (!numberTest.test(password)) {
                setChangePasswordError('Password must contain at least one number');
            } else if (invalidCharTest.test(password)) {
                setChangePasswordError('Valid password characters are alphanumeric or !@#$%^&*()');
            } else {
                $scope.changePasswordErrorMessage = false;
                $scope.updatePassword = true;
                
                var promise = $http.put(apiRoot.getRoot() + '/services/user/password', {
                    password: $scope.password
                });

                promise.then(
                    function(response) {
                        $scope.updatePassword = false;
                        $scope.password = '';
                        $scope.changePasswordSuccessMessage = true;
                    },
                    function(response) {
                        if (response.status != 500 && response.status != 502) {
                            setChangePasswordError(response.data.txt);
                        } else {
                            setChangePasswordError(constants.servicesDown());
                        }
                    }
                );
            }
        }

        $scope.name = $scope.user && $scope.user.first_name + ' ' + $scope.user.last_name || 'Name';
        $scope.email = $scope.user && $scope.user.email || 'email';
        $scope.password = '';
        $scope.changePasswordErrorMessage = false;

        var nameTest = new RegExp('[A-Za-z]');
        $scope.modifyUserNameErrorMessage = false;
        $scope.modifyUserEmailErrorMessage = false;
        $scope.updatePassword = false;
        $scope.updateNotifications = false;
        $scope.updateProfile = false;
        $scope.changePasswordSuccessMessage = false;
        $scope.treeNotf = $scope.user && $scope.user.notf_tree_invite || '1';
        $scope.leafAssignNotf = $scope.user && $scope.user.notf_leaf_assign || '1';

        setScroll();
        $("#loadingScreen").hide();
    });
})(angular, AnnoTree);
