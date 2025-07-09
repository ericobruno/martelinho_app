# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🚀 Iniciando seed do banco de dados..."

# Limpar dados existentes de veículos
puts "Limpando dados antigos de veículos..."
VehicleModel.destroy_all
VehicleBrand.destroy_all

# Criar usuário administrador
puts "Criando usuário administrador..."
admin = User.find_or_create_by(email: 'admin@martelinhocarlao.com') do |user|
  user.name = 'Administrador do Sistema'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.role = 'admin'
  user.active = true
end

puts "✅ Usuário administrador criado: #{admin.email}"

# Criar usuários funcionários
puts "Criando usuários funcionários..."

employees_data = [
  { name: 'João Silva', email: 'joao@martelinhocarlao.com', role: 'employee' },
  { name: 'Maria Santos', email: 'maria@martelinhocarlao.com', role: 'employee' },
  { name: 'Pedro Oliveira', email: 'pedro@martelinhocarlao.com', role: 'manager' },
  { name: 'Ana Costa', email: 'ana@martelinhocarlao.com', role: 'employee' },
  { name: 'Carlos Ferreira', email: 'carlos@martelinhocarlao.com', role: 'employee' }
]

employees_data.each do |emp_data|
  user = User.find_or_create_by(email: emp_data[:email]) do |u|
    u.name = emp_data[:name]
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.role = emp_data[:role]
    u.active = true
  end
  puts "✅ Usuário #{user.role} criado: #{user.name} (#{user.email})"
end

# Criar marcas e modelos de veículos populares no Brasil
puts "Criando marcas e modelos de veículos..."

vehicle_data = {
  'Volkswagen' => ['Gol', 'Fox', 'Polo', 'Golf', 'Jetta', 'Passat', 'Tiguan', 'T-Cross', 'Virtus', 'Saveiro'],
  'Fiat' => ['Uno', 'Palio', 'Siena', 'Strada', 'Mobi', 'Argo', 'Cronos', 'Toro', 'Fiorino', 'Ducato'],
  'Ford' => ['Ka', 'Fiesta', 'Focus', 'Fusion', 'EcoSport', 'Edge', 'Ranger', 'Transit'],
  'Chevrolet' => ['Onix', 'Prisma', 'Cruze', 'Malibu', 'Tracker', 'Equinox', 'S10', 'Spin'],
  'Toyota' => ['Etios', 'Yaris', 'Corolla', 'Camry', 'RAV4', 'Hilux', 'SW4', 'Prius'],
  'Honda' => ['Fit', 'City', 'Civic', 'Accord', 'HR-V', 'CR-V', 'Pilot'],
  'Hyundai' => ['HB20', 'Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Creta', 'ix35'],
  'Nissan' => ['March', 'Versa', 'Sentra', 'Altima', 'Kicks', 'X-Trail', 'Frontier'],
  'Renault' => ['Sandero', 'Logan', 'Fluence', 'Duster', 'Captur', 'Oroch', 'Master'],
  'Peugeot' => ['208', '308', '408', '508', '2008', '3008', 'Partner'],
  'Citroën' => ['C3', 'C4', 'Aircross', 'Jumper', 'Berlingo'],
  'Jeep' => ['Renegade', 'Compass', 'Grand Cherokee', 'Wrangler'],
  'BMW' => ['Série 1', 'Série 3', 'Série 5', 'X1', 'X3', 'X5'],
  'Mercedes-Benz' => ['Classe A', 'Classe C', 'Classe E', 'GLA', 'GLC', 'Sprinter'],
  'Audi' => ['A3', 'A4', 'A6', 'Q3', 'Q5', 'Q7']
}

brands_created = 0
models_created = 0

vehicle_data.each do |brand_name, models|
  brand = VehicleBrand.create!(name: brand_name)
  brands_created += 1
  
  models.each do |model_name|
    VehicleModel.create!(
      name: model_name,
      vehicle_brand: brand,
      initial_year: rand(1990..2010),
      final_year: rand(2020..2025),
      active: true
    )
    models_created += 1
  end
end

puts "✅ #{brands_created} marcas criadas"
puts "✅ #{models_created} modelos criados"

# Criar departamentos
puts "Criando departamentos..."

departments_data = [
  { name: 'Recepção', description: 'Recebimento e triagem inicial de veículos' },
  { name: 'Diagnóstico', description: 'Análise e diagnóstico de problemas' },
  { name: 'Mecânica Geral', description: 'Serviços de mecânica geral e manutenção' },
  { name: 'Elétrica', description: 'Serviços elétricos e eletrônicos' },
  { name: 'Funilaria', description: 'Reparos de lataria e estrutura' },
  { name: 'Pintura', description: 'Serviços de pintura e acabamento' },
  { name: 'Pneus e Alinhamento', description: 'Serviços de pneus, balanceamento e alinhamento' },
  { name: 'Lavagem', description: 'Lavagem e limpeza de veículos' },
  { name: 'Entrega', description: 'Preparação final e entrega ao cliente' }
]

departments_created = 0
departments_data.each do |dept_data|
  Department.find_or_create_by(name: dept_data[:name]) do |dept|
    dept.description = dept_data[:description]
    dept.active = true
  end
  departments_created += 1
end

puts "✅ #{departments_created} departamentos criados"

# Criar tipos de serviço
puts "Criando tipos de serviço..."

services_data = [
  { name: 'Troca de Óleo', description: 'Troca de óleo do motor', price: 80.00 },
  { name: 'Alinhamento', description: 'Alinhamento de direção', price: 60.00 },
  { name: 'Balanceamento', description: 'Balanceamento de rodas', price: 40.00 },
  { name: 'Revisão Geral', description: 'Revisão completa do veículo', price: 200.00 },
  { name: 'Troca de Filtros', description: 'Troca de filtros (ar, óleo, combustível)', price: 120.00 },
  { name: 'Diagnóstico Eletrônico', description: 'Diagnóstico com scanner automotivo', price: 80.00 },
  { name: 'Troca de Pastilhas de Freio', description: 'Substituição das pastilhas de freio', price: 150.00 },
  { name: 'Suspensão', description: 'Reparo ou troca de componentes da suspensão', price: 300.00 },
  { name: 'Sistema Elétrico', description: 'Reparo em sistema elétrico', price: 180.00 },
  { name: 'Ar Condicionado', description: 'Manutenção do sistema de ar condicionado', price: 120.00 }
]

services_created = 0
services_data.each do |service_data|
  ServiceType.find_or_create_by(name: service_data[:name]) do |service|
    service.description = service_data[:description]
    service.default_price = service_data[:price]
    service.active = true
  end
  services_created += 1
end

puts "✅ #{services_created} tipos de serviço criados"

puts "🎉 Seed concluído com sucesso!"
puts "📊 Resumo:"
puts "   - 1 usuário administrador"
puts "   - 5 usuários funcionários"
puts "   - #{brands_created} marcas de veículos"
puts "   - #{models_created} modelos de veículos"
puts "   - #{departments_created} departamentos"
puts "   - #{services_created} tipos de serviço"
