class AddTemporaryPasswordToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :temporary_password, :string
  end
end
