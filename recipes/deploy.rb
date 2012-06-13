#
# Cookbook Name:: hello_app
# Recipe:: deploy
#
# Copyright 2012, Jason Grimes
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "hello_app::webserver" 

# Handle ssh key for git private repo
secrets = Chef::EncryptedDataBagItem.load("secrets", "hello_app")
if secrets["deploy_key"]
  ruby_block "write_key" do
    block do
      f = ::File.open("#{node['hello_app']['deploy_dir']}/id_deploy", "w")
      f.print(secrets["deploy_key"])
      f.close
    end
    not_if do ::File.exists?("#{node['hello_app']['deploy_dir']}/id_deploy"); end
  end

  file "#{node['hello_app']['deploy_dir']}/id_deploy" do
    mode '0600'
  end

  template "#{node['hello_app']['deploy_dir']}/git-ssh-wrapper" do
    source "git-ssh-wrapper.erb"
    mode "0755"
    variables("deploy_dir" => node['hello_app']['deploy_dir'])
  end
end

deploy_revision node['hello_app']['deploy_dir'] do
  scm_provider Chef::Provider::Git 
  repo node['hello_app']['deploy_repo']
  revision node['hello_app']['deploy_branch']
  if secrets["deploy_key"]
    git_ssh_wrapper "#{node['hello_app']['deploy_dir']}/git-ssh-wrapper" # For private Git repos 
  end 
  enable_submodules true
  shallow_clone false
  symlink_before_migrate({}) # Symlinks to add before running db migrations
  purge_before_symlink [] # Directories to delete before adding symlinks
  create_dirs_before_symlink ["config"] # Directories to create before adding symlinks
  symlinks({"config/local.config.php" => "config/local.config.php"})
  # migrate true
  # migration_command "php app/console doctrine:migrations:migrate" 
  action :deploy
  restart_command do
    service "apache2" do action :restart; end
  end
end
