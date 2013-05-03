module Gemgento
  class Product < ActiveRecord::Base
    has_many :assets

    def self.index
      if Product.find(:all).size == 0
        fetch_all
      end
      Product.find(:all)
    end

    def self.fetch_all
      response = Gemgento::Magento.create_call(:catalog_product_list, { sessionId: @session })
      #puts 'response.body=' + response.body[:catalog_product_list_response].inspect
      response.body[:catalog_product_list_response][:store_view][:item].each_with_index do |product, i|
        info_response = Gemgento::Magento.create_call(:catalog_product_info, { product: product[:product_id], productIdentifierType: 'id' })
        #puts info_response.inspect
        p = Product.create
        p.magento_id = info_response.body[:catalog_product_info_response][:info][:product_id]
        p.magento_type = info_response.body[:catalog_product_info_response][:info][:type]
        p.name = info_response.body[:catalog_product_info_response][:info][:name]
        p.url_key = info_response.body[:catalog_product_info_response][:info][:url_key]
        p.price = info_response.body[:catalog_product_info_response][:info][:price]
        p.save

        image_response = Gemgento::Magento.create_call(:catalog_product_attribute_media_list, { product: product[:product_id], productIdentifierType: 'id' })
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

    def self.create_asset(img, p)
      puts 'IMG?: '+img.inspect
      a = Gemgento::Asset.new
      a.url = img[:url]
      a.position = img[:position]
      a.product_id = p.id
      a.save
    end

  end
end