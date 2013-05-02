require 'rubygems'
require 'savon'
require 'spreadsheet'
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
file = '/Users/philipvasilevski/gemgento/tool/xls/mw_collections_04122013.xlsx'
@worksheet = Spreadsheet.open(file).worksheet(0)
#@headers = get_headers(@worksheet)
@msgs = []
@product_count = 0
# first process of worksheet
1.upto @worksheet.last_row_index do |index|
  next if @worksheet.row(index)[0].nil? && @worksheet.row(index)[1].nil?
  puts @worksheet.row(index)[0]
end 
