$(document).ready(function() {
  $('button.criterion-clear-button').click(function () {
    $clearButton = $(this)
    $criterionScoringContainer = $clearButton.closest('.criterion-scoring')
    $criterionScoringContainer.find('input:checked').prop('checked', false);
  });
});
