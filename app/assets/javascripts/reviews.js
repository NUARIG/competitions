$(document).ready(function() {
  $('button.clear-button').click(function () {
    $clearButton = $(this)
    $scoringContainer = $clearButton.closest('.scoring')
    $scoringContainer.find('input:checked').prop('checked', false);
    return false
  });
});
