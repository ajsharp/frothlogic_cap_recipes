require 'erb'

after 'deploy:setup', 'deploy:create_shared_config_dir'
after "deploy:setup", "deploy:db:create_config"
# after "deploy:setup", "deploy:set_file_permissions"
after "deploy:update_code", "deploy:db:symlink_config"
# after "deploy:update_code", "mongrel:create_config_file_symlink"
after "deploy:symlink", "deploy:build_public_symlinks"
after "deploy:symlink", "deploy:restart"

namespace :deploy do
  namespace :db do
    desc "Runs rake db:create on remote server"
    task :create do
      run "cd #{current_path} && #{app_framework}_ENV=#{app_environment} rake db:create"
    end
    
    desc "Auto-generate production database.yml"
    task :create_config do
      db_config = ERB.new <<-EOF
      production:
        adapter: mysql
        database: #{db_name}
        username: #{db_user}
        password: #{db_password}
        host: localhost
      EOF
      put db_config.result, "#{shared_config_path}/database.yml"
    end
    
    desc "Create a symlink to the database yaml file"
    task :symlink_config do
      run "ln -nfs #{shared_config_path}/database.yml #{release_path}/config/database.yml"
    end
  end

  task :restart do
    eval("#{app_server.to_s}.restart")
  end
  
  task :start do
    eval("#{app_server.to_s}.start")
  end
  
  task :stop do
    eval("#{app_server.to_s}.stop")
  end

  desc "Shows tail of production log"
  task :tail do
    stream "tail -f #{current_path}/log/#{app_environment}.log"
  end
  
  desc "Creates the shared config file directory"
  task :create_shared_config_dir do
    run "mkdir -p #{shared_config_path}"
  end
  
  # These symlink any project-specific directories that need to be consistent between deploys (file upload directories, etc)
  task :build_public_symlinks do
    unless public_symlink_dirs.nil?
      public_symlink_dirs.each do |dir|
        run "mkdir -p #{shared_path}/system/#{dir}"
        run "ln -nfs #{shared_path}/system/#{dir} #{release_path}/public/#{dir}"
      end
    end
  end
end