module Gemgento
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc 'Copies migrations to your application.'

    def copy_migrations
      rake('gemgento:install:migrations')
    end

    desc 'Add the Gemgento routes'

    def add_routes
      # routes are inserted in reverse
      route "mount Gemgento::Engine, at: '/'"
      route 'ActiveAdmin.routes(self)'
      route 'devise_for :admin_users, ActiveAdmin::Devise.config'
    end

    desc 'Include the Gemgento::ApplicationHelper'

    def include_application_helper
      inject_into_file Rails.root.join('app', 'controllers', 'application_controller.rb'), before: 'class ApplicationController' do
        <<-'RUBY'
include Gemgento::ApplicationHelper

        RUBY
      end
    end

    desc 'Create default active admin assets'

    def create_active_admin_assets
      template 'active_admin.rb', 'config/initializers/active_admin.rb'
      template 'active_admin.css.scss', 'app/assets/stylesheets/active_admin.css.scss'
      template 'active_admin.js.coffee', 'app/assets/javascripts/active_admin.js.coffee'
    end

  end
end