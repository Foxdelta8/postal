namespace :postal do

  desc "Start the backend job worker"
  task :worker => :environment do
    Postal::Worker.new([:main]).work
  end

  desc "Start the cron worker"
  task :cron => :environment do
    require 'clockwork'
    require Rails.root.join('config', 'cron')
    trap('TERM') { puts "Exiting..."; Process.exit(0) }
    Clockwork.run
  end

  desc 'Start SMTP Server'
  task :smtp_server => :environment do
    Postal::SMTPServer::Server.new(:debug => true).run
  end

  desc 'Start the message requeuer'
  task :requeuer => :environment do
    Postal::MessageRequeuer.new.run
  end

  desc 'Run all migrations on message databases'
  task :migrate_message_databases => :environment do
    Server.all.each do |server|
      puts "\e[35m-------------------------------------------------------------------\e[0m"
      puts "\e[35m#{server.id}: #{server.name} (#{server.permalink})\e[0m"
      puts "\e[35m-------------------------------------------------------------------\e[0m"
      server.message_db.provisioner.migrate
    end
  end

  desc 'Start the fast server'#
  task :fast_server => :environment do
    Postal::FastServer::Server.new.run
  end

end
