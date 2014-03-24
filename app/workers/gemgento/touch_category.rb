module Gemgento
  class TouchCategory
    include Sidekiq::Worker

    def perform(category_ids)
      Gemgento::Category.skip_callback(:save, :after, :sync_local_to_magento)
      Gemgento::Category.where(id: category_ids).update_all(updated_at: Time.now)
      Gemgento::Category.set_callback(:save, :after, :sync_local_to_magento)
    end
  end
end