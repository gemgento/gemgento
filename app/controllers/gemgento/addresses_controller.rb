module Gemgento
  class AddressesController < BaseController
    layout false

    def region_options
      country = Country.find(params[:country_id])
      @regions = Region.where(country: country).map { |r| [r.name, r.id] }
    end
  end
end