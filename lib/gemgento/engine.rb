require 'rails/engine'

module Gemgento
  class Engine < ::Rails::Engine
    isolate_namespace Gemgento
    engine_name 'gemgento'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer :gemgento do

      if defined?(ActiveAdmin)
        ActiveAdmin.application.load_paths << File.dirname(__FILE__) + '/admin/'
      end

      class ActiveRecord::Base
        def self.escape_sql(clause, *rest)
          self.send(:sanitize_sql_array, rest.empty? ? clause : ([clause] + rest))
        end
      end
    end
  end
end