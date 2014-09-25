module Gemgento
  class AddressesController < Gemgento::ApplicationController
    respond_to :html, :json

    layout -> { set_layout false }

    def region_options
      country = Country.find(params[:country_id])
      @regions = Region.where(country: country).map { |r| [r.name, r.id] }

      respond_with @regions
    end
  end
end