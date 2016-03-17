module Gemgento
  module MagentoAdapter
    extend ActiveSupport::Concern

    class_methods do
      def filters(attributes)
        filters = { filter: { item: [] } }

        attributes.each do |key, val|
          filters[:filter][:item] << { key: key, value: val }
        end

        return filters
      end
    end
  end
end