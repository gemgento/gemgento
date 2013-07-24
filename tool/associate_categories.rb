Gemgento::Category.all.each do |category|
  parent = Gemgento::Category.where(magento_id: category.parent_id).first

  if parent.nil?
    category.parent = nil
  else
    category.parent = parent
  end

  category.save
end