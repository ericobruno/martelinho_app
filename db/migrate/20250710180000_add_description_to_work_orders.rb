class AddDescriptionToWorkOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :work_orders, :description, :text
  end
end