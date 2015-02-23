module Gemgento
  module Bundle

    # @author Gemgento LLC
    class Option < ActiveRecord::Base
      belongs_to :product, class_name: 'Gemgento::Product'

      has_many :items, class_name: 'Gemgento::Bundle::Item', dependent: :destroy
      has_many :products, through: :items, class_name: 'Gemgento::Product'

      validates :product, presence: true
    end
  end
end