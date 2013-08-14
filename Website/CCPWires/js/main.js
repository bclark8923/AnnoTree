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
      window.location.href = "tree-branches.html";
    }, 250);
  })

  $(".branchCard").click(function() {
    $("#trees").css('opacity', 0);
    setTimeout(function() {
      window.location.href = "tree-leaves.html";
    }, 250);
  })

  $(".leafCard").click(function() {
    $("#trees").css('opacity', 0);
    setTimeout(function() {
      window.location.href = "leaf.html";
    }, 250);
  })

  $("#leafBack").click(function() {
    $(".cardLarge").css('opacity', 0);
    $("#dashboardWrap").css('opacity', 0);
    setTimeout(function() {
      window.location.href = "tree-leaves.html";
    }, 250);
  })


  $('#carousel-example-generic').children('.carousel-control').show();

  if($('.carousel-inner .item:first').hasClass('active')) {
    $('#carousel-example-generic').children('.left.carousel-control').hide();
  } else if($('.carousel-inner .item:last').hasClass('active')) {
    $('#carousel-example-generic').children('.right.carousel-control').hide();
  }

  $('#carousel-example-generic').on('slid', '', function() {

    var $this = $(this);

    $this.children('.carousel-control').show();

    if($('.carousel-inner .item:first').hasClass('active')) {
      $this.children('.left.carousel-control').hide();
    } else if($('.carousel-inner .item:last').hasClass('active')) {
      $this.children('.right.carousel-control').hide();
    }

  });

  //draggable shit
  $( "#leafs > .container > .row" ).sortable({
      revert: true,
      cancel: ".ui-state-disabled"
  });

  $( "#leafs" ).draggable({
    connectToSortable: "#leafs",
    helper: "clone",
    revert: "invalid",
    handle: "div.cardName",
    cancel: ".ui-state-disabled"
  });
  $( "div" ).disableSelection();
});