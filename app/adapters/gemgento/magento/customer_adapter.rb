class Gemgento::Magento::CustomerAdapter

  def self.find_by(attributes)
    response = Gemgento::API::SOAP::Customer::Customer.list filters(attributes)

    if response.body_overflow[:store_view].first[:item]

      if response.body_overflow[:store_view].first[:item].is_a? Array
        return response.body_overflow[:store_view].first[:item].first

      else
        return response.body_overflow[:store_view].first[:item]
      end

    else
      return nil
    end
  end

  def self.filters(attributes)
    filters = { filter: { item: [] } }

    attributes.each do |key, val|
      filters[:filter][:item] << { key: key, value: val }
    end

    return filters
  end

end
