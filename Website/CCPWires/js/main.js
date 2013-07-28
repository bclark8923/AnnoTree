$(document).ready(function() {
      settingsPane = new SlidingPane({
        id: 'mobileDashboard',
        targetId: 'containWrapper',
        side: 'left',
        width: 240,
        duration: 0.75,
        timingFunction: 'ease',
        shadowStyle: '0px 0px 0px #000'
      });
    
  $("#paneToggle").click(function() {
    if($("#mobileDashboard").length) {
        settingsPane.toggle();
    }
  });
});