
module Allens
  class Interval
    def self.forever       # sub-classes can nominate their own "forever" value
      return nil
    end


    def initialize(starts, ends = nil)
      # Passing in a nil 'ends' (ie not passing) manufactures a forever Interval.
      # Programmers may pass the forever value of their particular subclass; cope with that too
      #
      if ! ends.nil? && ends != self.class.forever && starts > ends
        raise ArgumentError, "Expected starts <= ends. Got starts=#{starts}, ends=#{ends}"
      end

      @starts = starts
      @ends = ends.nil? ? self.class.forever : ends
    end


    def hash
      return starts.hash ^ ends.hash
    end


    def eql?(other)
      return false if starts != other.starts
      return false if forever? != other.forever?
      return forever? && other.forever? || ends == other.ends
    end


    ##################################################################
    def to_s(*args)
      return "[" + starts.to_s(*args) + "," + (forever? ? "-" : ends.to_s(*args)) + ")"
    end


    def foreverValue    # convenience
      return self.class.forever
    end


    def forever?
      return ends == self.class.forever
    end

    def limited?
      return ends != self.class.forever
    end


    def starts
      return @starts
    end

    def ends
      return @ends
    end


    ##################################################################
    def before?(y)
      if y.is_a?(Interval)
        return limited? && ends < y.starts
      end

      return limited? && (y == self.class.forever || ends <= y)
    end

    def meets?(y)
      return starts < y.starts && limited? && ends == y.starts
    end

    def overlaps?(y)
      return starts < y.starts && limited? && ends > y.starts && (y.forever? || ends < y.ends)
    end

    def starts?(y)
      return starts == y.starts && limited? && (y.forever? || ends < y.ends)
    end

    def during?(y)
      return starts > y.starts && limited? && (y.forever? || ends < y.ends)
    end

    def finishes?(y)
      return starts > y.starts && ((forever? && y.forever?) || (limited? && y.limited? && ends == y.ends))
    end

    def equals?(y)
      return starts == y.starts && ((forever? && y.forever?) || (limited? && y.limited? && ends == y.ends))
    end

    def finishedBy?(y)
      if y.is_a?(Interval)
        return starts < y.starts && ((forever? && y.forever?) || (limited? && y.limited? && ends == y.ends))
      end

      return forever? ? y == self.class.forever : y != self.class.forever && ends == y
    end

    def includes?(y)
      if y.is_a?(Interval)
        return starts < y.starts && y.limited? && (forever? || ends > y.ends)
      end

      return y != self.class.forever && starts < y && (forever? || y < ends)
    end

    def startedBy?(y)
      if y.is_a?(Interval)
        return starts == y.starts && y.limited? && (forever? || ends > y.ends)
      end

      return y != self.class.forever && starts == y
    end

    def overlappedBy?(y)
      return starts > y.starts && y.limited? && starts < y.ends && (forever? || ends > y.ends)
    end

    def metBy?(y)
      return starts > y.starts && y.limited? && starts == y.ends
    end

    def after?(y)
      if y.is_a?(Interval)
        return y.limited? && starts > y.ends
      end

      return y != self.class.forever && starts > y
    end


    ##################################################################
    def method_missing(key, *args)
      text = key.to_s
      if args.length == 1 and (text =~ /^(B)?(M)?(O)?(S)?(D)?(F)?(E)?(Fby)?(I)?(Sby)?(Oby)?(Mby)?(A)?\?$/ or
                               text =~ /^(Before)?(Meets)?(Overlaps)?(Starts)?(During)?(Finishes)?(Equals)?(FinishedBy)?(Includes)?(StartedBy)?(OverlappedBy)?(MetBy)?(After)?\?$/
                              )

        names = Regexp.last_match
        sep = 'return'
        code = "def #{text}(y);"

        %w(before? meets? overlaps? starts? during? finishes? equals? finishedBy? includes? startedBy? overlappedBy? metBy? after?).each_with_index do |name, i|
          if ! names[i + 1].nil?
            code += " #{sep} #{name}(y)"
            sep = '||'
          end
        end

        code += "; end"
        Interval.class_eval code

        return send(key, *args)
      end

      # TODO: a real error message shows line numbers...
      raise NoMethodError, "undefined or improperly named method `#{text}(*#{args.count})'"
    end
    # method_missing
  end
end

