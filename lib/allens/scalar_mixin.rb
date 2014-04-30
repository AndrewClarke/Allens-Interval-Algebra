
module Allens
  module ScalarMixin
    def before?(y)
      return self != y.foreverValue && self < y.starts
    end

    def starts?(y)
      return self != y.foreverValue && self == y.starts
    end

    def during?(y)
      return self != y.foreverValue && y.starts < self && (y.forever? || self < y.ends)
    end

    def finishes?(y)
      return self == y.ends
    end

    def after?(y)
      return y.limited? && (self == y.foreverValue || self > y.ends)
    end
  end
end

