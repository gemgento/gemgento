module Gemgento

  # @author Gemgento LLC
  class AssetFile < ActiveRecord::Base
    has_many :assets
    has_many :products, through: :assets
    has_many :stores, through: :assets

    has_attached_file :file, styles: { thumb: "200x", thumb_2x: "400x",
                                       small: "400x", small_2x: "800x",
                                       medium: "800x", medium_2x: "1600x",
                                       large: "1600x", large_2x: "3200x"}

    validates_attachment_content_type :file, content_type: /\Aimage\/.*\Z/

    # Check that a url is valid.
    #
    # @param url [String]
    # @return [Boolean]
    def self.valid_url(url)
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri)

      unless Gemgento::Config[:magento][:auth_username].blank?
        req.basic_auth Gemgento::Config[:magento][:auth_username], Gemgento::Config[:magento][:auth_password]
      end

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.use_ssl = uri.port == 443
        http.request(req)
      end

      return res.code == '200'
    end

  end
end
