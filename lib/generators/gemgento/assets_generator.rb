module Gemgento
  class AssetsGenerator < Rails::Generators::Base

    desc 'Copies migrations to your application.'
    def copy_views
      FileUtils.cp_r Gemgento::Engine.root.join('app', 'assets', 'javascripts', 'gemgento'), Rails.application.root.join('app', 'assets', 'javascripts')
      FileUtils.cp_r Gemgento::Engine.root.join('app', 'assets', 'stylesheets', 'gemgento'), Rails.application.root.join('app', 'assets', 'stylesheets')
    end

  end
end