module Gemgento
  class TouchWorker
    include Sidekiq::Worker
    sidekiq_options backtrace: true

    def perform(klass, ids)
      klass = klass.constantize
      klass.where(id: ids).each{ |k| k.update(updated_at: Time.now) }
    end
  end
end