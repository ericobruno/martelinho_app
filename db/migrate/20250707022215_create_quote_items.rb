class CreateQuoteItems < ActiveRecord::Migration[8.0]
  def change
    create_table :quote_items do |t|
      t.references :quote, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false
      t.integer :unit_price_cents, default: 0, null: false
      t.string :unit_price_currency, default: 'BRL', null: false
      t.integer :total_price_cents, default: 0, null: false
      t.string :total_price_currency, default: 'BRL', null: false
      t.text :description

      t.timestamps
    end
  end
end
