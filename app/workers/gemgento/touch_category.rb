module Gemgento
  class TouchCategory
    include Sidekiq::Worker
    sidekiq_options backtrace: true

    def perform(category_ids)
      Gemgento::Category.where(id: category_ids).each do |category|
        related_category_ids = category.ancestors.map(&:id) + category.descendents.map(&:id)
        Gemgento::Category.where(id: related_category_ids).update_all(updated_at: category.updated_at)
      end
    end
  end
end