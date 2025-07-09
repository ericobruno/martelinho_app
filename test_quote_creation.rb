#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

# Test case 1: New customer + New vehicle (nested attributes)
puts "=== Testing Case 1: New Customer + New Vehicle ==="

# Find a user to assign
user = User.first
unless user
  puts "❌ No user found. Creating one..."
  user = User.create!(email: 'test@example.com', password: 'password123', name: 'Test User')
end

# Find vehicle brands and models
brand = VehicleBrand.first
model = VehicleModel.first

unless brand && model
  puts "❌ No vehicle brands/models found. Creating them..."
  brand = VehicleBrand.create!(name: 'Toyota')
  model = VehicleModel.create!(name: 'Corolla', vehicle_brand: brand)
end

# Simulate form parameters for new customer + new vehicle
quote_params = {
  notes: 'Test quote with new customer and vehicle',
  status: 'draft',
  expires_at: 30.days.from_now,
  vehicle_attributes: {
    license_plate: 'ABC1234',
    year: 2020,
    color: 'Branco',
    vehicle_brand_id: brand.id,
    vehicle_model_id: model.id,
    customer_attributes: {
      name: 'João Silva',
      cpf_cnpj: '11144477735', # Valid CPF
      email: 'joao@example.com',
      phone: '11999887766', # Brazilian format
      address: 'Rua das Flores, 123'
    }
  }
}

# Create quote
quote = Quote.new(quote_params)
quote.user = user

puts "Quote params: #{quote_params.inspect}"
puts "Quote valid?: #{quote.valid?}"
puts "Quote errors: #{quote.errors.full_messages}" unless quote.valid?

if quote.save
  puts "✅ Quote created successfully!"
  puts "Quote ID: #{quote.id}"
  puts "Customer: #{quote.customer.name} (#{quote.customer.cpf_cnpj})"
  puts "Vehicle: #{quote.vehicle.license_plate} - #{quote.vehicle.vehicle_brand.name} #{quote.vehicle.vehicle_model.name}"
  puts "Total Amount: #{quote.total_amount}"
else
  puts "❌ Quote creation failed: #{quote.errors.full_messages}"
end

puts "\n" + "="*50 + "\n"

# Test case 2: Existing customer + New vehicle
puts "=== Testing Case 2: Existing Customer + New Vehicle ==="

# Create a customer first
customer = Customer.create!(
  name: 'Maria Santos',
  cpf_cnpj: '22233366612', # Valid CPF
  email: 'maria@example.com',
  phone: '11888776655', # Brazilian format
  address: 'Av. Principal, 456'
)

puts "Created customer: #{customer.name}"

# Parameters for existing customer + new vehicle
quote_params_2 = {
  customer_id: customer.id,
  notes: 'Test quote with existing customer and new vehicle',
  status: 'draft',
  expires_at: 30.days.from_now,
  vehicle_attributes: {
    license_plate: 'XYZ9876',
    year: 2021,
    color: 'Preto',
    vehicle_brand_id: brand.id,
    vehicle_model_id: model.id,
    customer_id: customer.id
  }
}

quote2 = Quote.new
quote2.user = user

# Simulate our process_quote_params logic
vehicle_attrs = quote_params_2[:vehicle_attributes].dup
vehicle_attrs[:customer_id] = quote_params_2[:customer_id]
processed_params = {
  vehicle_attributes: vehicle_attrs,
  notes: quote_params_2[:notes],
  status: quote_params_2[:status]
}

quote2.assign_attributes(processed_params)

puts "Processed params: #{processed_params.inspect}"
puts "Quote2 valid?: #{quote2.valid?}"
puts "Quote2 errors: #{quote2.errors.full_messages}" unless quote2.valid?

if quote2.save
  puts "✅ Quote2 created successfully!"
  puts "Quote ID: #{quote2.id}"
  puts "Customer: #{quote2.customer.name} (#{quote2.customer.cpf_cnpj})"
  puts "Vehicle: #{quote2.vehicle.license_plate} - #{quote2.vehicle.vehicle_brand.name} #{quote2.vehicle.vehicle_model.name}"
  puts "Total Amount: #{quote2.total_amount}"
else
  puts "❌ Quote2 creation failed: #{quote2.errors.full_messages}"
end

puts "\n" + "="*50 + "\n"

# Test case 3: Existing vehicle
puts "=== Testing Case 3: Existing Vehicle ==="

vehicle = Vehicle.first
if vehicle
  quote3 = Quote.new(vehicle: vehicle, notes: 'Test with existing vehicle', status: 'draft', expires_at: 30.days.from_now)
  quote3.user = user
  
  if quote3.save
    puts "✅ Quote3 created successfully!"
    puts "Quote ID: #{quote3.id}"
    puts "Customer: #{quote3.customer.name}"
    puts "Vehicle: #{quote3.vehicle.license_plate}"
  else
    puts "❌ Quote3 creation failed: #{quote3.errors.full_messages}"
  end
else
  puts "No existing vehicle found to test with"
end

puts "\nTest completed!" 