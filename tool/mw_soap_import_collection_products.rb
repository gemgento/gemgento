file = '/Users/Kevin/Sites/gemgento/tool/xls/mw_collections_04122013.xls'
image_prefix = '/Users/Kevin/Downloads/finished/'
image_suffix = '.png'
thumbnail_suffix = '_thumb.jpg'
root_category_id = Gemgento::Category.find_by(name: 'Collections').id

import = Gemgento::ProductImport.new(file, 1, image_prefix, image_suffix, thumbnail_suffix, root_category_id)
import.process
