class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :product, foreign_key: { on_delete: :nullify }
      t.string :product_name, null: false
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false

      t.timestamps
    end
  end
end
