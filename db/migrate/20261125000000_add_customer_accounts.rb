class AddCustomerAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :username, :string
    add_column :customers, :password_digest, :string
    add_index :customers, "LOWER(username)", unique: true, where: "username IS NOT NULL", name: "index_customers_on_account_username"
  end
end
