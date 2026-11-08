class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.string :street
      t.string :city
      t.string :postal_code
      t.string :province_code
      t.integer :subtotal_cents
      t.integer :gst_cents
      t.integer :pst_cents
      t.integer :hst_cents
      t.integer :total_cents
      t.decimal :gst_rate, precision: 6, scale: 5, null: false
      t.decimal :pst_rate, precision: 6, scale: 5, null: false
      t.decimal :hst_rate, precision: 6, scale: 5, null: false

      t.timestamps
    end
  end
end
