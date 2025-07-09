class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.string :license_plate, null: false
      t.integer :year, null: false
      t.string :color, null: false
      t.references :customer, null: false, foreign_key: true
      t.references :vehicle_brand, null: false, foreign_key: true
      t.references :vehicle_model, null: false, foreign_key: true
      t.string :qr_code

      t.timestamps
    end

    add_index :vehicles, :license_plate, unique: true
    add_index :vehicles, :qr_code, unique: true
  end
end
