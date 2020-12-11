class CreateReviewerInvitations < ActiveRecord::Migration[6.0]
  def change
    create_table :grant_reviewer_invitations do |t|
      t.belongs_to  :grant,         null: false
      t.bigint      :invited_by_id, null: false
      t.bigint      :invitee_id
      t.string      :email,         null: false
      t.datetime    :confirmed_at
      t.datetime    :reminded_at
      t.datetime    :opted_out_at

      t.timestamps
    end

    add_index :grant_reviewer_invitations, %i[email]
    add_index :grant_reviewer_invitations, %i[grant_id invited_by_id]
    add_index :grant_reviewer_invitations, %i[grant_id email], unique: true

    create_table :grant_reviewer_invitation_versions do |t|
      t.string    :item_type,     null: false
      t.integer   :item_id,       null: false
      t.integer   :grant_id,      null: false
      t.string    :email,         null: false
      t.string    :event,         null: false
      t.integer   :whodunnit # user id
      t.text      :object
      t.datetime  :created_at,    null: false
    end

    add_index :grant_reviewer_invitation_versions, %i[item_id]
    add_index :grant_reviewer_invitation_versions, %i[whodunnit]
    add_index :grant_reviewer_invitation_versions, %i[grant_id]
    add_index :grant_reviewer_invitation_versions, %i[email]
  end
end
