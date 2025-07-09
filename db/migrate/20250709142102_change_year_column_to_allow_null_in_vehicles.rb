class ChangeYearColumnToAllowNullInVehicles < ActiveRecord::Migration[8.0]
  def change
    change_column_null :vehicles, :year, true
  end
end
