class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :address

      t.timestamps
    end
  end
end
