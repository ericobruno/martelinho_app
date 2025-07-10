class AddDepartmentIdToWorkOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :work_orders, :department, null: true, foreign_key: true
  end
end