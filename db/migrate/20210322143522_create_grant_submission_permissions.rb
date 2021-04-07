class CreateGrantSubmissionPermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :grant_submission_permissions do |t|
      t.references :grant_submission_submission,  foreign_key: true,
                                                  null: false,
                                                  index: { name: 'i_gsa_on_grant_submission_submission_id' }
      t.references :user, foreign_key: true,
                          null: false
      t.datetime   :deleted_at

      t.timestamps
    end
  end
end
