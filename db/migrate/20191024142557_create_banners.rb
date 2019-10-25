class CreateBanners < ActiveRecord::Migration[5.2]
  def change
    create_table :banners do |t|
      t.text        :body
      t.boolean     :visible, null: false, default: true
      t.timestamps  null: false
    end
  end
end
