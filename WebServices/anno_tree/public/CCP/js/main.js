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
	console.log("Oldie");
});

// Document ready
$(document).ready(function() {
  var width = 80;
  settingsPane = new SlidingPane({
    id: 'mobileOptions',
    targetId: 'wrapper',
    side: 'right',
    width: 240,
    duration: 0.75,
    timingFunction: 'ease',
    shadowStyle: '0px 0px 0px #000'
  });

  $("#paneToggle").click(function() {
    settingsPane.toggle()
  });
});

