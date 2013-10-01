<?php 
    require_once('TwitterAPIExchange.php');

    $settings = array(
        'oauth_access_token' => "1487861966-mc9y6aPZt3Lmy7kDwmxFSp3Ddz1t499jjywyJ0R",
        'oauth_access_token_secret' => "wdADNVnPARl1E6t8SS7CPPWnxE7dw1dEiQWcPnXhCgA",
        'consumer_key' => "0ck3Ejn8KMmpr2kChD4kaw",
        'consumer_secret' => "dL7isVNO9YpqIb0LNE8e0gs4jdSAsEJUfzJXQnMqLe4"
    );
    
    $username = $_GET["user_name"];
    //echo $username;
    
    $apiCall = "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=" . $username . "&count=5";
    
    $url = 'https://api.twitter.com/1.1/statuses/user_timeline.json';
    $getfield = '?screen_name=' . $username . '&count=5';
    $requestMethod = 'GET';
    $twitter = new TwitterAPIExchange($settings);
    echo $twitter->setGetfield($getfield)
                 ->buildOauth($url, $requestMethod)
                 ->performRequest();  
             
    /*$aContext = array(
        'http' => array(
            'proxy' => 'http-proxy.corporate.ge.com',
            'request_fulluri' => true,
        ),
    );
    
    $cxContext = stream_context_create($aContext);*/

    //$file = file_get_contents($apiCall, False, $cxContext);
    //$file = file_get_contents($apiCall);
    /*
    function curl($url){
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
        $data = curl_exec($ch);
        $info = curl_getinfo($ch);
        //echo $info;
        curl_close($ch);
        return $data;
    }


    $file = curl($apiCall);
*/
    //$post_data = array("The first tweet" , "The second tweet", "Here is a longer tweet with some interesting words to change things up");
    
    //$file = json_encode(array('tweets' => $post_data));
    
    //echo $file;
?>