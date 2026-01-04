# frozen_string_literal: true

namespace :identity do
  desc "Create an admin user with a secure generated password"
  task :create_admin, [:username] => :environment do |_t, args|
    username = args[:username]

    if username.blank?
      puts "Error: Username is required"
      puts "Usage: rake identity:create_admin[username]"
      exit 1
    end

    service = Identity::Container[:admin_auth_service]
    result = service.provision(username: username)

    if result.success?
      data = result.value!
      puts "\nAdmin created successfully!"
      puts "=" * 50
      puts "Username: #{data[:admin].username}"
      puts "Password: #{data[:password]}"
      puts "=" * 50
      puts "\nIMPORTANT: Store this password securely. It cannot be recovered."
    else
      case result.failure
      when :username_blank
        puts "Error: Username cannot be blank"
      when :username_exists
        puts "Error: Username '#{username}' already exists"
      else
        puts "Error: #{result.failure}"
      end
      exit 1
    end
  end
end
