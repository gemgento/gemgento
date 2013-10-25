namespace :gemgento do
  namespace :sync do
    task :orders => :environment do

      # make sure there is no active order sync
      if Gemgento::Sync.is_active? %w[customers orders everything]
        puts 'Order sync is active'
        next
      end

      Gemgento::Sync.customers
      Gemgento::Sync.orders
    end
  end
end