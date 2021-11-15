// Entry point for the build script in your package.json

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
// import "./channels"
import "@hotwired/turbo-rails"
// import "@rails/actioncable"

import "./src/vendor/jquery"
import "jquery-ui"
import "jquery_nested_form"
import "trix"
import "@rails/actiontext"
import "foundation-sites"
import "foundation-datepicker"
import "motion-ui"
import "./src/vendor/select2"

import "./controllers"

Rails.start()
ActiveStorage.start()
$(document).on('turbo:load', function() {
    $(function(){ $(document).foundation(); });
});

require('./src/legacy/app')
// require('./src/legacy/cable')
require('./src/legacy/dependency')
require('./src/legacy/form_builder_standard_answer')
require('./src/legacy/form_builder_survey')
require('./src/legacy/form_builder_upload_setup')
require('./src/legacy/foundation-datepicker')
require('./src/legacy/grant_permissions')
// require('./src/legacy/grant_reviewers')
require('./src/legacy/reviews')
