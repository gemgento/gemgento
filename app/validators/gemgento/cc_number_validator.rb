module Gemgento
  class CcNumberValidator < ActiveModel::Validator
    def validate(record)
      digits =  record.cc_number.gsub(/\D/, '').split('').map(&:to_i)
      check = digits.pop

      sum = digits.reverse.each_slice(2).map do |x, y|
        [(x * 2).divmod(10), y || 0]
      end.flatten.inject(:+) || 0

      if (10 - sum % 10) != check
        record.errors[:cc_number] << 'is invalid'
      end
    end

  end
end