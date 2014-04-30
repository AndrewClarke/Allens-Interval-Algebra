
require 'allens'

module Allens
  class Interval
    def self.maker(str)
      # Construct from a string like   /^\.*x+\.*$/ or /^\.*X+$/
      # If X is used, it implies the Interval ranges to infinity, therefore it must not be followed by dots.
      # Also, x and X cannot (should not) be mingled.
      #
      # The pattern returns an Interval starting at 1..n (where the first [Xx] is found) and the end is the
      # position after the last x found.
      # If X is used, it must run all the way to the end, and it represents infinity as the terminating
      # date: [n, INF) ie an open-ended interval. Although a single trailing X would be sufficient to
      # represent infinity, in practice the string diagrams can look more obvious when all the strings
      # are the same length; thus "..XXX" is recommended when comparing with "..xx."
      #
      starts = str.index(/[xX]/) + 1
      ends = str.index(?., starts - 1)
      if ends.nil?
        ends = str.length + 1
      else
        ends += 1
      end

      return str[-1] == ?X ? self.new(starts) : self.new(starts, ends)
    end
  end
end

class AltInterval < Allens::Interval
  def self.forever
    return -100          # A whacky value that makes little or no sense in the real world
  end
end

