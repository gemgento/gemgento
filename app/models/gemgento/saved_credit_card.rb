module Gemgento

  # @author Gemgento LLC
  class SavedCreditCard < ActiveRecord::Base
    belongs_to :user

    has_one :address, as: :addressable, class_name: 'Address', dependent: :destroy

    accepts_nested_attributes_for :address

    before_create :magento_create, if: -> { Config[:extensions]['authorize-net-cim-payment-module'] }
    before_destroy :magento_destroy, if: -> { Config[:extensions]['authorize-net-cim-payment-module'] }

    attr_accessor :cc_cid

    private

    def magento_create
      response = Gemgento::API::SOAP::Authnetcim::Payment.create self

      if response.success?
        # mask the credit card number
        self.cc_number = self.cc_number.split(//).last(4).join
        self.cc_number = 'XXXX' + self.cc_number
        self.token = response.body[:result]

        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end

    def magento_destroy
      response = Gemgento::API::SOAP::Authnetcim::Payment.destroy self.user.magento_id, self.token

      if response.success?
        return true
      else
        errors.add(:base, response.body[:faultstring])
        return false
      end
    end
  end
end