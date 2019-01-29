class CreateGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :grants do |t|
      t.references :organization, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name
      t.string :short_name
      t.string :state
      t.datetime :initiation_date
      t.datetime :submission_open_date
      t.datetime :submission_close_date
      t.text :rfa
      t.float :min_budget
      t.float :max_budget
      t.integer :applications_per_user
      t.text :review_guidance
      t.integer :max_reviewers_per_proposal
      t.integer :max_proposals_per_reviewer
      t.datetime :panel_date
      t.text :panel_location

      t.timestamps
    end
  end
end
