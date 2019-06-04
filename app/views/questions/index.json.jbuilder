# frozen_string_literal: true

json.array! @questions, partial: 'questions/question', as: :question
