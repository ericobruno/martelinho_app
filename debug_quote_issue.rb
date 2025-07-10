#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

puts "=== DEBUGGING QUOTE CREATION ISSUE ==="
puts "Time: #{Time.current}"
puts

# Check if basic models exist
puts "=== Checking Required Models ==="
user_count = User.count
customer_count = Customer.count
vehicle_count = Vehicle.count
brand_count = VehicleBrand.count
model_count = VehicleModel.count

puts "Users: #{user_count}"
puts "Customers: #{customer_count}" 
puts "Vehicles: #{vehicle_count}"
puts "Vehicle Brands: #{brand_count}"
puts "Vehicle Models: #{model_count}"
puts

if user_count == 0
  puts "❌ No users found! Creating test user..."
  user = User.create!(
    email: 'debug@example.com',
    password: 'password123',
    name: 'Debug User'
  )
  puts "✅ User created: #{user.email}"
else
  user = User.first
  puts "✅ Using existing user: #{user.email}"
end

# Test case 1: Simple quote with existing customer and vehicle
puts "\n=== Test 1: Existing Customer + Existing Vehicle ==="

if customer_count == 0 || vehicle_count == 0
  puts "⚠️ No existing customers or vehicles found. Creating test data..."
  
  # Create customer
  customer = Customer.create!(
    name: 'Test Customer',
    cpf_cnpj: '12345678901',
    email: 'test@customer.com',
    phone: '11999888777'
  )
  puts "✅ Customer created: #{customer.name}"
  
  # Ensure we have brand and model
  brand = VehicleBrand.first_or_create!(name: 'Test Brand')
  model = VehicleModel.first_or_create!(name: 'Test Model', vehicle_brand: brand)
  
  # Create vehicle
  vehicle = Vehicle.create!(
    license_plate: 'TEST123',
    customer: customer,
    vehicle_brand: brand,
    vehicle_model: model,
    year: 2020
  )
  puts "✅ Vehicle created: #{vehicle.license_plate}"
else
  customer = Customer.first
  vehicle = Vehicle.first
  puts "✅ Using existing customer: #{customer.name}"
  puts "✅ Using existing vehicle: #{vehicle.license_plate}"
end

# Test simple quote creation
puts "\n--- Creating quote with existing vehicle ---"

quote = Quote.new(
  vehicle: vehicle,
  user: user,
  service_value: 150.0,
  notes: "Test quote debug"
)

puts "Quote attributes before save:"
puts "  vehicle_id: #{quote.vehicle_id}"
puts "  user_id: #{quote.user_id}" 
puts "  service_value: #{quote.service_value}"
puts "  service_value_cents: #{quote.service_value_cents}"
puts "  total_amount: #{quote.total_amount}"
puts "  total_amount_cents: #{quote.total_amount_cents}"
puts "  status: #{quote.status}"
puts "  expires_at: #{quote.expires_at}"

puts "\nValidation check:"
if quote.valid?
  puts "✅ Quote is valid"
else
  puts "❌ Quote is invalid:"
  quote.errors.full_messages.each do |error|
    puts "  - #{error}"
  end
  puts "\nDetailed errors:"
  quote.errors.details.each do |field, details|
    puts "  #{field}: #{details}"
  end
end

puts "\nAttempting to save..."
if quote.save
  puts "✅ Quote saved successfully! ID: #{quote.id}"
  puts "  Final service_value_cents: #{quote.service_value_cents}"
  puts "  Final total_amount_cents: #{quote.total_amount_cents}"
  puts "  Final status: #{quote.status}"
  puts "  Final expires_at: #{quote.expires_at}"
else
  puts "❌ Quote save failed:"
  quote.errors.full_messages.each do |error|
    puts "  - #{error}"
  end
end

# Test case 2: Quote with parameters similar to form submission
puts "\n=== Test 2: Quote with Form-like Parameters ==="

quote2_params = {
  vehicle_id: vehicle.id,
  notes: "Test quote with form params",
  service_value: "200.50"  # String like form input
}

quote2 = Quote.new
quote2.user = user
quote2.assign_attributes(quote2_params)

puts "Quote2 attributes:"
puts "  vehicle_id: #{quote2.vehicle_id}"
puts "  user_id: #{quote2.user_id}"
puts "  service_value: #{quote2.service_value}"
puts "  service_value_cents: #{quote2.service_value_cents}"
puts "  notes: #{quote2.notes}"

if quote2.valid?
  puts "✅ Quote2 is valid"
  if quote2.save
    puts "✅ Quote2 saved successfully! ID: #{quote2.id}"
  else
    puts "❌ Quote2 save failed despite being valid"
  end
else
  puts "❌ Quote2 is invalid:"
  quote2.errors.full_messages.each { |e| puts "  - #{e}" }
end

# Test case 3: Quote with nested attributes (new customer + new vehicle)
puts "\n=== Test 3: Quote with Nested Attributes ==="

brand = VehicleBrand.first
model = VehicleModel.first

quote3_params = {
  notes: "Test quote with nested attributes",
  service_value: 300.75,
  vehicle_attributes: {
    license_plate: "DEBUG123",
    year: 2021,
    vehicle_brand_id: brand.id,
    vehicle_model_id: model.id,
    customer_attributes: {
      name: "Debug Customer",
      cpf_cnpj: "98765432100",
      phone: "11888777666",
      email: "debug@customer.com"
    }
  }
}

quote3 = Quote.new
quote3.user = user
quote3.assign_attributes(quote3_params)

puts "Quote3 validation:"
if quote3.valid?
  puts "✅ Quote3 is valid"
  if quote3.save
    puts "✅ Quote3 saved successfully! ID: #{quote3.id}"
    puts "  Customer: #{quote3.vehicle.customer.name}"
    puts "  Vehicle: #{quote3.vehicle.license_plate}"
  else
    puts "❌ Quote3 save failed despite being valid"
    puts "Quote3 errors after save attempt:"
    quote3.errors.full_messages.each { |e| puts "  - #{e}" }
  end
else
  puts "❌ Quote3 is invalid:"
  quote3.errors.full_messages.each { |e| puts "  - #{e}" }
  
  # Check nested validations
  if quote3.vehicle && !quote3.vehicle.valid?
    puts "Vehicle errors:"
    quote3.vehicle.errors.full_messages.each { |e| puts "  - #{e}" }
    
    if quote3.vehicle.customer && !quote3.vehicle.customer.valid?
      puts "Customer errors:"
      quote3.vehicle.customer.errors.full_messages.each { |e| puts "  - #{e}" }
    end
  end
end

puts "\n=== Debug Complete ===" 