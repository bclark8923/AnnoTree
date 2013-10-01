<!DOCTYPE html>

<html class="no-js"> 
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>GWC Workshop</title>
    <meta name="viewport" content="width=device-width">
  </head>

  <body style="text-align:center;">

	<!-- D3 here -->
    <div id="data"></div>
    <div id="d3Holder" style="text-align:center;"></div>
    
    <button id="getData">Get Data</button>
    <input type="text" id="username"></input>
    
    
    
	
	<!-- /container -->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
    <script src="/lib/d3/d3.js"></script>
    <script src="/d3.layout.cloud.js"></script>
    <script src="/support.js"></script>
     
    <script type='text/javascript'> 
        var words = [],
            tweets = [],
            usernmae = 'gwcge',
            font = "Impact";
        
        function buildApp() {
            username = $.trim($("#username").val());
            tweets = CallAPI('/twitter.php', username);
            //printArray(tweets);
            words = parseData(tweets);
            //printArray(words);
            buildScreen(words, "Helvetica");
        }
    </script>
  </body>
</html>
