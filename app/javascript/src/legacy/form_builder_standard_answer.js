Grant.FormBuilderStandardAnswer = {
    // initialization in response set views
    init_in_response_sets: function () {
        var that = this;
        that._init_std_answer_selects($('select.standard-answer'));
        $(document).on('cocoon:after-insert', function (e, inserted_item) {
            that._init_std_answer_selects($(inserted_item).find('select.standard-answer'));
        });
    },
    // initialization in standard answer set mgmt views
    init_in_standard_answer_sets: function () {
        var that = this;

        $('select.parent-standard-answers').each(function () {
            that._init_std_answer_set_parent_answer(this);
        });

        $(document).on('nested:fieldAdded', function (event) {
            var field = event.field;
            var $display_order_input = field.find('input.display-order');
            var prev_display_order = field.prevAll('tr.fields:first').find('input.display-order').val();
            $display_order_input.val(parseInt(prev_display_order) ? parseInt(prev_display_order) + 1 : 1);
            var parent_answer_dropdown = field.find('select.parent-standard-answers').get(0);
            that._init_std_answer_set_parent_answer(parent_answer_dropdown);
        });

        $('#form_builder_standard_answer_set_parent_id').on("change", function () {
            $('select.parent-standard-answers').each(function () {
                that._init_std_answer_set_parent_answer(this, true);
            });
        });
        this._validate_uniqueness_of_display_order();
        this._initAlwaysEditableFields();
    },

    /* private methods */

    _initAlwaysEditableFields: function () {
      $('.update-fields-btn').click(function (e) {
        e.preventDefault();
        var $input = $(this).prev('.field-always-editable');
        var data_hash = {};
        data_hash[$input.attr('name')] = $input.val();
        var url = $('#standard_answer_set_update_fields_url').val();
        $.ajax(url, {data: data_hash, type: "PUT"}).done(function () {
          $input.siblings('.fail_msg').hide();
          $input.siblings('.success_msg').html('Saved').show().delay(500).fadeOut('slow');
        }).fail(function (jqXHR) {
          $input.siblings('.fail_msg').html('Failed to save: ' + jqXHR.responseText).show();
        });
      });
    },

    _init_std_answer_selects: function ($std_answer_selects) {
        var that = this;
        $std_answer_selects.each(function () {
            // build parent child relationships
            var standard_answer_set_id = this.dataset.standardAnswerSetId;
            var parent_standard_answer_set_id = this.dataset.parentStandardAnswerSetId;
            var parent_element = that._find_nearest(this, 'select.standard-answer[data-standard-answer-set-id=' + parent_standard_answer_set_id + ']');
            if (parent_element) {
                $(this).data('parent', parent_element);
                $(parent_element).data('children') ?
                    $(parent_element).data('children').push(this) :
                    $(parent_element).data('children', [this]);
            }
            // init select2
            var search_path = $('#form_builder_standard_answer_sets_path').val() + "/" + standard_answer_set_id + "/search";
            that._init_select2(this, search_path);
        });
        $std_answer_selects.each(function () {
            // bind events
            $(this).on('select2:select', function (e) {
                if ($(this).data('parent') && e.params.data.parent) {
                    that._update_parent_questions_in_response_set($(this).data('parent'), e.params.data.parent);
                }
                this.focus();
            });
            $(this).on('change', function (e) {
                that._update_children_questions_in_response_set($(this).data('children'));
            });
        });
    },
    _find_nearest: function (base_element, criteria) {
        var base_element_tr = $(base_element).closest('tr').get(0);
        var base_element_index;
        var matched_elements = [];
        $(base_element).closest('fieldset').find('tr').each(function (index, tr) {
            if (tr === base_element_tr) {
                base_element_index = index;
            } else if ($(tr).find(criteria).length) {
                matched_elements.push([index, $(tr).find(criteria).get(0)]);
            }
        });
        var min_dist = Infinity;
        var result;
        matched_elements.forEach(function (matched_element, index) {
            if (Math.abs(matched_element[0] - base_element_index) < min_dist) {
                min_dist = Math.abs(matched_element[0] - base_element_index);
                result = matched_element[1];
            }
        });
        return result;
    },
    _update_parent_questions_in_response_set: function (element, data) {
        if ($(element).val() !== data.id) {
            if ($(element).data('parent') && data.parent) {
                this._update_parent_questions_in_response_set($(element).data('parent'), data.parent);
            }
            $(element).empty();
            $(element).append($('<option>', {value: "", text: ""}));
            $(element).append($('<option>', {value: data.id, text: data.text}));
            $(element).val(data.id);
        }
    },
    _update_children_questions_in_response_set: function (elements) {
        var that = this;
        if (elements) {
            $.each(elements, function(){
                $(this).val('').trigger('change');
                that._update_children_questions_in_response_set($(this).data('children'));
            });
        }
    },
    _init_std_answer_set_parent_answer: function (element, clear_selection) {
        var that = this;
        if ($(element).data('select2')) {
            $(element).select2('destroy');
            $(element).empty();
        }
        var parent_set_id = $('#form_builder_standard_answer_set_parent_id').val();
        var search_path = $('#form_builder_standard_answer_sets_path').val() + "/" + parent_set_id + "/search";
        if (parent_set_id && parent_set_id != "") {
            element.style.width = "150px";
            that._init_select2(element, search_path);
        } else {
            element.style.width = null;
        }
        if (clear_selection) {
            $(element).val('').trigger('change');
        }
    },
    _init_select2: function (element, search_path) {
        $(element).select2({
            allowClear: true,
            placeholder: "Select from standard answer set",
            ajax: {
                url: search_path,
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                        q: params.term,
                        parent_answer_id: $(element).data("parent") ? $($(element).data("parent")).val() : null,
                        page: params.page
                    };
                },
                processResults: function (data, params) {
                    params.page = params.page || 1;
                    return {
                        results: data.items,
                        pagination: {
                            more: (params.page * 20) < data.total_count
                        }
                    };
                },
                cache: true
            },
            templateSelection: function(data, container) {
              if (data.value) {
                $(data.element).attr('data-value', data.value);
              }
              return data.text;
            }
        });
    },
    _validate_uniqueness_of_display_order: function(){
        $('.standard_answer_set_form').submit(function(){
            var display_orders = $(".display-order:visible").map(function(){ return $(this).val(); }).get();
            var sorted_display_orders = display_orders.sort();

            var results = [];
            for (var i = 0; i < display_orders.length - 1; i++) {
                if (sorted_display_orders[i] == sorted_display_orders[i + 1]) {
                    results.push(sorted_display_orders[i]);
                }
            }

            if(results.length > 0){
                // humane.log("There are more than one display orders with same values. Data cannot be submitted.", { timeout: 3000, addnCls: 'humane-jackedup-error' });
                return false;
            } else {
                return true;
            }
        });
    }
};
