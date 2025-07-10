class AddPaymentFieldsToWorkOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :work_orders, :paid_amount_cents, :integer, default: 0, null: false
    add_column :work_orders, :paid_amount_currency, :string, default: 'BRL', null: false
    add_column :work_orders, :fully_paid_at, :datetime
  end
end