Grant.dependency = function(source, sink, condition, on_hide){
  var update = function(){
    var con = !!condition();
    sink.toggle(con);
    if(!con){on_hide();}
  }
  update();
  source.change(update);
}

Grant.dependency_include = function(source, source_type, sink, sink_type, values){
  var get_selector = function(name, type){
    var type_element_map = {checkbox: 'input',
                            select:   'select',
                            textbox:  'input',
                            textarea: 'textarea'};
    var selector = "." + name + " " + type_element_map[type];
    if(type === 'checkbox'){
      selector = selector + "[type=checkbox]"
    }
    if(type === 'textbox'){
      selector = selector + "[type=text]"
    }
    return selector
  }
  return function(scope){
    var source_field = get_selector(source, source_type);
    var sink_field = get_selector(sink, sink_type);
    Grant.dependency(
      $(source_field, scope),
      $("." + sink, scope),
      function(){
        var active = true;
        switch(source_type){
          case 'select':
            active = values.indexOf($(source_field, scope).val()) !== -1;
            break;
          case 'checkbox':
            active = values.indexOf($(source_field, scope).prop('checked')) !== -1;
            break;
        }
        return active;
      },
      function(){
        $(sink_field, scope).val('');
        $(sink_field, scope).change();
      }
    );
  }
}
