class GrantResponseSet < ApplicationRecord
  belongs_to :grant, inverse_of: :grant_response_sets
  belongs_to :response_set, class_name: 'Submission::ResponseSet',
                            foreign_key: :submission_response_set_id,
                            inverse_of: :grant_response_set
end
