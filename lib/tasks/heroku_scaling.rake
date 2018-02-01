require 'platform-api'

namespace :heroku_scaling do
  task :set_workers, [:workers] => :environment do |_, args|
    APP_NAME = 'dropbox-accounts'

    heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_API_TOKEN'])
    heroku.formation.update(APP_NAME, 'worker', {"quantity" => args[:workers].to_i.to_s})
  end
end
