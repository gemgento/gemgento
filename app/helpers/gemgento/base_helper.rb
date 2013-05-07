module Gemgento
  module BaseHelper
    def ensure_string(subject)
      if subject.is_a? String
        subject
      else
        ''
      end
    end
  end
end