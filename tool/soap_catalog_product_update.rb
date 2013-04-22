require 'rubygems'
require 'savon'
client = Savon.client(wsdl: "http://mw.local/index.php/api/v2_soap?wsdl=1", log: true)
response = client.call(:login, message: { :username => 'philip.vasilevski', :apiKey => '857123FHDShfd' })
if response.success? == false
  puts "login failed"
  System.exit(0)
end
session = response.body[:login_response][:login_return];
update_response = client.call(:catalog_product_update, message: {:sessionId => session, :product => 17569, :productIdentifierType => 'id', :productData => {:name => 'test product name'}})

puts update_response.body
