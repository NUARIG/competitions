  Grant.FormBuilderSurvey = {
  init:function(){
    var that = this;
    that.initAlwaysEditableFields();
    var orig_insert = window.NestedFormEvents.prototype.insertFields;

    //see https://github.com/ryanb/nested_form/wiki/How-To:-Render-nested-fields-inside-a-table
    window.NestedFormEvents.prototype.insertFields = function(content, assoc, link) {
      if ($(link).data('location') == "parent"){
        var $tr = $(link).parents($(link).data('target'));
        return $(content).appendTo($tr);
      }else{
        return orig_insert(content, assoc, link)
      }
    }

    // $("fieldset.form_builder_section_fieldset").each(function(){
    //   that.allow_follow_up_dependency(this);
    // });

    $("fieldset.form_builder_question_fieldset").each(function(){
      that.answers_dependency(this);
      that.is_cycle_date_dependency(this);
      that.standard_answer_set_dependency(this);
      // that.copy_in_follow_up_dependency(this);
    });

    //see https://github.com/ryanb/nested_form/blob/0.3.2/README.md#javascript-events
    $(document).on('nested:fieldAdded', function(event){
      $("fieldset.form_builder_question_fieldset", event.field).each(function(){
        $('[data-behavior="select2"]', this).each(function () {
          $(this).select2({
            placeholder: $(this).data('placeholder'),
            triggerChange: true
          });
        });
        that.answers_dependency(this);
        that.is_cycle_date_dependency(this);
        that.standard_answer_set_dependency(this);
        // that.copy_in_follow_up_dependency(this);
      });
      // $("fieldset.form_builder_section_fieldset", event.field).each(function () {
      //   that.allow_follow_up_dependency(this);
      // });
    });
  },
  initAlwaysEditableFields: function () {

    $('.update-fields-btn').click(function (e) {
      var $btn = $(this);
      e.preventDefault();
      var $inputs = $('.field-always-editable');
      var data_hash = {};
      $inputs.each(function() {
        data_hash[$(this).attr('name')] = $(this).val();
      });
      var url = $('#survey_update_fields_url').val();
      $.ajax(url, {data: data_hash, type: "PUT"}).done(function () {
        $btn.siblings('.fail_msg').hide();
        $btn.siblings('.success_msg').html('Saved').show().delay(500).fadeOut('slow');
      }).fail(function (jqXHR) {
        $btn.siblings('.fail_msg').html('Failed to save: ' + jqXHR.responseText).show();
      });
    });
  },
  answers_dependency:function(scope){
    Grant.dependency(
      $(".form_builder_question_response_type", scope),
      $(".form_builder_answers_table", scope),
      function(){
        return $(".form_builder_question_response_type option:selected", scope).text() == "Multiple Choice - Pick One";
      },
      function(){
        $('a.remove_nested_fields[data-association="answers"]', scope).click(); // remove entered answers
      }
    );
  },
  is_cycle_date_dependency:function(scope){
    Grant.dependency(
      $(".form_builder_question_response_type", scope),
      $(".form_builder_question_is_cycle_date", scope),
      function(){
        return ($(".form_builder_question_response_type option:selected", scope).text() == "Date w/ Optional Time"
            || $(".form_builder_question_response_type option:selected", scope).text() == "Partial Date")
      },
      function(){
        $("select.form_builder_question_is_cycle_date", scope).val('');
      }
    );
    Grant.dependency(
      $(".form_builder_question_is_cycle_date", scope),
      $(".form_builder_question_cycle_date_msg", scope),
      function(){
        return ($(".form_builder_question_response_type option:selected", scope).text() == "Partial Date"
          && $(".form_builder_question_is_cycle_date option:selected", scope).text() == "true");
      },
      function(){
      }
    );
  },
  standard_answer_set_dependency: function standard_answer_set_dependency(scope) {
    Grant.dependency(
      $(".form_builder_question_response_type", scope),
      $(".form_builder_question_std_answer_set", scope),
      function () {
        return $(".form_builder_question_response_type option:selected", scope).text() === "Standard Answer";
      },
      function () {
        $("select.form_builder_question_std_answer_set", scope).val('');
      }
    );
  },
  // copy_in_follow_up_dependency: function copy_in_follow_up_dependency(question_scope) {
  //   var section_scope = $(question_scope).closest('.form_builder_section_fieldset').find('.section_table');
  //   Grant.dependency(
  //     // $(".form_builder_section_allow_follow_up", section_scope),
  //     $(".form_builder_question_use_baseline_value", question_scope),
  //     function () {
  //       return $("input.form_builder_section_allow_follow_up", section_scope)[0].checked
  //     },
  //     function () {
  //       $("input.form_builder_question_use_baseline_value", question_scope)[0].checked = false;
  //     }
  //   );
  // },
  // allow_follow_up_dependency: function allow_follow_up_dependency(scope) {
  //   Grant.dependency(
  //     $(".form_builder_section_repeatable", scope),
  //     $(".form_builder_section_allow_follow_up", scope).closest('tr'),
  //     function () {
  //       return $("input.form_builder_section_repeatable", scope)[0].checked
  //     },
  //     function () {
  //       $("input.form_builder_section_allow_follow_up", scope)[0].checked = false;
  //       $("input.form_builder_section_allow_follow_up", scope).trigger('change');
  //     }
  //   );
  // }
}
