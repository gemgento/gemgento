require 'rubygems'
require 'savon'
client = Savon.client(wsdl: "http://dev.oliverpeoples.com/api/v2_soap/index?wsdl", log: true)
response = client.call(:login, message: { :username => 'maui', :apiKey => '857123FHDShfd' })
if response.success? == false
  puts "login failed"
  System.exit(0)
end
puts response.body.inspect
session = response.body[:login_response][:login_return];
response = client.call(:catalog_product_list, message: {:sessionId => session})
if response.success?
  #puts 'response.body=' + response.body[:catalog_product_list_response].inspect
  response.body[:catalog_product_list_response][:store_view][:item].each_with_index do |product, i|
    if i == 100      
      info_response = client.call(:catalog_product_info, message: {:sessionId => session, :product => product[:product_id]+ ' ', :productIdentifierType => 'id'})
      puts info_response.inspect          

    end
  end
end
