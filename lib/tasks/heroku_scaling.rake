require 'platform-api'

namespace :heroku_scaling do
  APP_NAME = 'dropbox-accounts'

  task :set_workers, [:workers] => :environment do |_, args|
    heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_API_TOKEN'])
    heroku.formation.update(APP_NAME, 'worker', {"quantity" => args[:workers].to_i.to_s})
  end

  task :size_by_task => :environment do
    if has_tasks?
      redis.set('last_run', '1')

      heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_API_TOKEN'])
      heroku.formation.update(APP_NAME, 'worker', { 'quantity' => '1' })
    else
      # wait for two intervals without events before shutting down sidekiq
      if redis.get('last_run') == '0'
        heroku = PlatformAPI.connect_oauth(ENV['PLATFORM_API_TOKEN'])
        heroku.formation.update(APP_NAME, 'worker', { 'quantity' => '0' })
      end
      redis.set('last_run', '0')
    end
  end

  def redis
    @redis ||= Redis.new(url: ENV["REDIS_URL"])
  end

  def has_tasks?
    return true unless Sidekiq::Queue.all.sum(&:size).zero?
    ps = Sidekiq::ProcessSet.new
    ps.each do |process|
      return true unless process['busy'].zero?
    end
    false
  end
end
