class CreateVehicleBrands < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicle_brands do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :vehicle_brands, :name, unique: true
    add_index :vehicle_brands, :slug, unique: true
  end
end
