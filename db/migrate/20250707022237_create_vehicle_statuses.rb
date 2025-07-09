class CreateVehicleStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicle_statuses do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.references :work_order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'entered', null: false
      t.datetime :entered_at, null: false
      t.datetime :exited_at
      t.text :notes

      t.timestamps
    end

    add_index :vehicle_statuses, :status
    add_index :vehicle_statuses, :entered_at
    add_index :vehicle_statuses, :exited_at
    add_index :vehicle_statuses, [:vehicle_id, :exited_at]
  end
end
