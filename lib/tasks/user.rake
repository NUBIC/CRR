namespace :users do
  desc 'update users from ldap'
  task :ldap_update => :environment do
    User.all.each do |user|
      ldap_user = Devise::LDAP::Adapter.get_ldap_entry(user.netid)
      if ldap_user
        user.update_attributes(first_name: ldap_user.givenname.first, last_name: ldap_user.sn.first, email: ldap_user.mail.first)
      else
        puts "user could not be found in LDAP directory: #{user.netid}"
      end
    end
  end
end

