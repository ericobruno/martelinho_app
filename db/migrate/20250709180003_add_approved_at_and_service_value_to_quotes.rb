class AddApprovedAtAndServiceValueToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :approved_at, :datetime
    add_column :quotes, :service_value_cents, :integer, default: 0, null: false
    add_column :quotes, :service_value_currency, :string, default: 'BRL', null: false
    
    add_index :quotes, :approved_at
  end
end
