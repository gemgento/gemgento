require 'rails/engine'

module Gemgento
  class Engine < Rails::Engine
    isolate_namespace Gemgento
    engine_name 'gemgento'

    config.autoload_paths += %W(#{config.root}/lib)
    
    # load decorators
    config.to_prepare do
      Dir.glob(Rails.root + 'app/decorators/**/*_decorator*.rb').each do |c|
        require_dependency(c)
      end
    end

    initializer :gemgento do

      # Include application specific Active Admin resources
      ActiveAdmin.application.load_paths << File.dirname(__FILE__) + '/admin'

      # allow custom queries to sanitize inputs
      class ActiveRecord::Base
        def self.escape_sql(clause, *rest)
          self.send(:sanitize_sql_array, rest.empty? ? clause : ([clause] + rest))
        end
      end

    end

    ## BREAKING CHANGE - INCLUDE IN 2.0 ###
    # Append migrations direction to Application
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    # filter logging of sensitive fields
    initializer 'gemgento.params.filter' do |app|
      app.config.filter_parameters += [
          :cc_owner,
          :cc_number,
          :cc_cid,
          :cc_exp_month,
          :cc_exp_year
      ]
    end

  end
end