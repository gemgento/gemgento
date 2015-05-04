module Gemgento
  class TouchCategory
    include Sidekiq::Worker
    sidekiq_options backtrace: true

    def perform(category_ids)
      Gemgento::Category.skip_callback(:save, :after, :sync_local_to_magento)
      Gemgento::Category.where(id: category_ids).each{ |c| c.update(updated_at: Time.now) }
      Gemgento::Category.set_callback(:save, :after, :sync_local_to_magento)
    end
  end
end