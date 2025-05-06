class AddUserEmailToOrder < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :user_email, :string
  end
end
