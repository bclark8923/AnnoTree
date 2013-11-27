function logIn() {
    /*
    //DON'T DELETE THIS
    //This is used for testing style changes
    chrome.tabs.executeScript(null, {file: "canvas.js"});
    chrome.browserAction.setPopup({popup: ''});
    var bg = chrome.extension.getBackgroundPage();
    bg.loggedIn = true;
    window.close();
    /**/ 
    var email = $('#liEmail').val();
    var pass = $('#liPassword').val();
    var json = {
        loginEmail: email,
        loginPassword: pass
    }
    $.ajax({
        type: "POST",
        url: 'https://app.annotree.com/services/user/login/trees',
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
                bg.email = email;
                bg.emailp = pass;
                chrome.tabs.executeScript(null, {file: "canvas.js"});
                chrome.browserAction.setPopup({popup: ''});
                window.close();
            },
            500: function(res) {
                alert('AnnoTree is currently down. Please try again in a few minutes or contact us at support@annotree.com');
            }
        }
    });
}

document.addEventListener('DOMContentLoaded', function() {
    $('#errorText').hide();
    $('#login').show();
    $('#liEmail').focus();
    $("#loginBtn").click(function() {
        logIn();
    });
});

$(document).keypress(function(e) {
  if(e.which == 13) {
        logIn();
    }
});
