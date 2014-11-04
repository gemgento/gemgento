module Gemgento
  class CreditCardValidator < ActiveModel::Validator
    def validate(record)
      @record = record
      card_number
      expiration_date
      security_code
    end

    def card_number
      digits =  @record.cc_number.gsub(/\D/, '').split('').map(&:to_i)
      check = digits.pop

      sum = digits.reverse.each_slice(2).map do |x, y|
        [(x * 2).divmod(10), y || 0]
      end.flatten.inject(:+) || 0

      if (10 - sum % 10) != check
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