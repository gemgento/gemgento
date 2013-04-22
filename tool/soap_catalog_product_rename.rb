require 'rubygems'
require 'savon'
client = Savon.client(wsdl: "http://mw.local/index.php/api/v2_soap?wsdl=1", log: true)
response = client.call(:login, message: { :username => 'philip.vasilevski', :apiKey => '857123FHDShfd' })
if response.success? == false
  puts "login failed"
  System.exit(0)
end
session = response.body[:login_response][:login_return];
response = client.call(:catalog_product_list, message: {:sessionId => session})
if response.success?
  response.body[:catalog_product_list_response][:store_view][:item].each_with_index do |product, i|
    info_response = client.call(:catalog_product_info, message: {:sessionId => session, :product => 17569, :productIdentifierType => 'id', :attributes => ['color','design','quality']})
    product_type = info_response.body[:catalog_product_info_response][:info][:type]
    if product_type == 'simple'      
      color = info_response.body[:catalog_product_info_response][:info][:additional_attributes][:item][0][:value]
      quality = info_response.body[:catalog_product_info_response][:info][:additional_attributes][:item][1][:value]
      design = info_response.body[:catalog_product_info_response][:info][:additional_attributes][:item][2][:value]      
      puts color+' -- '+design+' -- '+quality
      update_response = client.call(:catalog_product_update, message: {:sessionId => session, :product => 17569, :productIdentifierType => 'id', :productData => {:name => color+' '+design+' '+quality}})      
    end
  end
end