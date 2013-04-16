require 'rubygems'
require 'savon'
client = Savon.client(wsdl: "http://madelineweinrib.mauinewyork.com/api/soap/index?wsdl", log: false)
response = client.call(:login, message: { :username => 'philip.vasilevski', :apiKey => '857123FHDShfd' })
if response.success? == false
  puts "login failed"
  System.exit(0)
end
session = response.body[:login_response][:login_return];
response = client.call(:call, message: {:sessionId => session, :resourcePath => 'catalog_product.list'})
 # fetching all products
if response.success?
  # listing found products
  response.body[:call_response][:call_return][:item].each do |product|
    puts "-------------------------------------------"
    product = product[:item]
    product.each do |pkey|
      puts "#{pkey[:key]} -> #{pkey[:value]}"
    end
  end
end
