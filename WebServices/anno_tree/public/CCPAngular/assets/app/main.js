
// Create an application module for our demo.
var AnnoTree = angular.module( "AnnoTree", [] );

AnnoTree.run(function($rootScope, $templateCache) {
          $rootScope.$on('$viewContentLoaded', function() {
                         $templateCache.removeAll();
                         });
          });

// Configure the routing. The $routeProvider will be automatically injected into 
// the configurator.
AnnoTree.config(
	function( $routeProvider, $locationProvider ){

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
					action: "standard.tree"
				}
            )
            .when(
                "/app/:treeID/:leafID",
                {
                    action: "standard.leaf"
                }
            )
			.when(
				"/pets/:categoryID/:petID",
				{
					action: "standard.pets.detail.background"
				}
			)
			.when(
				"/pets/:categoryID/:petID/diet",
				{
					action: "standard.pets.detail.diet"
				}
			)
			.when(
				"/pets/:categoryID/:petID/medical-history",
				{
					action: "standard.pets.detail.medicalHistory"
				}
			)
			.when(
				"/contact",
				{
					action: "standard.contact"
				}
			)
			.otherwise(
				{
					redirectTo: "/authenticate/login"
				}
			)
		;

	}
);

AnnoTree.factory('apiRoot', function() {
	return {
		getRoot: function() {
			return "http://23.21.235.254:3000";
		}
	}

});

