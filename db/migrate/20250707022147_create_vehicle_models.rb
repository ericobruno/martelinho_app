class CreateVehicleModels < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicle_models do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.references :vehicle_brand, null: false, foreign_key: true

      t.timestamps
    end

    add_index :vehicle_models, :name
    add_index :vehicle_models, :slug, unique: true
    add_index :vehicle_models, [:vehicle_brand_id, :name], unique: true
  end
end
