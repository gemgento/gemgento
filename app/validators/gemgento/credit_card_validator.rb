module Gemgento
  class CreditCardValidator < ActiveModel::Validator
    def validate(record)
      @record = record
      card_number
      expiration_date
      security_code
    end

    # Validate credit card number with a Luhn test.
    # Based on http://rosettacode.org/wiki/Luhn_test_of_credit_card_numbers#Ruby
    def card_number
      s1 = s2 = 0

      @record.cc_number.to_s.reverse.chars.each_slice(2) do |odd, even|
        s1 += odd.to_i

        double = even.to_i * 2
        double -= 9 if double >= 10
        s2 += double
      end

      if (s1 + s2) % 10 != 0
        @record.errors[:cc_number] << 'is invalid'
      end
    end

    def expiration_date
      year = @record.cc_exp_year.to_i
      month = @record.cc_exp_month.to_i

      if year < Time.now.year
        @record.errors[:cc_exp_month] = 'cannot be in the past'
      elsif (year == Time.now.year && month < Time.now.month)
        @record.errors[:cc_exp_month] = 'cannot be in the past'
      end
    end

    def security_code
      if (@record.cc_cid.length < 3 || @record.cc_cid.length > 4) || # between 3 and 4 digits
          @record.cc_cid.gsub(/\D/, '') != @record.cc_cid || # numbers only
          !(1..9999).include?(@record.cc_cid.to_i)

        @record.errors[:cc_cid] << 'is invalid'
      end
    end

  end
end