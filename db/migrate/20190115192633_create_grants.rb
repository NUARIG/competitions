# frozen_string_literal: true

class CreateGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :grants do |t|
      t.references :organization, foreign_key: true
      t.string :name,                null: false
      t.string :slug,                null: false
      t.string :state,               null: false
      t.date :publish_date,          null: false
      t.date :submission_open_date,  null: false
      t.date :submission_close_date, null: false
      t.text :rfa
      t.integer :applications_per_user
      t.text :review_guidance
      t.integer :max_reviewers_per_proposal
      t.integer :max_proposals_per_reviewer
      t.date :review_open_date
      t.date :review_close_date
      t.date :panel_date
      t.text :panel_location

      t.timestamps
    end

    add_index :grants, %i[slug]
  end
end
