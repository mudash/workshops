#
# Cookbook:: tomcat_install
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#
yum_package 'java-1.7.0-openjdk-devel'
yum_package 'wget'

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
end

group 'tomcat'

user 'tomcat' do
  manage_home false
  group 'tomcat'
  home '/opt/tomcat'
  shell '/bin/nologin'
end

directory '/opt/tomcat'

script 'install_tomcat_binary' do
  interpreter 'bash'
  user 'root'
  cwd '/tmp'
  code <<-EOH
  wget http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.29/bin/apache-tomcat-8.5.29.tar.gz
  tar xvf apache-tomcat-8.5.29.tar.gz -C /opt/tomcat --strip-components=1
  chgrp -R tomcat /opt/tomcat
  chmod -R g+r /opt/tomcat/conf
  chmod g+x /opt/tomcat/conf
  chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/
  EOH
end

execute 'reload_daemon' do
  command 'systemctl daemon-reload'
end

systemd_unit 'tomcat' do
  action [:start, :enable]
end
