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
end