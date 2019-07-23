class RemoveAllowNoScoreFromCriteria < ActiveRecord::Migration[5.2]
  def change
    remove_column :criteria, :allow_no_score, :boolean
  end
end
