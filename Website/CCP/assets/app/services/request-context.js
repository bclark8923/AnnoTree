(function( ng, app ) {
    
    "use strict";

    // I provide information about the current route request.
    app.service(
        "requestContext",
        function( RenderContext ) {

            function getAction() {
                return( action );
            }

            function getNextSection( prefix ) {

                if ( ! startsWith( prefix ) )
                    return( null );

                if ( prefix === "" ) {

                    return( sections[ 0 ] );

                }

                var depth = prefix.split( "." ).length;

                if ( depth === sections.length ) {
                    return( null );
                }
                return( sections[ depth ] );
            }

            function getParam( name, defaultValue ) {
                if ( ng.isUndefined( defaultValue ) ) {
                    defaultValue = null;
                }
                return( params[ name ] || defaultValue );
            }

            /**
             *
             * @param name
             * @param defaultValue
             * @returns {*} int - param as an int, otherwise 0
             */
            function getParamAsInt( name, defaultValue ) {

                // Try to parse the number.
                var valueAsInt = ( this.getParam( name, defaultValue || 0 ) * 1 );

                // Check to see if the coersion failed. If so, return the default.
                if ( isNaN( valueAsInt ) ) {

                    return( defaultValue || 0 );

                } else {

                    return( valueAsInt );

                }

            }


            /**
             *
             * @param requestActionLocation
             * @param paramNames
             * @returns {RenderContext} the given action prefix and sub-set of route parms
             */
            function getRenderContext( requestActionLocation, paramNames ) {
                requestActionLocation = ( requestActionLocation || "" );
                paramNames = ( paramNames || [] );

                if ( ! ng.isArray( paramNames ) ) {
                    paramNames = [ paramNames ];
                }
                return(new RenderContext( this, requestActionLocation, paramNames ));
            }

            function hasActionChanged() {
                return( action !== previousAction );
            }

            function hasParamChanged( paramName, paramValue ) {
                if ( ! ng.isUndefined( paramValue ) ) {
                    return( ! isParam( paramName, paramValue ) );
                }
                if ((! previousParams.hasOwnProperty( paramName ) && params.hasOwnProperty( paramName )) ||
                     (previousParams.hasOwnProperty( paramName ) && !params.hasOwnProperty( paramName )))
                    return( true );
                return( previousParams[ paramName ] !== params[ paramName ] );

            }

            function haveParamsChanged( paramNames ) {

                for ( var i = 0, length = paramNames.length ; i < length ; i++ ) {
                    if ( hasParamChanged( paramNames[ i ] ) ) return( true );
                }
                return( false );
            }

            function isParam( paramName, paramValue ) {
                if (
                    params.hasOwnProperty( paramName ) &&
                    ( params[ paramName ] == paramValue )
                    ) {

                    return( true );

                }
                return( false );

            }

            function setContext( newAction, newRouteParams ) {
                previousAction = action;
                previousParams = params;
                action = newAction;
                sections = action.split( "." );
                params = ng.copy( newRouteParams );

            }
            function startsWith( prefix ) {

                if (! prefix.length || ( action === prefix ) || ( action.indexOf( prefix + "." ) === 0 )) {
                    return( true );
                }
                return( false );
            }

            var action = "";
            var sections = [];
            var params = {};
            var previousAction = "";
            var previousParams = {};


            return({
                getNextSection: getNextSection,
                getParam: getParam,
                getParamAsInt: getParamAsInt,
                getRenderContext: getRenderContext,
                hasActionChanged: hasActionChanged,
                hasParamChanged: hasParamChanged,
                haveParamsChanged: haveParamsChanged,
                isParam: isParam,
                setContext: setContext,
                startsWith: startsWith
            });


        }
    );

})( angular, AnnoTree );
