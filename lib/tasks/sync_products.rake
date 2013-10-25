namespace :gemgento do
  namespace :sync do
    task :products => :environment do

      # make sure there is no active product sync
      if Gemgento::Sync.is_active? %w[categories attributes products inventory everything]
        puts 'Product sync is active'
        next
      end

      Gemgento::Sync.categories
      Gemgento::Sync.attributes
      Gemgento::Sync.products
      Gemgento::Sync.inventory
    end
  end
end