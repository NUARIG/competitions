class CreateGrantCreatorRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :grant_creator_requests do |t|
      t.bigint  :requester_id,    foreign_key: true, null: false
      t.text    :request_comment, null: false
      t.string  :status,          null: false, default: 'pending'
      t.bigint  :reviewer_id,     foreign_key: true
      t.text    :review_comment

      t.timestamps
    end

    add_index :grant_creator_requests, :status
  end
end
