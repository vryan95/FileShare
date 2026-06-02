#!/usr/bin/env ruby
# Script to verify Entra ID configuration

puts '=== Entra ID Configuration Check ==='
puts ''

client_id = ENV['ENTRA_CLIENT_ID']
client_secret = ENV['ENTRA_CLIENT_SECRET']
tenant_id = ENV['ENTRA_TENANT_ID']

if client_id && !client_id.empty?
  puts "✓ ENTRA_CLIENT_ID is set: #{client_id[0..10]}..."
else
  puts '✗ ENTRA_CLIENT_ID is NOT set'
end

if client_secret && !client_secret.empty?
  puts "✓ ENTRA_CLIENT_SECRET is set (length: #{client_secret.length} chars)"
else
  puts '✗ ENTRA_CLIENT_SECRET is NOT set'
end

if tenant_id && !tenant_id.empty?
  puts "✓ ENTRA_TENANT_ID is set: #{tenant_id}"
else
  puts '✗ ENTRA_TENANT_ID is NOT set'
end

puts ''
if client_id && client_secret && tenant_id
  puts '✓ All required environment variables are configured!'
  puts 'You can now restart your Rails server and try signing in.'
else
  puts '✗ Some environment variables are missing. Please check your .env file.'
end
