module Gemgento
  class InstallGenerator < Rails::Generators::Base

    desc 'Copies migrations to your application.'
    def copy_migrations
      rake('gemgento:install:migrations')
    end

    desc 'Add the Gemgento routes'
    def add_routes
      route "mount Gemgento::Engine, at: '/'"
    end

    desc 'Include the Gemgento::ApplicationHelper'
    def include_application_helper
      inject_into_file Rails.root.join('app', 'controllers', 'application_controller.rb'), before: 'class ApplicationController' do <<-'RUBY'
include Gemgento::ApplicationHelper

      RUBY
      end
    end

  end
end