
require 'test/unit'
require 'allens'

class AllensTest < Test::Unit::TestCase
  TESTS = [ :before?, :meets?, :overlaps?, :starts?, :during?,
            :finishes?, :equals?, :finishedBy?, :includes?,
            :startedBy?, :overlappedBy?, :metBy?, :after?
          ]

  # The patterns are described in test_helper.rb
  # Each pattern pair will satisfy exactly one operator.
  # The pairs of pairs are designed to test Intervals that
  # are both limited and have an infinite ends value.
  #
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

      pX = Allens::Interval.maker(sX)
      pY = Allens::Interval.maker(sY)

      j = 0
      TESTS.each do |test|
        j += 1
        want = i == j
        assert_equal want, pX.send(test, pY)
      end
    end
  end


  def test_scalar_arg
    p1 = Allens::Interval.new(10, 20)
    p2 = Allens::Interval.new(10)

    assert ! p1.before?(5)
    assert ! p1.before?(10)
    assert ! p1.before?(15)
    assert   p1.before?(20)
    assert   p1.before?(25)
    assert   p1.before?(p1.foreverValue)

    assert ! p2.before?(5)
    assert ! p2.before?(10)
    assert ! p2.before?(15)
    assert ! p2.before?(20)
    assert ! p2.before?(25)
    assert ! p2.before?(p2.foreverValue)

    assert ! p1.finishedBy?(5)
    assert ! p1.finishedBy?(10)
    assert ! p1.finishedBy?(15)
    assert   p1.finishedBy?(20)
    assert ! p1.finishedBy?(25)
    assert ! p1.finishedBy?(p1.foreverValue)

    assert ! p2.finishedBy?(5)
    assert ! p2.finishedBy?(10)
    assert ! p2.finishedBy?(15)
    assert ! p2.finishedBy?(20)
    assert ! p2.finishedBy?(25)
    assert   p2.finishedBy?(p2.foreverValue)

    assert ! p1.includes?(5)
    assert ! p1.includes?(10)
    assert   p1.includes?(15)
    assert ! p1.includes?(20)
    assert ! p1.includes?(25)
    assert ! p1.includes?(p1.foreverValue)

    assert ! p2.includes?(5)
    assert ! p2.includes?(10)
    assert   p2.includes?(15)
    assert   p2.includes?(20)
    assert   p2.includes?(25)
    assert ! p2.includes?(p2.foreverValue)

    assert ! p1.startedBy?(5)
    assert   p1.startedBy?(10)
    assert ! p1.startedBy?(15)
    assert ! p1.startedBy?(20)
    assert ! p1.startedBy?(25)
    assert ! p1.startedBy?(p1.foreverValue)

    assert ! p2.startedBy?(5)
    assert   p2.startedBy?(10)
    assert ! p2.startedBy?(15)
    assert ! p2.startedBy?(20)
    assert ! p2.startedBy?(25)
    assert ! p2.startedBy?(p2.foreverValue)

    assert   p1.after?(5)
    assert ! p1.after?(10)
    assert ! p1.after?(15)
    assert ! p1.after?(20)
    assert ! p1.after?(25)
    assert ! p1.after?(p1.foreverValue)

    assert   p2.after?(5)
    assert ! p2.after?(10)
    assert ! p2.after?(15)
    assert ! p2.after?(20)
    assert ! p2.after?(25)
    assert ! p2.after?(p2.foreverValue)
  end


  def test_scalar_receiver
    p1 = AltInterval.new(10, 20)
    p2 = AltInterval.new(10)
    inf = AltInterval.forever

    assert   5.before?(p1)
    assert ! 10.before?(p1)
    assert ! 15.before?(p1)
    assert ! 20.before?(p1)
    assert ! 25.before?(p1)
    assert ! inf.before?(p1)

    assert   5.before?(p2)
    assert ! 10.before?(p2)
    assert ! 15.before?(p2)
    assert ! 20.before?(p2)
    assert ! 25.before?(p2)
    assert ! inf.before?(p2)

    assert ! 5.starts?(p1)
    assert   10.starts?(p1)
    assert ! 15.starts?(p1)
    assert ! 20.starts?(p1)
    assert ! 25.starts?(p1)
    assert ! inf.starts?(p1)

    assert ! 5.starts?(p2)
    assert   10.starts?(p2)
    assert ! 15.starts?(p2)
    assert ! 20.starts?(p2)
    assert ! 25.starts?(p2)
    assert ! inf.starts?(p2)

    assert ! 5.during?(p1)
    assert ! 10.during?(p1)
    assert   15.during?(p1)
    assert ! 20.during?(p1)
    assert ! 25.during?(p1)
    assert ! inf.during?(p1)

    assert ! 5.during?(p2)
    assert ! 10.during?(p2)
    assert   15.during?(p2)
    assert   20.during?(p2)
    assert   25.during?(p2)
    assert ! inf.during?(p2)

    assert ! 5.finishes?(p1)
    assert ! 10.finishes?(p1)
    assert ! 15.finishes?(p1)
    assert   20.finishes?(p1)
    assert ! 25.finishes?(p1)
    assert ! inf.finishes?(p1)

    assert ! 5.finishes?(p2)
    assert ! 10.finishes?(p2)
    assert ! 15.finishes?(p2)
    assert ! 20.finishes?(p2)
    assert ! 25.finishes?(p2)
    assert   inf.finishes?(p2)

    assert ! 5.after?(p1)
    assert ! 10.after?(p1)
    assert ! 15.after?(p1)
    assert ! 20.after?(p1)
    assert   25.after?(p1)
    assert   inf.after?(p1)

    assert ! 5.after?(p2)
    assert ! 10.after?(p2)
    assert ! 15.after?(p2)
    assert ! 20.after?(p2)
    assert ! 25.after?(p2)
    assert ! inf.after?(p2)
  end
end

