
    function printArray(array) {
        for (var i = 0; i < array.length; i++) {
            $("#data").append(array[i] + '<br/>');
        }
    }
    
    function getData() {
        $("#data").html('');
        $("#d3Holder").empty();
        words = [];
        tweets = [];
        buildApp();
    }
    
    function parseData(tweets) {
        //var words = [];
        for (var i = 0; i < tweets.length; i++) {
          tweetWords = tweets[i].split(' ');
          // Do something with element i.
          for (var j = 0; j < tweetWords.length; j++) {
            words.push(tweetWords[j]);
          }
        }
        return words;
    }
    
    function buildScreen(data, newFont) {
        font = newFont;
        d3.layout.cloud().size([600, 300])
          .words(data.map(function(d) {
            return {text: d, size: 10 + Math.random() * 90};
          }))
          .rotate(function() { return ~~(Math.random() * 2) * 90; })
          .font(newFont)
          .fontSize(function(d) { return d.size; })
          .on("end", draw)
          .start();
    }
    
    $("#getData").on('click', getData);
    
    function CallAPI(url, username) {
        if(!username) { username = "gwcge" }      
        var returndata = "";
        var apiCall = "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=" + username;// + "&count=5";
        var request = $.ajax({
            url: url + "?user_name=" + username,
            type: "get",
            async: false
        });
    
        request.success(function (data){
            // log a message to the console
            //alert("Hooray, it worked!");
            returndata = data;
        });
        
        request.fail(function (data){
            // log a message to the console
            alert("Uh oh something went wrong!");
            returndata = "Broken :(";
        });
        var tweets = [];
        $.each(JSON.parse(returndata), function(i, obj) {
            tweets.push(obj['text']);
        });
        //return returndata;
        
        return tweets;
    }
    
    var fill = d3.scale.category20();

    function draw(words) {
        d3.select("#d3Holder").append("svg")
            .attr("width", 600)
            .attr("height", 300)
          .append("g")
            .attr("transform", "translate(300,180)")
          .selectAll("text")
            .data(words)
          .enter().append("text")
            .style("font-size", function(d) { return d.size + "px"; })
            .style("font-family", font)
            .style("fill", function(d, i) { return fill(i); })
            .attr("text-anchor", "middle")
            .attr("transform", function(d) {
              return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
            })
            .text(function(d) { return d.text; });
    }