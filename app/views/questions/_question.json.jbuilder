json.extract! question, :id, :field, :grant, :name, :help_text, :placeholder_text, :required, :created_at, :updated_at
json.url question_url(question, format: :json)
