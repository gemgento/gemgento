module Gemgento
  class AddressesController < BaseController
    layout false

    def region_options
      country = Country.where(params[:country_id]).first
      @regions = Region.where(country: country).map { |r| [r.name, r.id] }.insert(0, "Select a State")
    end
  end
end