if defined? Rails
  module APN
    class Railtie < Rails::Railtie
      config.before_initialize do
        require 'configatron'

        configatron.apn.set_default(:passphrase, '')
        configatron.apn.set_default(:port, 2195)

        configatron.apn.feedback.set_default(:passphrase, configatron.apn.passphrase)
        configatron.apn.feedback.set_default(:port, 2196)

        configatron.apn.production.gateway.set_default(:host, 'gateway.push.apple.com')
        configatron.apn.production.feedback.set_default(:host, 'feedback.push.apple.com')

        configatron.apn.development.gateway.set_default(:host, 'gateway.sandbox.push.apple.com')
        configatron.apn.development.feedback.set_default(:host, 'feedback.sandbox.push.apple.com')

        if Rails.env == 'production'
          configatron.apn.set_default(:host, configatron.apn.production.gateway.host)
          configatron.apn.feedback.set_default(:host, configatron.apn.production.feedback.host)
        else
          configatron.apn.set_default(:host, configatron.apn.development.gateway.host)
          configatron.apn.feedback.set_default(:host, configatron.apn.development.feedback.host)
        end

        %w{models controllers helpers}.each do |dir| 
          path = File.expand_path("#{File.dirname(__FILE__)}/../app/#{dir}")
          next unless File.directory? path

          $LOAD_PATH << path 
          begin
            if ActiveSupport::Dependencies.respond_to? :autoload_paths
              ActiveSupport::Dependencies.autoload_paths << path
              ActiveSupport::Dependencies.autoload_once_paths.delete(path)
            else
              ActiveSupport::Dependencies.load_paths << path 
              ActiveSupport::Dependencies.load_once_paths.delete(path) 
            end
          rescue NameError
            Dependencies.load_paths << path 
            Dependencies.load_once_paths.delete(path) 
          end
        end
      end
    end
  end
end
