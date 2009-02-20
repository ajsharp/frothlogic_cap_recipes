# Capistrano recipes for an Apache Passenger app server
namespace :passenger do
  desc "Restart the rails app"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
