require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module YouthMatchV2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = :sidekiq


    KNOWN_HOSTS = ENV.fetch('KNOWN_HOSTS') {
      'http://lvh.me:5000,http://localhost:4200'
    }
    DEBUG_CORS  = ENV.fetch('DEBUG_CORS', false)

    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride

    config.autoload_paths << "#{Rails.root}/app/jobs/concerns"

    config.middleware.insert_before 0, Rack::Cors,
      debug:  DEBUG_CORS,
      logger: (-> { Rails.logger }) do
        allow do
          origins  KNOWN_HOSTS.split(',')
          resource '*', headers: :any, methods: %i( get post put patch delete )
        end
      end
  end
end
