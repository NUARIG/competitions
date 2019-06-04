Grant.FormBuilderUploadSetup = function(){
  $('[data-form_builder_upload]').each(function(){
    var clear_link        = $(this).find('[data-form_builder_upload_clear]');
    var file_input        = $(this).find('input[type=file]');
    var file_link         = $(this).find('[data-form_builder_upload_file_link]');
    var remove_file_input = $(this).find('[data-form_builder_remove_document]');
    //hide the upload input if there is currently a file_link
    if(file_link.size() != 0){
      file_input.hide();
    }
    clear_link.on( "click", function(){
      Grant.ClearUpload(file_input);
      file_link.hide();
      file_input.show();
      remove_file_input.val('1');
    });
    //handle adding a file to the input
    file_input.on("change", function(){
      remove_file_input.val('0');
    });
  });
};

/*
   For security reasons file upload inputs cannot have their values
   set. IE will not even allow setting the input to blank. This is
   the cleanest cross-browser workaround I know of.
*/
Grant.ClearUpload = function (e){
  if(e.size() !=0){
    e.wrap('<form>').closest('form').get(0).reset();
    e.unwrap();
  }
};
