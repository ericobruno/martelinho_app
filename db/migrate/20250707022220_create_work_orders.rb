class CreateWorkOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :work_orders do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :quote, null: true, foreign_key: true
      t.integer :total_amount_cents, default: 0, null: false
      t.string :total_amount_currency, default: 'BRL', null: false
      t.string :status, default: 'pending', null: false
      t.string :priority, default: 'normal', null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.text :notes

      t.timestamps
    end

    add_index :work_orders, :status
    add_index :work_orders, :priority
    add_index :work_orders, [:vehicle_id, :status]
    add_index :work_orders, :started_at
    add_index :work_orders, :completed_at
  end
end
