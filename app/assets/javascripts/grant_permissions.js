//= require select2
$(document).ready(function() {

  $userSelector = $('select#grant_permission_user_id')

  if ($userSelector.length) {
    $userSelector.select2({
      placeholder: "Email Address",
      minimumInputLength: 3,
      allowClear: true,
      ajax: {
        url: $userSelector.data('users-query-source'),
        dataType: 'json',
        type: "get",
        delay: 250,
        processResults: function(data) {
          return {
            results: $.map( data, function(user, index) {
              return { id: user.id, text: user.email }
            } )
          }
        },
        cache: true
      }
    });
  };
});
