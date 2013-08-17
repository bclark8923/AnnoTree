function logIn() {
    //alert("test");
    /*
    chrome.tabs.executeScript(null, {file: "canvas.js"});
    chrome.browserAction.setPopup({popup: ''});
    var bg = chrome.extension.getBackgroundPage();
    bg.loggedIn = true;
    window.close();
    */
    var json = {
        loginEmail: $('#liEmail').val(),
        loginPassword: $('#liPassword').val()
    }
    $.ajax({
        type: "POST",
        url: 'https://ccp.localhost/services/user/login/trees',
        data: JSON.stringify(json),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        statusCode: {
            401: function(res) {
                $('#errorText').html(res.responseJSON.txt);
                $('#errorText').show();
            },
            200: function(res) {
                $('#errorText').hide();
                var bg = chrome.extension.getBackgroundPage();
                bg.loggedIn = true;
                bg.trees = res.trees;
                chrome.tabs.executeScript(null, {file: "canvas.js"});
                chrome.browserAction.setPopup({popup: ''});
                //bg.hello();
                /*
                chrome.tabs.query({
                    active: true,
                    currentWindow: true
                }, 
                function(tabsArray) {
                    alert(tabsArray.length);
                });*/
                window.close();
            }
        }
    });
}

document.addEventListener('DOMContentLoaded', function() {
    /*
    var loggedIn = false;
    if (loggedIn) {
        var startBtn = document.getElementById('startBtn');
        startBtn.addEventListener('click', function() {
            /*alert('test');
            chrome.tabs.getCurrent(function(tab) {
                tabId = tab.id;
            });
            *
            chrome.tabs.executeScript(null, {file: "canvas.js"});
        });

        var screenshotBtn = document.getElementById('screenshot');
        screenshotBtn.addEventListener('click', function() {
            chrome.tabs.captureVisibleTab(null, {format: 'jpeg', quality: 100}, function(dataUrl) {
                chrome.tabs.create({
                    url: dataUrl
                });
            });
        });
    } else {
    */
    $('#errorText').hide();
    $('#login').show();
    $("#loginBtn").click(function() {
        logIn();
    });
});
