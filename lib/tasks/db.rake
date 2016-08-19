# http://www.postgresql.org/docs/8.3/static/app-pgdump.html
require 'erb'
require 'yaml'
require 'highline/import'

namespace :db do
  task :pg_setup => :environment do
    ar_config      = HashWithIndifferentAccess.new(ActiveRecord::Base.connection.instance_variable_get("@config"))
    fail 'This only works for postgres' unless ar_config[:adapter] == "postgresql"
    @app_name      = Rails.configuration.custom.app_config['application']
    @backup_folder = %w(production staging).include?(Rails.env) ? "/var/www/apps/#{@app_name}/shared/db_backups" : File.join(Rails.root,"tmp","db_backups")
    @password      = ar_config[:password]
    @pg_options    = "-U #{ar_config[:username]} -h #{ar_config[:host] || 'localhost'} -p #{ar_config[:port] || 5432} #{ar_config[:database]}"

    Dir.mkdir(@backup_folder) unless File.directory?(@backup_folder)
  end

  desc "backup database"
  task :backup => :pg_setup do
    destination    = File.join(@backup_folder, "#{@app_name}_#{Rails.env}-#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.sql.gz")
    puts "executing `pg_dump -O -o -c -x -i #{@pg_options} | gzip -f --best > #{destination}`"
    pgpassword_wrapper(@password){ `pg_dump -O -o -c -x -i #{@pg_options} | gzip -f --best > #{destination}` }
  end

  desc "restore database"
  task :restore => :pg_setup do |t|
    backup_files = Dir.glob(File.join(@backup_folder,"*.sql.gz")).sort
    fail "no backup files (*.sql.gz) found in #{@backup_folder}" if backup_files.empty?
    backup_files.each_with_index{|f,i| puts "#{i+1}:#{File.basename(f)}"}
    selected_index = ask("Which file? ", Integer){|q| q.above = 0; q.below = backup_files.size+1}
    pgpassword_wrapper(@password){`cat #{backup_files[selected_index.to_i-1]} | gunzip | psql #{@pg_options}`}
  end

  desc 'clear expired sessions'
  task :clear_expired_sessions => :environment do
    sql = "DELETE FROM sessions WHERE updated_at < '#{Date.today - 1.day}'"
    ActiveRecord::Base.connection.execute(sql)
  end

  desc "remove accounts, example: rake db:remove_accounts['test1@email.com test2@email.com test3@email.com'] "
  task :remove_accounts, [:emails] => :environment do |task, args|
    emails = args[:emails].split(' ')

    Account.where(email: emails).each do |account|
      account.participants.destroy_all
      account.delete
    end
  end

  desc "de-identify current database"
  task de_id: :environment do
    if Rails.env.production?
      raise "Please don't run this in production."
    end

    ActiveRecord::Base.record_timestamps = false
    PaperTrail.enabled = false

    fail "I cannot, in good conscience, let you do this in production" if Rails.env.production?
    date_shift = rand(20).years + rand(20).month + rand(20).days
    batch_size = 2000

    puts "Processing #{Participant.count} participants in batches of #{batch_size}"
    Participant.find_in_batches(batch_size: batch_size).with_index do |group, batch|
      print "batch #{batch}..."
      group.each{|participant| de_id_participant(participant, date_shift)}
    end

    puts "Processing #{Account.count} accounts in batches of #{batch_size}"
    Account.find_in_batches(batch_size: batch_size).with_index do |group, batch|
      print "batch #{batch}..."
      group.each{|account| de_id_account(account, date_shift)}
    end
  end

  private

    def pgpassword_wrapper(password)
      # Unlike mysqldump, you don't enter in the password on the command line, you set an environment variable
      raise 'You need to pass in a block' unless block_given?
      begin
        ENV['PGPASSWORD'] = password
        yield
      ensure
        ENV['PGPASSWORD'] = nil
      end
    end

    def de_id_participant(participant, date_shift)
      participant.email             = Faker::Internet.email             unless participant.email.blank?
      participant.first_name        = Faker::Name.first_name            unless participant.first_name.blank?
      participant.last_name         = Faker::Name.last_name             unless participant.last_name.blank?
      participant.address_line1     = Faker::Address.street_address     unless participant.address_line1.blank?
      participant.address_line2     = Faker::Address.secondary_address  unless participant.address_line2.blank?
      participant.city              = Faker::Address.city               unless participant.city.blank?
      participant.state             = Faker::Address.state              unless participant.state.blank?
      participant.zip               = Faker::Number.number(5)           unless participant.zip.blank?

      phone_number = -> { "#{Faker::Number.number(3)}-#{Faker::Number.number(3)}-#{Faker::Number.number(4)}" }
      participant.primary_phone   = phone_number.call unless participant.primary_phone.blank?
      participant.secondary_phone = phone_number.call unless participant.secondary_phone.blank?

      participant.primary_guardian_first_name =
        Faker::Name.first_name  unless participant.primary_guardian_first_name.blank?
      participant.primary_guardian_last_name  =
        Faker::Name.last_name   unless participant.primary_guardian_last_name.blank?
      participant.primary_guardian_email =
        Faker::Internet.email   unless participant.primary_guardian_email.blank?
      participant.primary_guardian_phone =
        phone_number.call       unless participant.primary_guardian_phone.blank?
      participant.secondary_guardian_first_name =
        Faker::Name.first_name  unless participant.secondary_guardian_first_name.blank?
      participant.secondary_guardian_last_name  =
        Faker::Name.last_name   unless participant.secondary_guardian_last_name.blank?
      participant.secondary_guardian_email =
        Faker::Internet.email   unless participant.secondary_guardian_email.blank?
      participant.secondary_guardian_phone =
        phone_number.call       unless participant.secondary_guardian_phone.blank?
      participant.save!
    end

    def de_id_account(account, date_shift)
      account.email = Faker::Internet.email unless account.email.blank?
      account.save!
    end
end