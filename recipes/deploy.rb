require 'erb'

after 'deploy:setup', 'deploy:create_shared_config_dir'
after "deploy:setup", "deploy:db:create_config"
after "deploy:setup", "deploy:set_file_permissions"
after "deploy:update_code", "deploy:db:symlink_config"
after "deploy:update_code", "deploy:build_photos_symlink"

namespace :deploy do
  namespace :db do
    desc "Runs rake db:create on remote server"
    task :create do
      run "cd #{current_path} && #{app_framework}_ENV=#{mongrel_environment} rake db:create"
    end
    
    desc "Auto-generate production database.yml"
    task :create_config do
      db_config = ERB.new <<-EOF
      production:
        adapter: mysql
        database: forward_fab_production
        username: #{db_user}
        password: #{db_password}
        host: localhost
      EOF
      put db_config.result, "#{shared_config_path}/database.yml"
    end
    
    desc "Create a symlink to the database yaml file"
    task :symlink_config do
      run "ln -s #{shared_config_path}/database.yml #{release_path}/config/database.yml"
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
  
  desc "Copy production database.yml to live app"
  task :copy_config_files do    
    config_files.each do |file|
      run "cp #{shared_path}/config/#{file} #{release_path}/config/"
    end
  end
  
  desc "Builds a symlink from public/photos to the shared photos directory"
  task :build_photos_symlink do
    run "ln -s #{shared_path}/system/photos #{release_path}/public/photos"
  end
end