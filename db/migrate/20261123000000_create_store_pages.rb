class CreateStorePages < ActiveRecord::Migration[8.1]
  def change
    create_table :store_pages do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.string :email
      t.string :phone
      t.text :opening_hours
      t.timestamps
    end
    add_index :store_pages, :slug, unique: true
  end
end
