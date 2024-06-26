// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import CheckboxSubmitController from "./checkbox_submit_controller.js"
application.register("checkbox-submit", CheckboxSubmitController)

import FiltersController from "./filters_controller.js"
application.register("filters", FiltersController)

import Ts__SearchController from "./ts/search_controller.js"
application.register("ts--search", Ts__SearchController)

import ReviewsController from "./reviews_controller.js"
application.register('reviews', ReviewsController)

import ModalsController from "./modals_controller.js"
application.register('modals', ModalsController)

import ReflowController from "./reflow_controller.js"
application.register('reflow', ReflowController)
