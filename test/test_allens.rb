
require 'test/unit'
require 'allens'


class TestInterval < Allens::Interval
  def self.forever
    return 1000
  end
end


class AllensTest < Test::Unit::TestCase
  FUNDAMENTAL_TESTS = [
            :before?,       :meets?,    :overlaps?,
            :starts?,       :during?,   :finishes?,
            :equals?,
            :finishedBy?,   :includes?, :startedBy?,
            :overlappedBy?, :metBy?,    :after?
          ]

  HIGHER_TESTS = [
    :before!, :meets!, :overlaps!, :starts!, :during!, :finishes!,
    :equals!, :aligns!, :occupies!, :fills!, :intersects!, :excludes!
  ]


  # The patterns are described in test_helper.rb
  # Each pattern pair will satisfy exactly one operator. The pairs of pairs are
  # designed to test Intervals that are both limited and have a 'forever' ends value.
  # The list of numbers shows which of the higher operators should be true for
  # this combo; these extra lists are ignored for testing the fundamental operators.
  #
  VALS = [ [ "xx...", "...xx", [ 0, 0, 0, 0, 1 ] ], [ "xx...", "...XX", [ 0, 0, 0, 0, 1 ] ],
           [ "xx...", "..xxx", [ 0, 0, 0, 0, 1 ] ], [ "xx...", "..XXX", [ 0, 0, 0, 0, 1 ] ],
           [ "xxx..", "..xxx", [ 0, 0, 0, 1, 0 ] ], [ "xxx..", "..XXX", [ 0, 0, 0, 1, 0 ] ],
           [ "xx...", "xxxxx", [ 1, 1, 1, 1, 0 ] ], [ "xx...", "XXXXX", [ 1, 1, 1, 1, 0 ] ],
           [ ".xxx.", "xxxxx", [ 0, 1, 1, 1, 0 ] ], [ ".xxx.", "XXXXX", [ 0, 1, 1, 1, 0 ] ],
           [ "..xxx", "xxxxx", [ 1, 1, 1, 1, 0 ] ], [ "..XXX", "XXXXX", [ 1, 1, 1, 1, 0 ] ],
           [ "xxxxx", "xxxxx", [ 0, 0, 1, 1, 0 ] ], [ "XXXXX", "XXXXX", [ 0, 0, 1, 1, 0 ] ],
           [ "xxxxx", "..xxx", [ 1, 1, 1, 1, 0 ] ], [ "XXXXX", "..XXX", [ 1, 1, 1, 1, 0 ] ],
           [ "xxxxx", ".xxx.", [ 0, 1, 1, 1, 0 ] ], [ "XXXXX", ".xxx.", [ 0, 1, 1, 1, 0 ] ],
           [ "xxxxx", "xx...", [ 1, 1, 1, 1, 0 ] ], [ "XXXXX", "xx...", [ 1, 1, 1, 1, 0 ] ],
           [ "..xxx", "xxx..", [ 0, 0, 0, 1, 0 ] ], [ "..XXX", "xxx..", [ 0, 0, 0, 1, 0 ] ],
           [ "..xxx", "xx...", [ 0, 0, 0, 0, 1 ] ], [ "..XXX", "xx...", [ 0, 0, 0, 0, 1 ] ],
           [ "...xx", "xx...", [ 0, 0, 0, 0, 1 ] ], [ "...XX", "xx...", [ 0, 0, 0, 0, 1 ] ] ]

  # TODO: checks for class constraints triggering exceptions
  # eg not defining chronon, clocktick, forever
  # also need tests for insensible (ie out of bounds) end values throwing exceptions.


  def test_fundamental_operators
    i = 0
    k = 0
    VALS.each do |(sX, sY, _)|
      # step i by 1 every two pairs; will run as: 1, 1, 2, 2, ..., 13, 13 (13 tests - are you paying attention?)
      k = 1 - k
      i += k

      pX = TestInterval.maker(sX)
      pY = TestInterval.maker(sY)

      j = 0
      FUNDAMENTAL_TESTS.each do |test|
        j += 1
        want = i == j
        assert_equal want, pX.send(test, pY)
      end
    end
  end


  def test_higher_operators
    i = 0
    k = 0
    VALS.each do |(sX, sY, expects)|
      # step i by 1 every two pairs; will run as: 1, 1, 2, 2, ..., 13, 13 (13 tests - are you paying attention?)
      k = 1 - k
      i += k

      pX = TestInterval.maker(sX)
      pY = TestInterval.maker(sY)

      j = 0
      HIGHER_TESTS.each do |test|
        want = expects[j] == 1
        j += 1
        assert_equal want, pX.send(test, pY)
      end
    end
  end
end

