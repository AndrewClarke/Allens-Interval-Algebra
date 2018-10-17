
require 'allens'

module Allens
  class Interval
    def self.maker(str)
      # Construct from a string like   /^\.*x+\.*$/ or /^\.*X+$/
      # The pattern returns an Interval starting at 1..n (where the first [Xx] is found) and the end is the
      # position after the last x found.
      #
      # If X is used, it implies the Interval ranges to 'forever', therefore it must not be followed by dots -
      # the string should be filled to the end with big-X if big-X is used. Note that the code here doesn't
      # check - it trusts you! I mean, come on. Tests inside tests? Get it rite!!!
      # Another consequence is that x and X cannot (and/or should not) be mingled.

      starts = str.index(/[xX]/) + 1

      if str[-1] == ?X
        result = self.new(starts)       # ending with big-X implies the interval runs to 'forever'
      else
        ends = (str.index(?., starts - 1) || str.length) + 1
        result = self.new(starts, ends)
      end

      return result
    end  # self.maker
  end


  def self.rangeO(str)
    # Construct an open-ended Range from a string like   /^\.*x+\.*$/
    # The pattern returns a Range starting at 1..n (where the first [Xx] is found) and the end is the
    # position after the last x found.

    starts = str.index(/x/) + 1
    ends = (str.index(?., starts - 1) || str.length) + 1
    result = starts.to_f ... ends.to_f

    return result
  end  # self.rangeO


  def self.rangeC(str)
    # Construct a closed-end Range from a string like   /^\.*x+\.*$/
    # The pattern returns a Range starting at 1..n (where the first [Xx] is found) and the end is the
    # position after the last x found.

    starts = str.index(/x/) + 1
    ends = (str.index(?., starts - 1) || str.length) + 1
    result = starts.to_f .. ends.to_f

    return result
  end  # self.rangeC
end

