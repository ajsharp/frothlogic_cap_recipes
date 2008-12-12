# Recipe adapted from deprec gem
namespace :mongrel do
  desc <<-DESC
  Configure Mongrel processes on the app server. This uses the :use_sudo
  variable to determine whether to use sudo or not. By default, :use_sudo is
  set to true.
  DESC
  task :configure, :roles => :app do
    set_mongrel_conf

    argv = []
    argv << "mongrel_rails cluster::configure"
    argv << "-N #{app_servers.to_s}"
    argv << "-p #{app_server_port.to_s}"
    argv << "-e #{app_environment}"
    argv << "-a #{app_server_address}"
    argv << "-c #{current_path}"
    argv << "-l #{shared_path}/log/mongrel.log"
    argv << "-P #{shared_path}/pids/mongrel.pid"
    argv << "--user #{user}"
    group ||= user
    argv << "--group #{app_server_group}"
    argv << "-C #{app_server_conf}"
    cmd = argv.join " "
    run cmd
  end

  desc <<-DESC
  Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
  set to true.
  DESC
  task :start , :roles => :app do
    set_mongrel_conf
    run "mongrel_rails cluster::start -C #{app_server_conf}"
  end

  desc <<-DESC
  Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
  variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
  DESC
  task :restart, :roles => :app do
    set_mongrel_conf
    run "mongrel_rails cluster::stop -C #{app_server_conf}"
    run "mongrel_rails cluster::start -C #{app_server_conf}"
  end
  
  desc "does a sudo mongrel_cluster_ctl restart"
  task :restart_all, :roles => :app do
    sudo "mongrel_cluster_ctl restart"
  end

  desc <<-DESC
  Stop the Mongrel processes on the app server.  This uses the :use_sudo
  variable to determine whether to use sudo or not. By default, :use_sudo is
  set to true.
  DESC
  task :stop , :roles => :app do
    set_mongrel_conf
    run "mongrel_rails cluster::stop -C #{app_server_conf}"
  end
  
  desc "creates a symlink from 'current_path/config/mongrel_cluster.yml to shared_path/config/mongrel_cluster.yml"
  task :create_config_file_symlink do
    run "ln -nfs #{shared_config_path}/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml"
  end

  def set_mongrel_conf
    set :app_server_conf, "/etc/mongrel_cluster/#{application}.yml" unless app_server_conf
  end
end
