require 'rails/engine'

module Gemgento
  class Engine < ::Rails::Engine
    isolate_namespace Gemgento
    engine_name 'gemgento'

    config.autoload_paths += %W(#{config.root}/lib)

  end
end