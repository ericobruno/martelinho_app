#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

puts "=== Quick Test: Optional Fields ==="

# Test Customer with optional email
customer = Customer.new(
  name: 'Test Customer',
  cpf_cnpj: '12345678901',
  phone: '11987654321'
  # email omitted
)

puts "Customer valid without email?: #{customer.valid?}"
if customer.valid?
  puts "✅ Customer validation passed (email optional)"
else
  puts "❌ Customer validation failed: #{customer.errors.full_messages}"
end

# Test Vehicle with optional year and color
brand = VehicleBrand.first || VehicleBrand.create!(name: 'Test Brand')
model = VehicleModel.first || VehicleModel.create!(name: 'Test Model', vehicle_brand: brand)

vehicle = Vehicle.new(
  license_plate: 'TEST123',
  customer: customer,
  vehicle_brand: brand,
  vehicle_model: model
  # year and color omitted
)

puts "Vehicle valid without year/color?: #{vehicle.valid?}"
if vehicle.valid?
  puts "✅ Vehicle validation passed (year/color optional)"
else
  puts "❌ Vehicle validation failed: #{vehicle.errors.full_messages}"
end

# Test Quote with default status
user = User.first || User.create!(email: 'test@example.com', password: 'password123', name: 'Test User')

quote = Quote.new(
  vehicle: vehicle,
  user: user,
  notes: 'Test quote'
  # status and expires_at omitted - should get defaults
)

puts "Quote valid with defaults?: #{quote.valid?}"
if quote.valid?
  puts "✅ Quote validation passed (defaults applied)"
  puts "Default status: #{quote.status}"
else
  puts "❌ Quote validation failed: #{quote.errors.full_messages}"
end

puts "\n✅ Quick test completed!" 