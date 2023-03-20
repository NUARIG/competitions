class AddAwardedToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :grant_submission_submissions, :awarded, :boolean, null: false, default: false

    add_index :grant_submission_submissions, %i[grant_id awarded]
  end
end
