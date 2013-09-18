(function(ng, app) {
    "use strict";

    app.controller("tree.LeafController", function(
        $scope, $location, $http, $timeout, apiRoot, constants, dataService
    ) {
        $scope.$on('showLeaf', function(evt, leafID) {
            $location.path("app/" + $scope.tree.forest_id + "/" + $scope.tree.id + "/" + $scope.activeBranch.id + '/' + leafID);
            $scope.leafCommentErrorMessage = false;
            $scope.leafRenameShow = false;
            var promise = $http.get(apiRoot.getRoot() + '/services/leaf/' + leafID);
            $scope.user = dataService.getUser();
            promise.then(
                function(response) {
                    $scope.leaf = response.data;
                    for (var i = 0; i < $scope.leaf.annotations.length; i++) {
                        $scope.leaf.annotations[i].created_at = parseDate($scope.leaf.annotations[i].created_at.substring(0,10));
                    }
                    $('#leafModal').appendTo('body').modal('show');
                    if ($scope.leaf.annotations.length == 0) {
                        $scope.annotationCarousel = false;
                    } else if ($scope.leaf.annotations.length == 1) {
                        $scope.annotationCarousel = true;
                        $scope.showCarouselIndicators = false;
                    } else {
                        $scope.annotationCarousel = true;
                        $scope.showCarouselIndicators = true;
                    }
                },
                function(response) {} //TODO: what to do on failure?
            );
        });

        function parseDate(input) {
            var parts = input.split('-');
            return new Date(parts[0], parts[1]-1, parts[2]);
        }

        $scope.openUploadAnnotationModal = function() {
            $scope.uploadAnnotationWorking = false;
            $scope.uploadAnnotationErrorMessage = false;
            resetUploadAnnotation();
            $('#uploadAnnotationModal').appendTo('body').modal('show');
        } 
        
        function setUploadAnnotationError(msg) {
            $scope.uploadAnnotationErrorText = msg;
            $scope.uploadAnnotationErrorMessage = true;
            $scope.uploadAnnotationWorking = false;
        }

        function resetUploadAnnotation() {
            $('#newAnnotation').replaceWith($('#newAnnotation').clone());
            $('#annotationName').html('No file selected'); 
            $("#newAnnotation").change(function() {
               var file = $('#newAnnotation').val().replace(/C:\\fakepath\\/i, '');
                if (file == '') {
                    file = 'No file selected';
                }
                $('#annotationName').html(file);
            });
        }

        function sendAnnotation() {
            var annotationImageElement = document.getElementById('newAnnotation');
            var files = annotationImageElement.files;
            var fd = new FormData();
            fd.append("uploadedFile", files[0]);
            
            var xhr = new XMLHttpRequest();

            xhr.addEventListener("load", uploadComplete, false);
            xhr.addEventListener("error", uploadFailed, false);
            xhr.addEventListener("abort", uploadCanceled, false);
            xhr.open("POST", apiRoot.getRoot() + "/services/" + $scope.leaf.id + "/annotation");
            xhr.send(fd);
        }
        
        function uploadComplete(evt) {
            if (this.status == 415 || this.status == 406) {
                setUploadAnnotationError("Only images can be uploaded at this time");
            } else if (this.status == 413) {
               setUploadAnnotationError("Image is too large.  Only images less then 10MB may be uploaded at this time.");
            } else {
                var annotationObject = jQuery.parseJSON(evt.target.responseText);
                annotationObject.created_at = parseDate(annotationObject.created_at.substring(0, 10));
                $scope.leaf.annotations.push(annotationObject);
                $scope.$emit('newAnnotation', $scope.leaf.id, annotationObject.path);

                $scope.$apply();
                $timeout(function() {
                    if ($scope.leaf.annotations.length == 1) {
                        $scope.annotationCarousel = true;
                        $scope.showCarouselIndicators = false;
                    } else if ($scope.leaf.annotations.length == 2) {
                        $scope.showCarouselIndicators = true;
                    }
                }, 0, true);

                $('#uploadAnnotationModal').modal('hide');
            }
        }

        function uploadFailed(evt) {
            $location.path("/forestFire");
        }

        function uploadCanceled(evt) {
            $location.path("/forestFire");
        } 

        $scope.uploadAnnotation = function() {
            var annotationElement = document.getElementById('newAnnotation');
            if (annotationElement.files.length == 0) {
                setUploadAnnotationError("Please select an image.");
            } else if (annotationElement.files[0].size > 10485760) {
               resetUploadAnnotation();
               setUploadAnnotationError("Image is too large. Only images less then 10MB may be uploaded at this time");
            } else { 
                $scope.uploadAnnotationWorking = true;
                sendAnnotation();
            }
        }

        function setLeafCommentError(msg) {
            $scope.leafCommentErrorText = msg;
            $scope.leafCommentErrorMessage = true;
            $('#newComment').prop('disabled', false);
        }
        
        $scope.addLeafComment = function() {
            $('#newComment').prop('disabled', true);
            var comment = $scope.leafComment.comment;
            if (!comment) {
                setLeafCommentError("You didn't write a comment!");
            } else {
                var leafID = $scope.leaf.id;
                var promise = $http.post(apiRoot.getRoot() + '/services/comments/leaf/' + $scope.leaf.id, {
                    comment: comment
                });

                promise.then(
                    function(response) {
                        $scope.leaf.comments = (response.data.comments);
                        $scope.leafComment.comment = '';
                        $('#newComment').prop('disabled', false);
                    },
                    function(response) {
                        if (response.status != 500 && response.status != 502) {
                            setLeafCommentError(response.data.txt);
                        } else {
                            setLeafCommentError(constants.servicesDown());
                        }
                    }
                );
            }
        }
    
        $scope.showLeafRename = function() {
            $scope.leafRenameErrorMessage = false;
            $scope.leafRenameShow = true;
            $scope.leafRenameText = $scope.leaf.name;
        }
        
        function setLeafRenameError(msg) {
            $scope.leafRenameErrorText = msg;
            $scope.leafRenameErrorMessage = true;
        }

        $scope.renameLeaf = function() {
            var leafName = $scope.leafRenameText;
            var leafID = $scope.leaf.id;

            if (!leafName) {
                setLeafRenameError("Please enter a leaf name");
            } else if (!nameTest.test(leafName)) {
                setLeafRenameError("A leaf name must include at least one alphanumeric character");
            } else {
                var promise = $http.put(apiRoot.getRoot() + '/services/leaf/' + leafID, {
                    name: leafName
                });

                $scope.leaf.name = leafName;
                $scope.leafRenameShow = false;
                setScroll();
                $scope.$emit('leafRename', $scope.leaf.id, leafName, $scope.leaf.branch_id);

                promise.then(
                    function(response) {}, //TODO: handle success and failure
                    function(response) {}
                );
            }
        }

        $scope.closeAnnotationModal = function() {
            $('#annotationModal').remove();
        }

        $scope.openAnnotationModal = function(path) {
            var width = $(window).outerWidth() - 20;
            var height = $(window).outerHeight() - 20;
            var sizeLimits = 'max-width:' + width + 'px;max-height:' + height + 'px';
            var modal = $('<div id="annotationModal" class="valign" onclick="$(\'#annotationModal\').remove()"></div>');
            var img = $('<div><img src="' + path + '" style="' + sizeLimits + '" /></div>');
            modal.append(img);
            $('body').append(modal);
        }

        $scope.openDeleteLeaf = function() {
            $scope.deleteLeafWorking = false;
            $('#deleteLeafCallbackModal').appendTo('body').modal('show');
        }

        $scope.deleteLeaf = function() {
            var leafID = $scope.leaf.id;
            var promise = $http.delete(apiRoot.getRoot() + '/services/leaf/' + leafID);
            $scope.deleteLeafWorking = true;
            $scope.$emit('leafDelete', $scope.leaf.id, $scope.leaf.branch_id);

            promise.then(
                function(response) {
                    $('#deleteLeafCallbackModal').modal('hide');
                    $('#leafModal').modal('hide');
                },
                function(response) {} // TODO: handle failure
            );
        }

        function setScroll() {
            $timeout(function() {
                if ($(window).outerWidth() > 767) {
                    var height = $(window).outerHeight();
                    var multiplier = 0;
                    if ($scope.leaf !== undefined) {
                        multiplier = Math.floor($scope.leaf.name.length / 100);
                    }
                    var calc = height - 310 - (multiplier * 26);
                    if (calc < 400) calc = 400;
                    $('#commentsWrapper').css('max-height', calc);
                } else {
                    $('#commentsWrapper').css('max-height', 400);
                }
                $('#commentsWrapper').scrollTop(99999999);
            }, 0);
        }

        $(window).resize(setScroll);
        
        $scope.$watch('leaf.comments', function() {
            setScroll();
        });

        $('#leafModal').on('hide.bs.modal', function() {
            $scope.$emit('hideLeaf');
        });
        
        $('#leafModal').on('hidden.bs.modal', function() {
            $('#leafModal').appendTo('#leafModalsPage');
        })
       
        $('#uploadAnnotationModal').on('hidden.bs.modal', function() {
            $('#uploadAnnotationModal').appendTo('#leafModalsPage');
        }); 
        
        $('#deleteLeafCallbackModal').on('hidden.bs.modal', function() {
            $('#deleteLeafCallbackModal').appendTo('#leafModalsPage');
        });         
        
        var nameTest = new RegExp('[A-Za-z0-9]');
        
        console.log('leaf');
    });
})(angular, AnnoTree);
