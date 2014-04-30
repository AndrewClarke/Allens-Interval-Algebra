
require 'test/unit'
require 'allens'

# AltInterval < Allens::Interval is defined with a personal number for the "forever" value.
#
class SubclassTest < Test::Unit::TestCase
  TESTS = [ :before?, :meets?, :overlaps?, :starts?, :during?, :finishes?,
            :equals?,
            :finishedBy?, :includes?, :startedBy?, :overlappedBy?, :metBy?, :after? ]

  # The patterns are described in test_helper.rb
  # Each pattern pair will satisfy exactly one operator. The pairs of pairs are
  # designed to test Intervals that are both limited and have an infinite ends value.
  VALS = [ [ "x..", "..x" ], [ "x..", "..X" ],
           [ "x..", ".xx" ], [ "x..", ".XX" ],
           [ "xx.", ".xx" ], [ "xx.", ".XX" ],
           [ "x..", "xxx" ], [ "x..", "XXX" ],
           [ ".x.", "xxx" ], [ ".x.", "XXX" ],
           [ ".xx", "xxx" ], [ ".XX", "XXX" ],
           [ "xxx", "xxx" ], [ "XXX", "XXX" ],
           [ "xxx", "..x" ], [ "XXX", "..X" ],
           [ "xxx", ".x." ], [ "XXX", ".x." ],
           [ "xxx", "x.." ], [ "XXX", "x.." ],
           [ ".xx", "xx." ], [ ".XX", "xx." ],
           [ ".xx", "x.." ], [ ".XX", "x.." ],
           [ "..x", "x.." ], [ "..X", "x.." ] ]

  def test_operators
    i = 0
    k = 0
    VALS.each do |(sX, sY)|
      # step i by 1 every two pairs; will run as: 1, 1, 2, 2, ..., 13, 13 (13 tests - are you paying attention?)
      k = 1 - k
      i += k

      pX = AltInterval.maker(sX)
      pY = AltInterval.maker(sY)

      j = 0
      TESTS.each do |test|
        j += 1
        want = i == j
        assert_equal want, pX.send(test, pY)
      end
    end
  end
end

