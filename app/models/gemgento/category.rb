module Gemgento
  class Category < ActiveRecord::Base
    has_many :assets

    def self.index
      if Category.find(:all).size == 0
        fetch_all
      end
      Category.find(:all)
    end

    def self.fetch_all
      client = Gemgento::Magento.api_login
      response = client.call(:catalog_product_list, message: {:sessionId => @session})
      if response.success?
        #puts 'response.body=' + response.body[:catalog_product_list_response].inspect
        response.body[:catalog_product_list_response][:store_view][:item].each_with_index do |product, i|
          info_response = client.call(:catalog_product_info, message: {:sessionId => @session, :product => product[:product_id], :productIdentifierType => 'id'})
          #puts info_response.inspect
          p = Product.create
          p.magento_id = info_response.body[:catalog_product_info_response][:info][:product_id]
          p.magento_type = info_response.body[:catalog_product_info_response][:info][:type]
          p.name = info_response.body[:catalog_product_info_response][:info][:name]
          p.url_key = info_response.body[:catalog_product_info_response][:info][:url_key]
          p.price = info_response.body[:catalog_product_info_response][:info][:price]
          p.save

          image_response = client.call(:catalog_product_attribute_media_list, message: {:sessionId => @session, :product => product[:product_id], :productIdentifierType => 'id'})
          #puts image_response.body.inspect
          if image_response.body[:catalog_product_attribute_media_list_response][:result][:item] != nil &&

              if image_response.body[:catalog_product_attribute_media_list_response][:result][:item].size > 1

                image_response.body[:catalog_product_attribute_media_list_response][:result][:item].each_with_index do |img, i|
                  create_asset(img, p)
                end

              else
                img = image_response.body[:catalog_product_attribute_media_list_response][:result][:item]
                create_asset(img, p)
              end

          end
        end
      end
    end

  end
end