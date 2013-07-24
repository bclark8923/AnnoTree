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
	  $("#submitEmail").click();
	  return false;
	});

	var buttonEnabled = true;
	$("#submitEmail").click(function () {
		var emailVar = $.trim($("#emailInput").val());
		if(emailVar.length > 0 && isEmail(emailVar) && buttonEnabled) {
			buttonEnabled = false;

			$("#emailInput").addClass('disabled');
			$("#submitEmail").addClass('disabled');
			$("emailInput").prop('disabled', true);

			var serializedData = {email: emailVar}
			// fire off the request to /form.php
		    var request = $.ajax({
		        url: "http://annotree.com/betasignup",
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
				$("#submitEmail").removeClass('disabled');
				$("emailInput").prop('disabled', false);
		    });

		    // callback handler that will be called on failure
		    request.fail(function (jqXHR, textStatus, errorThrown){
				buttonEnabled = true;
				$("#emailInput").removeClass('disabled');
				$("#submitEmail").removeClass('disabled');
				$("emailInput").prop('disabled', false);
		        // log the error to the console
		        alert('Sorry, our beta sign up is currently down. Please try again later.')
		    });
		} else {
			$("#validateError").show();
		}
	});

	function isEmail(email){
		return /^([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22))*\x40([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d))*$/.test(email);	
	}
});

