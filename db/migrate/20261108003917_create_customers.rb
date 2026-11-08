class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.references :province, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.string :street
      t.string :city
      t.string :postal_code

      t.timestamps
    end
  end
end
