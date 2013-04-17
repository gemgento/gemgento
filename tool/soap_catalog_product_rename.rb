require 'rubygems'
require 'savon'
client = Savon.client(wsdl: "http://madelineweinrib.mauinewyork.com/api/soap/index?wsdl", log: true)
response = client.call(:login, message: { :username => 'philip.vasilevski', :apiKey => '857123FHDShfd' })
if response.success? == false
  puts "login failed"
  System.exit(0)
end
session = response.body[:login_response][:login_return];
response = client.call(:call, message: {:sessionId => session, :resourcePath => 'catalog_product.list'})
if response.success?
  response.body[:call_response][:call_return][:item].each_with_index do |product, i|
    if i == 0
      product = product[:item]
      product.each do |p|
        if p[:key] == 'sku'
          
          info_response = client.call(:call, message: {:sessionId => session, :resourcePath => 'catalog_product.info', :productId => p[:value]})
          
          puts info_response.inspect
          
        end
      end
    end
  end
end
