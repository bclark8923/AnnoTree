// Create an application module for our demo.
var AnnoTree = angular.module( "AnnoTree", ['ngCookies'] );

AnnoTree.run(function($rootScope, $templateCache) {
          $rootScope.$on('$viewContentLoaded', function() {
                         $templateCache.removeAll();
                         });
          });

// Configure the routing. The $routeProvider will be automatically injected into 
// the configurator.
AnnoTree.config(
	function( $routeProvider, $locationProvider, $httpProvider ){

		// Typically, when defining routes, you will map the route to a Template to be 
		// rendered; however, this only makes sense for simple web sites. When you are 
		// building more complex applications, with nested navigation, you probably need 
		// something more complex. In this case, we are mapping routes to render "Actions" 
		// rather than a template.

		//$locationProvider.html5Mode(true);

		$routeProvider
			.when(
				"/authenticate/login",
				{
					action: "authenticate.login"
				}
			)
      .when(
          "/authenticate/signUp",
          {
              action: "authenticate.signup"
          }
      )
      .when(
          "/authenticate/requestPassword",
          {
              action: "authenticate.requestPassword"
          }
      )
      .when(
          "/authenticate/resetPassword",
          {
              action: "authenticate.resetPassword"
          }
      )
			.when(
				"/app",
				{
					action: "standard.forest"
				}
			)
			.when(
				"/app/:treeID",
				{
					action: "standard.tree.leaves"
				}
      )
      .when(
          "/app/:treeID/:leafID",
          {
              action: "standard.tree.leaf"
          }
      )
      .when(
          "/forestFire",
          {
              action: "standard.forestFire"
          }
      )
			.otherwise(
				{
					redirectTo: "/authenticate/login"
				}
			)
		;
  	
  		$httpProvider.responseInterceptors.push( interceptor );

	}
);

AnnoTree.factory('apiRoot', function() {
	return {
		getRoot: function() {
			return "http://23.21.235.254:3000";
		}
	}
});

AnnoTree.directive('postRender', function($timeout) {
  return  { 
    link: function(scope, elm, attrs) { 
      $timeout( 
        function() {
          window.Gumby.init() 
        }, 0
      );
    }
  }
});

var interceptor = function( $q, $location ) {
  return function( promise ) {
 
    // convert the returned data using values passed to $http.get()'s config param
    var resolve = function( value ) {
    	if(value.redirect) {
			  $location.path("/authenticate/login");
		    return;
    	}
    };
 
    var reject = function( reason ) {
    	if(reason.status == 401 && reason.data.error == 0) {
  			$location.path("/authenticate/login");
  			return;
    	}
    };
 
    // attach our actions
    promise.then( resolve, reject );
 
    // return the original promise
    return promise;
  }
};
 
AnnoTree.filter('threeColumnFilter', function() {
    return function(arrayLength) {
        arrayLength = Math.ceil(arrayLength);
        var arr = new Array(arrayLength), i = 0;
        for (; i < arrayLength; i++) {
            arr[i] = i;
        }
        return arr;
    };
});