module Gemgento
  class InstallGenerator < Rails::Generators::Base

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
      inject_into_file Rails.root.join('app', 'controllers', 'application_controller.rb'), before: 'class ApplicationController' do <<-'RUBY'
include Gemgento::ApplicationHelper

      RUBY
      end
    end

    desc 'Create default active admin assets'

    def create_active_admin_assets
      create_file 'app/assets/stylesheets/active_admin.css.scss', '// Custom ActiveAdmin CMS styling goes here'
      create_file 'app/assets/javascripts/active_admin.js.coffee', '# Custom ActiveAdmin CMS javascript goes here'
    end

  end
end