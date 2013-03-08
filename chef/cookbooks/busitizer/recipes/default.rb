#
# Cookbook Name:: busitizer
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "database"
include_recipe "python"

postgresql_connection_info = {:host => "127.0.0.1",
                              :port => node['postgresql']['config']['port'],
                              :username => 'postgres',
                              :password => node['postgresql']['password']['postgres']}

postgresql_database 'busitizer' do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user 'busitizer' do
  connection postgresql_connection_info
  password 'hobbits'
  action :create
end

postgresql_database_user 'busitizer' do
  connection postgresql_connection_info
  database_name 'busitizer'
  privileges [:all]
  action :grant
end


user "busitizer" do
  action :create
  system true
end

directory "/var/venv" do
	owner "busitizer"
	group "www-data"
	mode 00744
	action :create
end

python_virtualenv "/var/venv" do
  options "--system-site-packages"
  action :create
  owner "busitizer"
  group "www-data"
end

package "libpq-dev"do
	action :install
end
package "libjpeg-dev"do
	action :install
end
package "libpng12-dev"do
	action :install
end
package "memcached" do
	action :install
end
package "libmemcached-dev" do
	action :install
end

execute "install_requirements" do
	cwd "/www/busitizer"
	path ["/var/venv/bin"]
	environment ({'VIRTUAL_ENV' => '/var/venv', 'HOME' => '/tmp/.pip'})
	command "/var/venv/bin/pip install -r requirements.txt"
	user "busitizer"
end

execute "sync_db" do
	cwd "/www/busitizer"
	path ["/var/venv/bin"]
	environment ({'VIRTUAL_ENV' => '/var/venv', 'HOME' => '/tmp/.pip'})
	command "/var/venv/bin/python manage.py syncdb --noinput"
	user "busitizer"
end
