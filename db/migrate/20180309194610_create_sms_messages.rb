class CreateSmsMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :sms_messages do |t|
      t.string :to
      t.text :body
      t.integer :company_id
      t.integer :user_id
      t.integer :customer_id

      t.timestamps
    end
  end
end
