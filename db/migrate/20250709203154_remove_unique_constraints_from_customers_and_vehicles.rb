class RemoveUniqueConstraintsFromCustomersAndVehicles < ActiveRecord::Migration[8.0]
  def up
    # Remove unique constraint from customers cpf_cnpj
    remove_index :customers, name: "index_customers_on_cpf_cnpj"
    add_index :customers, :cpf_cnpj

    # Remove unique constraint from vehicles license_plate
    remove_index :vehicles, name: "index_vehicles_on_license_plate"
    add_index :vehicles, :license_plate
  end

  def down
    # Restore unique constraints
    remove_index :customers, :cpf_cnpj
    add_index :customers, :cpf_cnpj, unique: true

    remove_index :vehicles, :license_plate
    add_index :vehicles, :license_plate, unique: true
  end
end
