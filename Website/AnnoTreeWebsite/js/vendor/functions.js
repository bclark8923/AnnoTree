

$( document ).ready(function() {
    $(function() {
      $( "#newLeavesBranch, #completedBranch, #inProgressBranch" ).sortable({
        revert: true,
        connectWith: ".connectedSortable",
        placeholder: "card-col-placeholder",
        start: function(e, ui){
            ui.placeholder.height(ui.item.height());
        }
      }).disableSelection();
      /*$( ".branchColumnLeaves" ).draggable({
        connectToSortable: ".branchColumnLeaves",
        revert: "invalid"
      });
      $( "ul, li" ).disableSelection();*/
    });

    $(function(){
 
      _offsetY = 0;
      _startY = 0;
   
      // To resize the height of the scroll scrubber when scroll height increases. 
      setScrubberHeight();
   
      var contentDiv = document.getElementById('updateContainer');
      scrubber = $('#updateScollScrubber');
      scrollHeight = $('#updateScollBar').outerHeight();
      contentHeight = $('#updateContent').outerHeight();
      scrollFaceHeight = scrubber.outerHeight();
   
      initPosition = 0;
      initContentPos = $('#updateHolder').offset().top;
      // Calculate the movement ration with content height and scrollbar height
      moveVal = (contentHeight - scrollHeight)/(scrollHeight - scrollFaceHeight);
   
      $("#updateContainer").mouseenter(function() {
          // Enable Scrollbar only when the content height is greater then the view port area.
          if(contentHeight > scrollHeight) {
              // Show scrollbar on mouse over
              scrubber.fadeToggle("fast");
              scrubber.bind("mousedown", onMouseDown);
          }
   
      }).mouseleave(function() {
   
          if(contentHeight > scrollHeight) {
              // Hide Scrollbar on mouse out.
              scrubber.fadeToggle("slow");
              $('#updateHolder').unbind("mousemove", onMouseMove); 
                scrubber.unbind("mousedown", onMouseDown);
          }
      });
   
      function onMouseDown(event) {
          $('#updateHolder').bind("mousemove", onMouseMove);
          $('#updateHolder').bind("mouseup", onMouseUp);
          _offsetY = scrubber.offset().top;
          _startY = event.pageY + initContentPos;
          // Disable the text selection inside the update area. Otherwise the text will be selected while dragging on the scrollbar.
          contentDiv.onselectstart = function () { return false; } // ie
          contentDiv.onmousedown = function () { return false; } // mozilla
      }
   
      function onMouseMove(event) {
   
          // Checking the upper and bottom limit of the scroll area
          var offset = scrubber.offset();
          if(
              (offset.top >= initContentPos) && (offset.top < (initContentPos + scrollHeight - scrollFaceHeight))) {
   
                  scrubber.css({top: (scrollHeight-scrollFaceHeight-1)});
                  $('#updateContent').css({top: (scrollHeight - contentHeight + initPosition)});
              }
   
              $('#updateHolder').trigger('mouseup');
   
      }
   
      function onMouseUp(event) {
          $('#updateHolder').unbind("mousemove", onMouseMove);
          contentDiv.onselectstart = function () { return true; } // ie
          contentDiv.onmousedown = function () { return true; } // mozilla
      }
   
      function setScrubberHeight() {
          cH = $('#updateContent').outerHeight();
          sH = $('#updateScollBar').outerHeight();
   
          if(cH > sH) {
              // Set the min height of the scroll scrubber to 20
              if(sH / ( cH / sH ) < 20) {
                  $('#updateScollScrubber').css({height: 20 });
              }else{
                  $('#updateScollScrubber').css({height: sH / ( cH / sH ) });
              }
          }
      }
   
  });
});