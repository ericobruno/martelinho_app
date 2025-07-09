class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :cpf_cnpj, null: false
      t.text :address

      t.timestamps
    end

    add_index :customers, :email
    add_index :customers, :cpf_cnpj, unique: true
    add_index :customers, :name
  end
end
