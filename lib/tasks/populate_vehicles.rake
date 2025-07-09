namespace :vehicles do
  desc "Populate vehicle brands and models"
  task populate: :environment do
    puts "🧹 Limpando dados existentes..."
    VehicleModel.destroy_all
    VehicleBrand.destroy_all

    # Basic vehicle brands and models for Brazilian market
    marcas_e_modelos = {
      'Volkswagen' => ['Gol', 'Polo', 'Jetta', 'Passat', 'Tiguan', 'Amarok', 'T-Cross', 'Virtus'],
      'Chevrolet' => ['Onix', 'Prisma', 'Cruze', 'Tracker', 'S10', 'Camaro', 'Spin', 'Cobalt'],
      'Ford' => ['Ka', 'Fiesta', 'Focus', 'Fusion', 'EcoSport', 'Ranger', 'Edge', 'Mustang'],
      'Fiat' => ['Uno', 'Palio', 'Siena', 'Strada', 'Toro', 'Argo', 'Cronos', 'Mobi'],
      'Honda' => ['Civic', 'Fit', 'City', 'HR-V', 'CR-V', 'Accord', 'WR-V'],
      'Toyota' => ['Corolla', 'Etios', 'Yaris', 'Camry', 'RAV4', 'Hilux', 'SW4', 'Prius'],
      'Nissan' => ['Versa', 'March', 'Sentra', 'Kicks', 'X-Trail', 'Frontier'],
      'Hyundai' => ['HB20', 'Creta', 'ix35', 'Tucson', 'Santa Fe', 'Azera', 'Elantra'],
      'Renault' => ['Sandero', 'Logan', 'Duster', 'Captur', 'Fluence', 'Kwid'],
      'Peugeot' => ['208', '2008', '3008', '308', '408', '508', '207']
    }

    puts "🚗 Criando marcas e modelos de veículos..."

    marcas_e_modelos.each do |marca_nome, modelos|
      puts "  📦 Criando marca: #{marca_nome}"
      marca = VehicleBrand.create!(name: marca_nome)
      
      modelos.each do |modelo_nome|
        modelo = VehicleModel.create!(
          name: modelo_nome, 
          vehicle_brand: marca
        )
        print "    ✅ #{modelo_nome} "
      end
      puts ""
    end

    puts "\n✨ Finalizado! Criadas #{VehicleBrand.count} marcas e #{VehicleModel.count} modelos."
  end
end 