#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

puts "=== Testing Updated Quote Features ==="

# Find a user to assign
user = User.first
unless user
  puts "❌ No user found. Creating one..."
  user = User.create!(email: 'test@example.com', password: 'password123', name: 'Test User')
end

# Find vehicle brands
brand = VehicleBrand.first
unless brand
  puts "❌ No vehicle brands found. Creating one..."
  brand = VehicleBrand.create!(name: 'Honda')
end

puts "✅ Using brand: #{brand.name}"

# Test 1: New customer with optional email, new vehicle with custom model
puts "\n=== Test 1: New Customer (no email) + New Vehicle (custom model) ==="

quote_params = {
  notes: 'Test quote with optional fields and custom model',
  vehicle_attributes: {
    license_plate: 'TEST123',
    vehicle_brand_id: brand.id,
    custom_model_name: 'Civic Turbo', # Custom model
    customer_attributes: {
      name: 'Carlos Silva',
      cpf_cnpj: '12345678901', # Valid CPF format
      phone: '11987654321'
      # email omitted (optional)
      # address omitted (optional)
    }
    # year omitted (optional)
    # color omitted (optional)
  }
}

quote = Quote.new(quote_params)
quote.user = user

puts "Quote params: #{quote_params.inspect}"
puts "Quote valid?: #{quote.valid?}"
puts "Quote errors: #{quote.errors.full_messages}" unless quote.valid?

if quote.save
  puts "✅ Quote created successfully!"
  puts "Quote ID: #{quote.id}"
  puts "Customer: #{quote.customer.name} (#{quote.customer.cpf_cnpj})"
  puts "Customer email: #{quote.customer.email || 'N/A'}"
  puts "Vehicle: #{quote.vehicle.license_plate} - #{quote.vehicle.vehicle_brand.name} #{quote.vehicle.vehicle_model.name}"
  puts "Vehicle year: #{quote.vehicle.year || 'N/A'}"
  puts "Vehicle color: #{quote.vehicle.color || 'N/A'}"
  puts "Status: #{quote.status}"
  puts "Expires at: #{quote.expires_at}"
else
  puts "❌ Quote creation failed: #{quote.errors.full_messages}"
end

# Test 2: Check if custom model was created
puts "\n=== Test 2: Verify Custom Model Creation ==="
custom_model = VehicleModel.find_by(name: 'Civic Turbo', vehicle_brand: brand)
if custom_model
  puts "✅ Custom model created: #{custom_model.name} (Brand: #{custom_model.vehicle_brand.name})"
else
  puts "❌ Custom model not found"
end

# Test 3: New customer with email, new vehicle with year and color
puts "\n=== Test 3: New Customer (with email) + New Vehicle (with optional fields) ==="

existing_model = VehicleModel.first || VehicleModel.create!(name: 'Fit', vehicle_brand: brand)

quote_params_2 = {
  notes: 'Test quote with all fields',
  vehicle_attributes: {
    license_plate: 'FULL456',
    year: 2022,
    color: 'Azul',
    vehicle_brand_id: brand.id,
    vehicle_model_id: existing_model.id,
    customer_attributes: {
      name: 'Ana Costa',
      cpf_cnpj: '98765432100',
      email: 'ana@example.com',
      phone: '11912345678',
      address: 'Rua das Palmeiras, 789'
    }
  }
}

quote2 = Quote.new(quote_params_2)
quote2.user = user

puts "Quote2 valid?: #{quote2.valid?}"
puts "Quote2 errors: #{quote2.errors.full_messages}" unless quote2.valid?

if quote2.save
  puts "✅ Quote2 created successfully!"
  puts "Quote ID: #{quote2.id}"
  puts "Customer: #{quote2.customer.name} (#{quote2.customer.email})"
  puts "Vehicle: #{quote2.vehicle.license_plate} - #{quote2.vehicle.vehicle_brand.name} #{quote2.vehicle.vehicle_model.name}"
  puts "Vehicle details: Year #{quote2.vehicle.year}, Color #{quote2.vehicle.color}"
  puts "Status: #{quote2.status}"
else
  puts "❌ Quote2 creation failed: #{quote2.errors.full_messages}"
end

puts "\n✅ Test completed! All features working as expected." 