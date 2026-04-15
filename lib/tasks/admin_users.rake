namespace :admin_users do
  desc "Crea l'utente admin primario da CLI"
  task create_primary: :environment do
    if User.where(admin: true).exists?
      abort("Esiste gia un admin. Operazione annullata.")
    end

    email = ENV["EMAIL"].to_s.strip
    password = ENV["PASSWORD"].to_s
    first_name = ENV["FIRST_NAME"].to_s.strip
    last_name = ENV["LAST_NAME"].to_s.strip
    time_zone = ENV["TIME_ZONE"].presence || "Europe/Rome"
    phone = ENV["PHONE"].to_s.strip.presence

    if email.blank? || password.blank?
      abort("Uso: bin/rails admin_users:create_primary EMAIL=admin@example.com PASSWORD=secret123 FIRST_NAME=Mario LAST_NAME=Rossi")
    end

    user = User.new(
      email: email,
      password: password,
      password_confirmation: password,
      first_name: first_name,
      last_name: last_name,
      time_zone: time_zone,
      phone: phone,
      admin: true
    )

    if user.save
      puts "Admin primario creato con successo: #{user.email}"
    else
      abort("Errore durante la creazione admin: #{user.errors.full_messages.join(', ')}")
    end
  end
end
