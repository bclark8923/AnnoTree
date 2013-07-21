$( document ).ready(function() {

	settingsPane = new SlidingPane({
	    id: 'pane',
	    targetId: 'wrapper',
	    side: 'right',
	    width: 240,
	    duration: 0.5,
	    timingFunction: 'ease',
	    shadowStyle: '0px 0px 0px #000'
	});
	
	$("#moreAll").click(function() {
	    settingsPane.toggle();
	});
	
	$(".paneLink").click(function() {
	    settingsPane.close();
	});
	
	$("#myCarousel").click(function() {
	    settingsPane.close();
	});

	$(".carouselLink").click(function() {
		$(".carouselLink").removeClass('active');
		$(this).addClass('active');
	})

	$(window).resize(function() {
	    if(window.innerWidth > 767 && settingsPane.isOpen) {
	      settingsPane.closeFast();
	    }
	});
});