module Gemgento
  class TouchCategory
    include Sidekiq::Worker
    sidekiq_options backtrace: true

    def perform(category_ids)
      Gemgento::Category.skip_callback(:save, :before, :create_magento_category)
      Gemgento::Category.skip_callback(:save, :before, :update_magento_category)

      Gemgento::Category.where(id: category_ids).each{ |c| c.update(updated_at: Time.now) }

      Gemgento::Category.set_callback(:save, :before, :create_magento_category)
      Gemgento::Category.set_callback(:save, :before, :update_magento_category)
    end
  end
end