#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

puts "=== TESTING QUOTE FIXES ==="
puts "Time: #{Time.current}"
puts

# Find user
user = User.first
puts "✅ Using user: #{user.email}"

# Find or create test data
customer = Customer.first || Customer.create!(
  name: 'Test Customer',
  cpf_cnpj: '12345678901',
  email: 'test@customer.com',
  phone: '+5511987654321'  # Valid Brazilian format
)

brand = VehicleBrand.first || VehicleBrand.create!(name: 'Toyota')
model = VehicleModel.first || VehicleModel.create!(name: 'Corolla', vehicle_brand: brand)

vehicle = Vehicle.first || Vehicle.create!(
  license_plate: 'TEST123',
  customer: customer,
  vehicle_brand: brand,
  vehicle_model: model,
  year: 2020
)

puts "✅ Test data ready"
puts

# Test 1: Simple quote creation (should work now)
puts "=== Test 1: Simple Quote Creation ==="

quote1 = Quote.new(
  vehicle: vehicle,
  user: user,
  service_value: 250.0,
  notes: "Test quote after fixes"
)

puts "Quote1 before save:"
puts "  service_value: #{quote1.service_value}"
puts "  service_value_cents: #{quote1.service_value_cents}"
puts "  status: #{quote1.status.inspect}"
puts "  total_amount: #{quote1.total_amount}"

if quote1.valid?
  puts "✅ Quote1 is valid"
  if quote1.save
    puts "✅ Quote1 saved successfully! ID: #{quote1.id}"
    puts "  Final status: #{quote1.status}"
    puts "  Final total_amount: #{quote1.total_amount}"
    puts "  Final expires_at: #{quote1.expires_at}"
  else
    puts "❌ Quote1 save failed"
    quote1.errors.full_messages.each { |e| puts "  - #{e}" }
  end
else
  puts "❌ Quote1 is invalid:"
  quote1.errors.full_messages.each { |e| puts "  - #{e}" }
end

puts

# Test 2: Quote with form-like parameters  
puts "=== Test 2: Quote with Form Parameters ==="

# Simulate controller behavior
quote_params = {
  vehicle_id: vehicle.id,
  service_value: "300.50",
  notes: "Test with form params"
}

quote2 = Quote.new
quote2.user = user
quote2.assign_attributes(quote_params)

puts "Quote2 after assign_attributes:"
puts "  vehicle_id: #{quote2.vehicle_id}"
puts "  service_value: #{quote2.service_value}"
puts "  status: #{quote2.status.inspect}"

if quote2.valid?
  puts "✅ Quote2 is valid"
  if quote2.save
    puts "✅ Quote2 saved successfully! ID: #{quote2.id}"
    puts "  Final status: #{quote2.status}"
    puts "  Final total_amount: #{quote2.total_amount}"
  else
    puts "❌ Quote2 save failed"
    quote2.errors.full_messages.each { |e| puts "  - #{e}" }
  end
else
  puts "❌ Quote2 is invalid:"
  quote2.errors.full_messages.each { |e| puts "  - #{e}" }
end

puts

# Test 3: Quote with nested attributes and valid phone
puts "=== Test 3: Quote with Valid Phone Number ==="

quote3_params = {
  service_value: 150.0,
  notes: "Test with valid phone",
  vehicle_attributes: {
    license_plate: "FIX123",
    year: 2021,
    vehicle_brand_id: brand.id,
    vehicle_model_id: model.id,
    customer_attributes: {
      name: "Valid Phone Customer",
      cpf_cnpj: "98765432100",
      phone: "+5511999887766",  # Valid Brazilian mobile
      email: "valid@customer.com"
    }
  }
}

quote3 = Quote.new
quote3.user = user
quote3.assign_attributes(quote3_params)

if quote3.valid?
  puts "✅ Quote3 is valid"
  if quote3.save
    puts "✅ Quote3 saved successfully! ID: #{quote3.id}"
    puts "  Customer: #{quote3.vehicle.customer.name}"
    puts "  Customer phone: #{quote3.vehicle.customer.phone}"
    puts "  Vehicle: #{quote3.vehicle.license_plate}"
    puts "  Status: #{quote3.status}"
    puts "  Total: #{quote3.total_amount}"
  else
    puts "❌ Quote3 save failed"
    quote3.errors.full_messages.each { |e| puts "  - #{e}" }
  end
else
  puts "❌ Quote3 is invalid:"
  quote3.errors.full_messages.each { |e| puts "  - #{e}" }
  
  if quote3.vehicle && !quote3.vehicle.valid?
    puts "Vehicle errors:"
    quote3.vehicle.errors.full_messages.each { |e| puts "  - #{e}" }
    
    if quote3.vehicle.customer && !quote3.vehicle.customer.valid?
      puts "Customer errors:"
      quote3.vehicle.customer.errors.full_messages.each { |e| puts "  - #{e}" }
    end
  end
end

puts
puts "=== FIXES TEST COMPLETE ===" 