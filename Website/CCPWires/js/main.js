$(document).ready(function() {
  if(typeof SlidingPane == 'function') {
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
  }

  $("#trees").css('opacity', 1);
  $("#leafs").css('opacity', 1);
  $("#dashboardWrap").css('opacity', 1);
  $(".cardLarge").css('opacity', 1);

  $(".treeCard").click(function() {
    $("#trees").css('opacity', 0);
    setTimeout(function() {
      window.location.href = "tree.html";
    }, 250);
  })

  $("#leafBack").click(function() {
    $(".cardLarge").css('opacity', 0);
    $("#dashboardWrap").css('opacity', 0);
    setTimeout(function() {
      window.location.href = "tree.html";
    }, 250);
  })

  $(".leafCard").click(function() {
    $("#leafs").css('opacity', 0);
    $("#dashboardWrap").css('opacity', 0);
    setTimeout(function() {
      window.location.href = "leaf.html";
    }, 250);
  })
});