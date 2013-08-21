function logIn() {
    /*
    //DON'T DELETE THIS
    //This is used for testing style changes
    chrome.tabs.executeScript(null, {file: "canvas.js"});
    chrome.browserAction.setPopup({popup: ''});
    var bg = chrome.extension.getBackgroundPage();
    bg.loggedIn = true;
    window.close();
    */
    var email = $('#liEmail').val();
    var pass = $('#liPassword').val();
    var json = {
        loginEmail: email,
        loginPassword: pass
    }
    $.ajax({
        type: "POST",
        url: 'https://ccp.annotree.com/services/user/login/trees',
        data: JSON.stringify(json),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        //TODO: catch 500
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
                bg.email = email;
                bg.emailp = pass;
                chrome.tabs.executeScript(null, {file: "canvas.js"});
                chrome.browserAction.setPopup({popup: ''});
                window.close();
            }
        }
    });
}

document.addEventListener('DOMContentLoaded', function() {
    $('#errorText').hide();
    $('#login').show();
    $("#loginBtn").click(function() {
        logIn();
    });
});
