class AddDiscardedAtToPanels < ActiveRecord::Migration[6.0]
  def change
    add_column :panels, :discarded_at, :datetime
    add_index  :panels, :discarded_at
  end
end
