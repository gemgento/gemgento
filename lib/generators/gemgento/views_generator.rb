module Gemgento
  class ViewsGenerator < Rails::Generators::Base

    desc 'Copies migrations to your application.'
    def copy_views
      FileUtils.cp_r Gemgento::Engine.root.join('app', 'views', 'gemgento'), Rails.application.root.join('app', 'views')
    end

  end
end