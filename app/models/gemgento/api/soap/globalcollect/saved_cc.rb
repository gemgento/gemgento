module Gemgento
  module API
    module SOAP
      module Globalcollect
        class SavedCc

          def self.fetch_all
            Gemgento::User.all.each do |user|
              fetch(user)
            end
          end

          def self.fetch(user)
            tokens(user.magento_id).each do |token|
              sync_magento_to_local(token, user.id)
            end
          end

          def self.tokens(customer_id)
            response = Gemgento::Magento.create_call(:globalcollect_tokens, { customer_id: customer_id })

            if response.success?
              if response.body[:result][:item].nil?
                return []
              else
                response.body[:result][:item] = [response.body[:result][:item]] unless response.body[:result][:item].is_a? Array
                puts response.body[:result][:item].inspect
                return response.body[:result][:item]
              end
            else
              return false
            end
          end

          private

          def self.sync_magento_to_local(token, user_id)
            saved_cc = Gemgento::SavedCreditCard.find_or_initialize_by(magento_id: token[:token_id])
            saved_cc.user_id = user_id
            saved_cc.token = token[:token]
            saved_cc.cc_number = token[:cc_number]
            saved_cc.exp_month = token[:expire_date][0..1]
            saved_cc.exp_year = token[:expire_date][2..3]
            saved_cc.cc_type = token[:payment_product_id]
            saved_cc.save
          end

        end
      end
    end
  end
end