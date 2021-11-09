// Entry point for the build script in your package.json

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "@hotwired/turbo-rails"

// import "controllers"
import "./controllers"

Rails.start()
ActiveStorage.start()

require('./src/legacy/app')
require('./src/legacy/cable')
require('./src/legacy/dependency')
require('./src/legacy/form_builder_standard_answer')
require('./src/legacy/form_builder_survey')
require('./src/legacy/form_builder_upload_setup')
require('./src/legacy/foundation-datepicker')
require('./src/legacy/grant_permission')
require('./src/legacy/reviews')
