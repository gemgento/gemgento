require 'rubygems'
require 'savon'
require 'spreadsheet'

# api variables
wsdl_host = 'http://mw.local/index.php/api/v2_soap?wsdl=1'
username = 'philip.vasilevski'
api_key = '857123FHDShfd'

path_to_spreadsheet = '/Users/Kevin/Downloads/mw_collections_04122013.xls'
product_groupings = Hash.new

# hard coded magento variables
attribute_set_id = 4
store_view_id = 1

# API call to get a category level
def catalogCategoryLevel(parent_id = 0)
  level = Hash.new

  category_response = @client.call(:catalog_category_level, message:{ sessionId: @session, parentId: parent_id })
  category_response.body[:catalog_category_level_response][:tree][:item].each do |category|
    level["#{category[:name]}"] = category
  end

  level
end

# Get a category id for a category by name
def getCategoryIdByName(type, parent_name, child_name)
  type_level = catalogCategoryLevel(@top_level_categories[type][:category_id])
  parent_category = searchLevelForName(type_level, parent_name)

  parent_level = catalogCategoryLevel(parent_category[:category_id])
  child_category = searchLevelForName(parent_level, child_name)

  if child_category
    child_category[:category_id]
  else
    catalog_category_create(child_name, parent_category[:category_id])
  end
end

# Return the category if found or nil
def searchLevelForName(category_level, name)
  category_level.each do |category|
    if category[:name] == name
      category
      break;
    end
  end
end

# API call to create a new category
def catalog_category_create(name, parent_id = 1)
    response = @client.call(:catalog_category_create, message: {sessionId: @session, parentId: parent_id, categoryData: {
      name: name,
      is_active: 1
    }})

  response.body[:catalog_category_create_response][:info][:category_id]
end

# get a connection
@client = Savon.client(wsdl: wsdl_host, log: true)
response = @client.call(:login, message: { :username => username, :apiKey => api_key })
if response.success? == false
  puts "login failed"
  System.exit(0)
end
@session = response.body[:login_response][:login_return]; # api session

# load the top level categories
@top_level_categories = catalogCategoryLevel

# load the spreadsheet and run through each row.
@worksheet = Spreadsheet.open(path_to_spreadsheet).worksheet(0)
@worksheet.each 5 do |row|
  collection_category_id = getCategoryIdByName('Collection', row[6], top_level_categories[:collection][:category_id])
  sku = "#{row[0]} "

  begin # update existing product
    info_response = @client.call(:catalog_product_info, message: {sessionId: @session, productIdentifierType: 'sku', product: '1322147'})
    product = info_response.body[:catalog_product_info_response][:info]
    update_response = @client.call(:catalog_product_update, message: { sessionId: @session, product: product[:product_id], productIdentifierType: 'id', productData: { categories: product[:categories] << collection_category_id } })
    product_groupings[row[9]] << product[:product_id]
  rescue # create new product
    default_category_id = getCategoryIdByName('Default Category', row[7], 'default')
    response = @client.call(:catalog_product_create, message: { sessionId: @session,  type: 'simple', set: attribute_set_id, sku: sku, storeView: store_view_id, productData: {
      name: row[2],
      status: 'Enabled',
      url_key: row[2].downcase.gsub(' ', '-'),
      category_ids: [default_category_id, collection_category_id],
      additional_attributes: {
         style_code: row[9],
         quality: row[8],
         design: row[4],
         color: row[3],
         size: row[5]
      }
    }})
    product_groupings[row[9]] << info_response.body[:catalog_product_info_response][:info][:product_id]
  end
end