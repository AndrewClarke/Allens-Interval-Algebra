
require 'test/unit'
require 'allens'


class RangeOTest < Test::Unit::TestCase
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
  # designed to test Ranges that are both limited and have a 'forever' ends value.
  # The list of numbers shows which of the higher operators should be true for
  # this combo; these extra lists are ignored for testing the fundamental operators.
  RANGES = [
    [ "xx...", "...xx", [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ], #  [ "xx...", "...XX", [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ "xx...", "..xxx", [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ], #  [ "xx...", "..XXX", [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ "xxx..", "..xxx", [ 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0 ] ], #  [ "xxx..", "..XXX", [ 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0 ] ],
    [ "xx...", "xxxxx", [ 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0 ] ], #  [ "xx...", "XXXXX", [ 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0 ] ],
    [ ".xxx.", "xxxxx", [ 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0 ] ], #  [ ".xxx.", "XXXXX", [ 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0 ] ],
    [ "..xxx", "xxxxx", [ 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0 ] ], #  [ "..XXX", "XXXXX", [ 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0 ] ],
    [ "xxxxx", "xxxxx", [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0 ] ], #  [ "XXXXX", "XXXXX", [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0 ] ],
    [ "xxxxx", "..xxx", [ 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0 ] ], #  [ "XXXXX", "..XXX", [ 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0 ] ],
    [ "xxxxx", ".xxx.", [ 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0 ] ], #  [ "XXXXX", ".xxx.", [ 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0 ] ],
    [ "xxxxx", "xx...", [ 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0 ] ], #  [ "XXXXX", "xx...", [ 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0 ] ],
    [ "..xxx", "xxx..", [ 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0 ] ], #  [ "..XXX", "xxx..", [ 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0 ] ],
    [ "..xxx", "xx...", [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ], #  [ "..XXX", "xx...", [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ "...xx", "xx...", [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ], #  [ "...XX", "xx...", [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ]
  ]

  # "Now let's consider the special case in which one of the two time periods is a point in time,
  #  i.e. is exactly one clock tick in length, and the other one contains two or more clock ticks.
  #  This point in time may either [intersects] or [excludes] the time period.
  #  If the point in time [intersects] the time period, it also [fills] and [occupies] that time period.
  #  If it [aligns] with the time period, then it either [starts] the time period or [finishes] it.
  #  Otherwise, the point in time occurs [during] the time period.
  #  If the point in time [excludes] the time period, then either may be [before] the other, or they may [meet]."
  POINT_RANGE = [
    [ "x....", "..xxx", [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    # "x....", "..XXX", [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ "x....", ".xxxx", [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    # "x....", ".XXXX", [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ "x....", "xxxxx", [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0 ] ],
    # "x....", "XXXXX", [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0 ] ],
    [ "..x..", "xxxxx", [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0 ] ],
    # "..x..", "XXXXX", [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0 ] ],
    [ "....x", "xxxxx", [ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0 ] ],
    # "....x", "XXXXX", [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0 ] ],
    [ "....x", "xxxx.", [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ "....x", "xxx..", [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ], [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ]
  ]

  # "Finally, let's consider one more special case, that in which both the time periods are points in time.
  #  Those two points in time may be [equal], or one may be [before] the other, or they may [meet].
  #  There are no other Allen relationships possible for them."
  POINTS = [
    [ "x..", "..x", [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ ".x.", "..x", [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ ".x.", ".x.", [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0 ] ],
    [ "..x", ".x.", [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 ], [ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
    [ "..x", "x..", [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ], [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ]
  ]

  # TODO: checks for class constraints triggering exceptions
  # eg not defining chronon, clocktick, forever
  # also need tests for insensible (ie out of bounds) end values throwing exceptions.


  def test_rangeO_fundamental_operators
    i = -1
    RANGES.each do |(sX, sY, _)|
      i += 1
      pX = Allens::rangeO(sX)
      pY = Allens::rangeO(sY)

      FUNDAMENTAL_TESTS.each_with_index do |test, j|
        want = i == j
        assert_equal want, pX.send(test, pY)
      end
    end
  end
  # test_rangeO_fundamental_operators


  def test_rangeO_higher_operators
    RANGES.each do |(sX, sY, expects)|
      pX = Allens::rangeO(sX)
      pY = Allens::rangeO(sY)

      HIGHER_TESTS.each_with_index do |test, i|
        want = expects[i] == 1
        assert_equal want, pX.send(test, pY)
      end
    end
  end
  # test_rangeO_higher_operators


  def test_point_rangeO_fundamental_operators
    POINT_RANGE.each do |(sX, sY, expects, _)|
      pX = Allens::rangeO(sX)
      pY = Allens::rangeO(sY)

      FUNDAMENTAL_TESTS.each_with_index do |test, i|
        want = expects[i] == 1
        assert_equal want, pX.send(test, pY)
      end
    end
  end
  # test_point_rangeO_fundamental_operators


  def test_point_rangeO_higher_operators
    POINT_RANGE.each do |(sX, sY, _, expects)|
      pX = Allens::rangeO(sX)
      pY = Allens::rangeO(sY)

      HIGHER_TESTS.each_with_index do |test, i|
        want = expects[i] == 1
        assert_equal want, pX.send(test, pY)
      end
    end
  end
  # test_point_rangeO_higher_operators


  def test_points_fundamental_operators
    POINTS.each do |(sX, sY, expects, _)|
      pX = Allens::rangeO(sX)
      pY = Allens::rangeO(sY)

      FUNDAMENTAL_TESTS.each_with_index do |test, i|
        want = expects[i] == 1
        assert_equal want, pX.send(test, pY)
      end
    end
  end
  # test_points_fundamental_operators


  def test_points_higher_operators
    POINTS.each do |(sX, sY, _, expects)|
      pX = Allens::rangeO(sX)
      pY = Allens::rangeO(sY)

      HIGHER_TESTS.each_with_index do |test, i|
        want = expects[i] == 1
        assert_equal want, pX.send(test, pY)
      end
    end
  end
  # test_points_higher_operators
end

