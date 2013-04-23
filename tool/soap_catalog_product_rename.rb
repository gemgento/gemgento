require 'rubygems'
require 'savon'
wsdl_host = 'http://madelineweinrib.mauinewyork.com/index.php/api/v2_soap?wsdl=1'
username = 'philip.vasilevski'
api_key = '857123FHDShfd'
client = Savon.client(wsdl: wsdl_host, log: true)
response = client.call(:login, message: { :username => username, :apiKey => api_key })
if response.success? == false
  puts "login failed"
  System.exit(0)
end
count = 0
session = response.body[:login_response][:login_return];
response = client.call(:catalog_product_list, message: {:sessionId => session})
if response.success?
  response.body[:catalog_product_list_response][:store_view][:item].each_with_index do |product, i|
    info_response = client.call(:catalog_product_info, message: {:sessionId => session, :product => product[:product_id], :productIdentifierType => 'id', :attributes => ['color','design','quality']})
    product_type = info_response.body[:catalog_product_info_response][:info][:type]
    if product_type == 'simple'      
      color = info_response.body[:catalog_product_info_response][:info][:additional_attributes][:item][0][:value]
      quality = info_response.body[:catalog_product_info_response][:info][:additional_attributes][:item][1][:value]
      design = info_response.body[:catalog_product_info_response][:info][:additional_attributes][:item][2][:value]      
      if color.class.name == "Nori::StringWithAttributes"
        count += 1
        puts count.to_s+". -- "+color+' -- '+design+' -- '+quality      
        update_response = client.call(:catalog_product_update, message: {:sessionId => session, :product => product[:product_id], :productIdentifierType => 'id', :productData => {:name => color+' '+design+' '+quality}})      
      end
    end
  end
end