class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.jsonb :items

      t.timestamps
    end
  end
end
