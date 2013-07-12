module Gemgento
  class Sync
    def pull
      Gemgento::API::SOAP::Directory::Country.fetch_all
      Gemgento::API::SOAP::Directory::Region.fetch_all
      Gemgento::API::SOAP::Miscellaneous::Store.fetch_all
      Gemgento::API::SOAP::Catalog::Category.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttributeSet.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttribute.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttributeMedia.fetch_all_media_types
      Gemgento::API::SOAP::Catalog::Product.fetch_all
      Gemgento::API::SOAP::Catalog::ProductAttributeMedia.fetch_all
      Gemgento::API::SOAP::CatalogInventory::StockItem.fetch_all
      Gemgento::API::SOAP::Customer::Customer.fetch_all_customer_groups
      Gemgento::API::SOAP::Customer::Customer.fetch_all
      Gemgento::API::SOAP::Customer::Address.fetch_all
      Gemgento::API::SOAP::Sales::Order.fetch_all
    end
  end
end