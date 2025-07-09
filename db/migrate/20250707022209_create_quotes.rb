class CreateQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :total_amount_cents, default: 0, null: false
      t.string :total_amount_currency, default: 'BRL', null: false
      t.string :status, default: 'draft', null: false
      t.text :notes
      t.datetime :expires_at

      t.timestamps
    end

    add_index :quotes, :status
    add_index :quotes, :expires_at
    add_index :quotes, [:vehicle_id, :status]
  end
end
