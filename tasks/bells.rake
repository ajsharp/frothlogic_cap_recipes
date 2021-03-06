namespace :bells do
  desc "Generate Capfile with Bells presets in it already."
  task :generate_capfile do
    if File.file? "Capfile"
      puts "=> Backing up old Capfile..."
      FileUtils.copy("Capfile", "Capfile.old")
    end
    
    puts "=> Creating Capfile..."
    exec "cp #{File.dirname(__FILE__)}/../recipes/templates/Capfile #{File.dirname(__FILE__)}/../../../../Capfile"
  end
end