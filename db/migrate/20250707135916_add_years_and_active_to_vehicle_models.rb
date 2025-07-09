class AddYearsAndActiveToVehicleModels < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicle_models, :initial_year, :integer, null: true
    add_column :vehicle_models, :final_year, :integer, null: true
    add_column :vehicle_models, :active, :boolean, default: true, null: false
  end
end
