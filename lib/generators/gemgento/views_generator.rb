module Gemgento
  class ViewsGenerator < Rails::Generators::Base

    desc 'Copies migrations to your application.'
    def copy_views
      FileUtils.cp_r Gemgento::Engine.root.join('app', 'views'), Rails.application.root.join('app')
    end

  end
end