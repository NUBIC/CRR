# Communication Research Registry Application
[Communication Research Registry Software](https://commresearchregistry.soc.northwestern.edu/for-developers/) - Additional information for developers

## Prerequisites

Application:
* ruby 2.1.2
* Bundler (install as a gem)
* PostgreSQL

Testing:
* chromedriver

## Configuration and Setup
### Set up config files
create /etc/nubic/db/crr.yml

```yaml

development:
  adapter: postgresql
  host: localhost
  port: 5432
  database: audiology
  username: <username>
  password:
  timeout: 0

test: &test
  adapter: postgresql
  host: localhost
  port: 5432
  database: audiology_test
  username: <username>
  password:

cucumber:

  <<: *test
```

create /etc/nubic/ldap-crr.yml

```yaml

## Authorizations
# Uncomment out the merging for each enviornment that you'd like to include.
# You can also just copy and paste the tree (do not include the "authorizations") to each
# enviornment if you need something different per enviornment.
authorizations: &AUTHORIZATIONS
  # group_base: ou=groups,dc=test,dc=com
  # ## Requires config.ldap_check_group_membership in devise.rb be true
  # # Can have multiple values, must match all to be authorized
  # required_groups:
  #   - cn=admins,ou=groups,dc=test,dc=com
  #   - cn=users,ou=groups,dc=test,dc=com
  ## Requires config.ldap_check_attributes in devise.rb to be true
  ## Can have multiple attributes and values, must match all to be authorized
  # require_attribute:
  #   objectClass: inetOrgPerson
  #   authorizationRole: postsAdmin

## Environments

development:
  host: localhost
  port: 3389
  attribute: cn
  base: ou=people,dc=test,dc=com
  admin_user: cn=admin,dc=test,dc=com
  admin_password: secret
  ssl: false

test:
  host: localhost
  port: 3389
  attribute: cn
  base: ou=people,dc=test,dc=com
  admin_user: cn=admin,dc=test,dc=com
  admin_password: secret
  ssl: false
```

### Install bundled gems and setup database

```console
$ bundle install
$ bundle exec rake db:create
$ bundle exec rake db:migrate
```

### Setup local LDAP

Having local LDAP running is handy for development and testing purposes. Modify 'lib/ldap/base.ldif' to set up a password for a test_user or add more users


Run the following to create LDAP records:
```console
$rake ldap:insert
```

To start the LDAP server
```console
$rake ldap:start
``

### Create admin user record in the database

```console
$ bundle exec rails console
```
```ruby
u = User.new(netid: "test_user", admin: true, researcher: false, data_manager: false, first_name: "Test", last_name: “User”)
u.save!
quit
```

## Testing
```console
$ bundle exec rspec
```

## Deployment
We use one-user deployment strategy.

  First-time deployment:
  - generate id_rsa.pub key if does not exist
  - ssh to application host (staging host in this example):
  - create authorized_keys list in .ssh directory of the deployer user
```console
  $ sudo su - crr-runner
  $ mkdir .ssh
  $ cd .ssh/
  $ touch authorized_keys
```
  - copy content of id_rsa.pud key from developer's machine to the authorized_keys file
  - test by ssh-ing to application host machine under deployer user (it should not ask for password if set up correctly):
```console
  cap staging deploy:setup
  cap staging deploy
