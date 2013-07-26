// Gumby is ready to go
Gumby.ready(function() {
    console.log('Gumby is ready to go...', Gumby.debug());

    // placeholder polyfil
    if(Gumby.isOldie || Gumby.$dom.find('html').hasClass('ie9')) {
        $('input, textarea').placeholder();
    }
});

// Oldie document loaded
Gumby.oldie(function() {
    console.log("This is an oldie browser...");
});

// Touch devices loaded
Gumby.touch(function() {
    console.log("This is a touch enabled device...");
});

// Document ready
$(function() {

    $('#submitSignUp').submit(function() {
      $(".submitEmail").click();
      return false;
    });

    var buttonEnabled = true;
    $(".submitEmail").click(function () {
        var emailVar = $.trim($("#emailInput").val());
        if(emailVar.length > 0 && isEmail(emailVar) && buttonEnabled) {
            buttonEnabled = false;

            $("#emailInput").addClass('disabled');
            $(".submitEmail").addClass('disabled');
            $("emailInput").prop('disabled', true);

            var serializedData = {email: emailVar}
            // fire off the request to /form.php
            var request = $.ajax({
                url: "/betasignup",
                type: "post",
                data: JSON.stringify(serializedData)
            });

            // callback handler that will be called on success
            request.done(function (response, textStatus, jqXHR){
                // log a message to the console
                $("#validateError").hide();
                $("#singupAppends").hide();
                $("#signupInfo").hide();
                $("#signupThanks").show();
                buttonEnabled = true;
                $("#emailInput").removeClass('disabled');
                $(".submitEmail").removeClass('disabled');
                $("emailInput").prop('disabled', false);
            });

            // callback handler that will be called on failure
            request.fail(function (jqXHR, textStatus, errorThrown){
                buttonEnabled = true;
                $("#emailInput").removeClass('disabled');
                $(".submitEmail").removeClass('disabled');
                $("emailInput").prop('disabled', false);
                $("#errorText").html('Sorry, our beta sign up is currently down. Please try again in a few minutes or email us at contact@annotree.com.');
                $("#validateError").show();
            });
        } else {
            $("#errorText").html('Please Enter a Valid Email');;
            $("#validateError").show();
        }
    });

    function isEmail(email){
        return /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/.test(email);
    }
});

