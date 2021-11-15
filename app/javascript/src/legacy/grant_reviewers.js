$(document).on('turbo:load', function() {
  current_location = '/grants/#{@grant.to_param}/reviewers';
  $('.review').draggable({
    revert: 'invalid'
  });
  $('.review_list').droppable({
    hoverClass: 'hover',
    drop: function(event, ui) {
      if ($(ui.draggable).attr('id').split('_').length == 2) {
        reviewer_id = $(this).parent().attr('id').split('_').splice(-1)[0];

        $.ajax({
          type: "POST",
          url: $(ui.draggable).data("destinationUrl"),
          data: { "reviewer_id": reviewer_id },
          success: function(data) {
            window.location.href = current_location;
          },
          error: function() {
            window.location.href = current_location;
          }
        });
      }
    }
  })
});

$('.unassigned_submission').draggable({
  revert: "invalid"
});
$('.unassigned_submission_list').droppable({
  hoverClass: "hover",
  drop: function(event, ui) {
    $.ajax({
      type: "DELETE",
      url: $(ui.draggable).data("destinationUrl"),
      success: function(data) {
        window.location.href = current_location;
      },
      error: function() {
        window.location.href = current_location;
      }
    });
  }
});