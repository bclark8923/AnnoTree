(function( ng, app ){
    "use strict";

    app.controller(
        "forest.LeafController",
        function( $scope, $cookies, $rootScope, $location, $timeout, $route, $routeParams,  requestContext, leafService, localStorageService, _ ) {


            // --- Define Controller Methods. ------------------- //
            function setScroll() {
               $timeout(function() {
                    var leafHeight = $('#leaf').height();
                    var commentArea = $('#commentArea').height() + 75;
                    $('#commentsWrapper').css('max-height', leafHeight - commentArea);
                    $('#commentsWrapper').scrollTop(99999999);
                }, 0); 
            }
            
            $scope.$watch('leaf.comments', function() {
                setScroll();
            });

            $scope.openViewLeafModal = function (tree) {
                $("#viewLeafModal").addClass('active');
                $rootScope.modifyTree = tree;
            }

            $scope.closeViewLeafModal = function () {
                $("#viewLeafModal").removeClass('active');
            }

            // I apply the remote data to the local view model.
            function annotationNameChange() {
                $("#newAnnotation").change(function() {
                   var file = $('#newAnnotation').val().replace(/C:\\fakepath\\/i, '');
                    if (file == '') {
                        file = 'No file selected';
                    }
                    $('#annotationName').html(file);
                });
            }

            function loadLeaf( leaf ) {
                var leafImage = "img/noImage.png";
                if (leaf.annotations.length > 0) {
                    leafImage = leaf.annotations[0].path
                } else {
                    var now = new Date();
                    var nowStr = '' + now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + (now.getDate());
                    leaf.annotations[0] = {
                        'path': 'img/noImage.png',
                        'created_at': nowStr,
                        'filename': 'No Image Found'
                    };
                }
                leaf.image = leafImage;
                for (var i = 0; i < leaf.annotations.length; i++) {
                    leaf.annotations[i].created_at = parseDate(leaf.annotations[i].created_at.substring(0,10));
                }
                $scope.leaf = leaf;
                localStorageService.add('activeLeaf', leaf.name);
                
                // Annotation carousel arrow shows
                $timeout(function() {
                    if (leaf.annotations.length == 1) {
                        $('#annotationCarousel').children('.carousel-control').hide();
                        if (leaf.annotations[0].path == 'img/noImage.png') {
                            $('#annotationAbout').hide();
                        }
                        $('#annotationCarousel').children('.carousel-indicators').hide();

                    } else {
                        $('#annotationCarousel').children('.carousel-control').show();
                        $('#annotationCarousel').children('.carousel-indicators').show();
                    }

                }, 0, true);
            }

            // I load the "remote" data from the server.
            function loadLeafData() {

                $scope.isLoading = true;

                var promise = leafService.getLeaf($routeParams.leafID);

                promise.then(
                    function( response ) {
                        $scope.isLoading = false;
                        loadLeaf( response.data );
                        $timeout(function() {$("#loadingScreen").hide(); }, 0);
                    },
                    function( response ) {

                        var errorData = "Our Create Tree Service is currently down, please try again later.";
                        var errorNumber = parseInt(response.data.error);
                        if(response.data.status == 406) {
                            switch(errorNumber)
                            {
                                case 1:
                                    errorData = "This user does not exist in our system. Please contact Us.";
                                    break;
                                default:
                                    //go to Fail Page
                                    $location.path("/forestFire");
                            }
                        } else if(response.data.status == 204) {
                            switch(errorNumber)
                            {
                                case 2:
                                    errorData = "This user currently has no forests."; // load a sample page maybe?
                                    break;
                                default:
                                    //go to Fail Page
                                    $location.path("/forestFire");
                            }
                        } else if(response.data.status != 401 && errorNumber != 0) {
                            //go to Fail Page
                            $location.path("/forestFire");
                        }
                    }
                );

            }
            
            function newAnnotation(leafID) {
                $scope.files = [];
                var annotationImageElement = document.getElementById('newAnnotation');
                var files = annotationImageElement.files;
                //console.log('files:', files)
                for (var i = 0; i < files.length; i++) {
                    $scope.files.push(files[i]);
                }

                var fd = new FormData();
                for (var i in $scope.files) {
                    fd.append("uploadedFile", $scope.files[i]);
                }
                var xhr = new XMLHttpRequest();

                //xhr.upload.addEventListener("progress", uploadProgress, false)
                xhr.addEventListener("load", uploadComplete, false);
                xhr.addEventListener("error", uploadFailed, false);
                xhr.addEventListener("abort", uploadCanceled, false);
                leafService.createAnnotation(leafID, fd, xhr);

                $scope.isLoading = false;
            }

            function parseDate(input) {
                var parts = input.split('-');
                return new Date(parts[0], parts[1]-1, parts[2]);
            }
            
            function updateRootScopeAnnotation(leafID, path) {
                for (var i = 0; i < $rootScope.leaves.length; i++) {
                    if ($rootScope.leaves[i].id == leafID) {
                        $rootScope.leaves[i].annotation = path;
                        break;
                    }
                }
            }

            function uploadComplete(evt) {
                /* This event is raised when the server send back a response */
                //alert(evt.target.responseText); 
                if (this.status == 415 || this.status == 406) {
                    var jsonResp = JSON.parse(this.response);
                    $("#invalidAnnotation").html("Only images can be uploaded at this time");
                    $("#invalidAnnotation").show();
                    $("#uploadAnnotationModalWorking").removeClass('active');
                } else if (this.status == 413) {
                   $("#invalidAnnotation").html("Image is too large. Only images less then 10MB may be uploaded at this time.");
                    $("#uploadAnnotationModalWorking").removeClass('active');
                } else {
                    var annotationObject = jQuery.parseJSON( evt.target.responseText );
                    annotationObject.created_at = parseDate(annotationObject.created_at.substring(0, 10));
                    if ($scope.leaf.annotations[0].path == 'img/noImage.png') {
                        $('#annotationAbout').show();
                        $scope.leaf.annotations[0] = annotationObject;
                    } else {
                        $scope.leaf.annotations.push(annotationObject);
                    }
                    updateRootScopeAnnotation($scope.leaf.id, annotationObject.path);
                    $("#invalidAnnotation").hide();
                    $scope.$apply();
                    $timeout(function() {
                        if ($scope.leaf.annotations.length == 1) {
                            $('#annotationCarousel').children('.carousel-control').hide();
                            $('#annotationCarousel').children('.carousel-indicators').hide();
                        } else {
                            $('#annotationCarousel').children('.carousel-control').show();
                            $('#annotationCarousel').children('.carousel-indicators').show();
                        }

                    }, 0, true);
                    $("#uploadAnnotationModalWorking").removeClass('active');
                    $('#uploadAnnotationModal').modal('hide');
                }
                $('#newAnnotation').replaceWith($('#newAnnotation').clone());
                $('#annotationName').html('No file selected');
                annotationNameChange();
            }

            function uploadFailed(evt) {
                /* This event is raised when the server send back a response */
                //alert(evt.target.responseText);
                //delete new leaf
                $location.path("/forestFire");
            }

            function uploadCanceled(evt) {
                /* This event is raised when the server send back a response */
                //alert(evt.target.responseText);
                //delete new leaf
                $location.path("/forestFire");
            } 
            // --- Define Scope Methods. ------------------------ //
            $scope.openUploadAnnotationModal = function() {
                $("#invalidAnnotation").hide();
                $('#newAnnotation').replaceWith($('#newAnnotation').clone());
                $('#annotationName').html('No file selected');
                annotationNameChange();
                $('#uploadAnnotationModal').modal('show');
            }

            $scope.openAnnotationModal = function(path, name) {
                $('#annotationImageDisplay').attr('src', path);
                $('#displayAnnotationName').html(name);
                $('#displayAnnotation').appendTo("body").modal('show');
            }

            $scope.addNewAnnotation = function() {
                var annotationElement = document.getElementById('newAnnotation');
                if (annotationElement.files.length == 0) {
                    $("#invalidAnnotation").html("Please select an image.");
                    $("#invalidAnnotation").show();
                } else if (annotationElement.files[0].size > 10485760) {
                   $("#invalidAnnotation").html("Image is too large. Only images less then 10MB may be uploaded at this time.");
                    $("#invalidAnnotation").show();
                    $('#newAnnotation').replaceWith($('#newAnnotation').clone());
                    $('#annotationName').html('No file selected');
                    annotationNameChange();
                } else { 
                    $("#uploadAnnotationModalWorking").addClass('active');
                    newAnnotation($scope.leaf.id);
                }
            }

            $scope.addLeafComment = function() {
                var formValid = $scope.leafCommentForm.$valid;
                var comment = $scope.leafComment.comment;
                if (!formValid) {
                    if (!comment) {
                        $('#leafCommentError').html("You didn't write a comment!");
                        $scope.leafCommentError = true;
                    }
                } else {
                    $('#newComment').prop('disabled', true);
                    var leafID = $scope.leaf.id;
                    var promise = leafService.addLeafComment(leafID, comment);

                    promise.then(
                        function( response ) {
                            $scope.isLoading = false;
                            $scope.leaf.comments = (response.data.comments);
                            $('#newComment').val('');
                            //setScroll();
                        },
                        function( response ) {
                            var errorData;
                            var errorNumber = parseInt(response.data.error);
                            if(response.data.status == 406) {
                                errorData = response.data;
                            } else if(response.data.status != 401 && errorNumber != 0) {
                                errorData = "Our service are experiencing issues currently. Please try again in a few minutes.";
                            }
                            $("#leafCommentError").html(errorData);
                        }
                    );
                    $('#newComment').prop('disabled', false);
                    $("#loadingScreen").hide();
                }
            }

            $scope.openModifyLeafModal = function () {
                $("#modifyLeafModal").modal('show');
                $rootScope.modifyLeaf = $scope.leaf;
                $rootScope.originalName = $scope.leaf.name;
            }

            $scope.cancelModifyLeafModal = function() {
                $rootScope.modifyLeaf.name = $rootScope.originalName;
                $scope.closeModifyLeafModal();  
            }

            $scope.closeModifyLeafModal = function () {
                $("#modifyLeafModal").modal('hide');
                $("#invalidModifyLeaf").html('');
                $rootScope.modifyLeaf = null;
                $scope.invalidModifyLeaf = false; 
                $("#loadingScreen").hide();
            }

            $scope.modifyLeafFn = function() {

                var leafName = $rootScope.modifyLeaf.name;
                var leafDescription = "NULL";
                var formValid = $scope.modifyLeafForm.$valid;
                var branchID = $rootScope.modifyLeaf.branch_id;
                var leafID = $rootScope.modifyLeaf.id;

                //validate form
                if(!formValid) {
                    $scope.invalidModifyLeaf = true;
                    if(!leafName) {
                        $("#invalidModifyLeaf").html("Please fill out a leaf name.");
                    } else {
                        //shouldn't happen
                        $("#invalidModifyLeaf").html("Please enter valid information.");
                    }
                } else {
                    //return;
                    var promise = leafService.updateLeaf(leafID, branchID, leafName, leafDescription);

                    promise.then(
                        function( response ) {

                            $scope.isLoading = false;
                            $scope.closeModifyLeafModal();

                        },
                        function( response ) {
                            var errorData = "Our Modify Leaf Service is currently down, please try again later.";
                            var errorNumber = parseInt(response.data.error);
                            if(response.data.status == 406) {
                                switch(errorNumber)
                                {
                                    case 0:
                                        errorData = "Please fill out all of the fields";
                                        break;
                                    case 1:
                                        errorData = "This user does not exist in our system. Please contact Us.";
                                        break;
                                    case 2:
                                        errorData = "The branch you attempted to add to no longer exists.";
                                        break;
                                    case 4:
                                        errorData = "Please enter a valid leaf name.";
                                        break;
                                    default:
                                        //go to Fail Page
                                        //$location.path("/forestFire");
                                }
                            } else if(response.data.status != 401 && errorNumber != 0) {
                                //go to Fail Page
                                //$location.path("/forestFire");
                                alert(errorData);
                            }
                            $("#invalidModifyLeaf").html(errorData);

                        }
                    );
                }
            }

            $scope.deleteCallback = function() {
                $("#deleteLeafCallbackModal").modal('show');
            }

            $scope.deleteLeaf = function() {
                //return;
                var leafID = $rootScope.modifyLeaf.id;
                var promise = leafService.deleteLeaf(leafID);

                promise.then(
                    function( response ) {

                        $scope.isLoading = false;
                        var indexPos = 0;
                        for (var i = 0; i < $rootScope.leaves.length; i++) {
                            if ($rootScope.leaves[i].id == leafID) {
                                $rootScope.leaves.splice(i, 1);
                                break;
                            }
                        }
                        $("#deleteLeafCallbackModal").modal('hide');
                        $scope.closeModifyLeafModal();
                        $location.path('/app/'+$routeParams.treeID);

                    },
                    function( response ) {
                        var errorData = "Our Modify Leaf Service is currently down, please try again later.";
                        var errorNumber = parseInt(response.data.error);
                        if(response.data.status == 406) {
                            switch(errorNumber)
                            {
                                case 0:
                                    errorData = "Please fill out all of the fields";
                                    break;
                                case 1:
                                    errorData = "This user does not exist in our system. Please contact Us.";
                                    break;
                                case 2:
                                    errorData = "The branch you attempted to add to no longer exists.";
                                    break;
                                case 4:
                                    errorData = "Please enter a valid leaf name.";
                                    break;
                                default:
                                    //go to Fail Page
                                    //$location.path("/forestFire");
                            }
                        } else if(response.data.status != 401 && errorNumber != 0) {
                            //go to Fail Page
                            //$location.path("/forestFire");
                            alert(errorData);
                        }
                        $("#invalidModifyLeaf").html(errorData);

                    }
                );
            }




            

            // ...


            // --- Define Controller Variables. ----------------- //


            // Get the render context local to this controller (and relevant params).
            var renderContext = requestContext.getRenderContext( "standard.tree.leaf" );

            
            // --- Define Scope Variables. ---------------------- //


            // I flag that data is being loaded.
            $scope.isLoading = true;

            // I hold the categories to render.
            $scope.leafImage = "";
            $scope.leafName = "";
            $scope.leafCommentError = false;

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
            //setScroll();
            // Load the "remote" data.
            loadLeafData();
        }
    );
})( angular, AnnoTree );
