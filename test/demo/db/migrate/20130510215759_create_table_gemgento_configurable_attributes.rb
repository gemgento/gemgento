class CreateTableGemgentoConfigurableAttributes < ActiveRecord::Migration
  def change
    create_table :gemgento_configurable_attributes, id: false do |t|
      t.integer    :product_id
      t.integer    :product_attribute_id
    end

    execute 'ALTER TABLE  `gemgento_configurable_attributes` ADD PRIMARY KEY (  `product_id` ,  `product_attribute_id` )'
  end
end
