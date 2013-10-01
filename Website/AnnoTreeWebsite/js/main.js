function validateEmail(email) { 
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

function signup(input, errorDiv) {
    $('#' + input).prop('disabled', true);
    var email = $('#' + input).val();
    if (validateEmail(email)) {
        var serializedData = {email: email};

        var request = $.ajax({
            url: "/services/user/beta",
            type: "post",
            data: JSON.stringify(serializedData)
        });

        request.done(function(response, textStatus, jqXHR) {
            $('#' + input).prop('disabled', false);
            $('#' + errorDiv).css('display', 'none');
            window.location.href = "ThankYou.html";
        });

        request.fail(function(jqXHR, textStatus, errorThrown) {
            var responseText = 'Sorry, our beta sign up is currently down. Please try again in a few minutes or email us at contact@annotree.com.';
            if (jqXHR.status == 406) {
                responseText = jQuery.parseJSON(jqXHR.responseText).txt;
            }
            $('#' + errorDiv).html(responseText);
            $('#' + errorDiv).css('display', 'block');
            $('#' + input).prop('disabled', false);
        });
    } else {
        $('#' + errorDiv).html('Please enter a valid email address.');
        $('#' + errorDiv).css('display', 'block');
        $('#' + input).prop('disabled', false);
    }
}

$(document).ready(function() {
    $('#mainSignUpEmail').popover({placement: 'top', trigger: 'focus'});
    $('#mainSignUpEmail').popover('show');

    $("#firstSignUpForm").submit(function(evt) {
        signup('mainSignUpEmail', 'firstErrorField');
        evt.preventDefault();
        return false;
    });

    $("#secondSignUpForm").submit(function(evt) {
        signup('secondSignUpEmail', 'secondErrorField');
        evt.preventDefault();
        return false;
    });

    $("#thirdSignUpForm").submit(function(evt) {
        signup('thirdSignUpEmail', 'thirdErrorField');
        evt.preventDefault();
        return false;
    });
});
