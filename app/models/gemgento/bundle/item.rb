module Gemgento
  module Bundle

    # @author Gemgento LLC
    class Item < ActiveRecord::Base
      belongs_to :option, class_name: 'Gemgento::Bundle::Option'
      belongs_to :product, class_name: 'Gemgento::Product'

      validates :option, :product, presence: true
      validates :product, uniqueness: { scope: :product }
    end
  end
end