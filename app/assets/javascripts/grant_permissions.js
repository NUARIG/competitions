// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//
//= require select2
$(document).ready(function() {
  $('select#grant_permission_user_id').select2({
    placeholder: "Choose a person",
    minimumInputLength: 1,
    allowClear: true
  });
});