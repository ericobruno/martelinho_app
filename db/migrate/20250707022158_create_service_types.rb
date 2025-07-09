class CreateServiceTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :service_types do |t|
      t.string :name, null: false
      t.text :description
      t.integer :default_price_cents, default: 0, null: false
      t.string :default_price_currency, default: 'BRL', null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :service_types, :name, unique: true
    add_index :service_types, :active
  end
end
