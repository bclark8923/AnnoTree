(function(ng, app) {
    "use strict";

    app.service("dataService",
        function() {
            // ----- Getters and Setters -----
            var reqPath = '';
            var user = null;
            
            function getReqPath() {
                return reqPath;
            }

            function setReqPath(path) {
                reqPath = path;
            }

            function setUser(u) {
                user = u;
            }

            function getUser() {
                return user;
            }

            return({
                setReqPath: setReqPath,
                getReqPath: getReqPath,
                setUser: setUser,
                getUser: getUser
            });
        }
    );
})(angular, AnnoTree);
