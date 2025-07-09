class CreateWorkOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :work_order_items do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false
      t.integer :unit_price_cents, default: 0, null: false
      t.string :unit_price_currency, default: 'BRL', null: false
      t.integer :total_price_cents, default: 0, null: false
      t.string :total_price_currency, default: 'BRL', null: false
      t.text :description
      t.boolean :completed, default: false, null: false

      t.timestamps
    end

    add_index :work_order_items, :completed
  end
end
