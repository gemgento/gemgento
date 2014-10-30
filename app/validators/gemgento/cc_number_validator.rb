module Gemgento
  class CcNumberValidator < ActiveModel::Validator
    def validate(record)
      n = record.cc_number
      valid = false
      size = get_size(n)

      # must be between 13 and 16 digits
      if (size > 12 and size < 17)
        # must start with a 4, 5, 6, or 37
        if (([4, 5, 6].include? get_prefix(n, 1)) or prefix_matched(n, 37))
          valid = (sum_of_double_even_place(n) + sum_of_odd_place(n)) % 10 == 0
        end
      end

      if !valid
        record.errors[:base] << 'Invalid card number'
      end
    end

    def sum_of_double_even_place(n)
      # double each number in an even place in n. if the doubled number is two-digits, use the sum of the two digits (use get_digit)
      place = 1
      sum = 0
      split = n.to_s.split(//)

      (split.length-1).downto(0) do |i|
        if place % 2 == 0
          sum = sum + get_digit(split[i].to_i * 2)
        end

        place = place + 1
      end

      return sum
    end

    def get_digit(n)
      # Return this number if it is a single digit, otherwise, return the sum of the two digits

      if (n > 9)
        result = n.to_s.split(//)
        result = result[0].to_i + result[1].to_i
      else
        result = n
      end

      return result
    end

    def sum_of_odd_place(n)
      # Return the sum of odd-place digits in number
      place = 1
      sum = 0
      split = n.to_s.split(//)

      (split.length-1).downto(0) do |i|
        if place % 2 > 0
          sum = sum + split[i].to_i
        end

        place = place + 1
      end

      return sum
    end

    def prefix_matched(n, d)
      # Return true if the digit d is a prefix for number
      return n.to_s.start_with?(d.to_s)
    end

    def get_size(n)
      # get the number of digits in n
      return n.to_s.length
    end

    def get_prefix(n, k)
      # Return the first k number of digits from number. If the number of digits in number is less than k, return number.
      prefix = n

      if (n >= 10**k)
        prefix = n.to_s[0, k].to_i
      end

      return prefix
    end
  end
end