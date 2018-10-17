
module Allens
  class Interval
    # Regarding the clock ticks mentioned below, e.g. timestamps could profitably use:
    #   chronon   = 0.000001 (find out what Ruby's granularity is for timestamp)
    #   clocktick = 0.000001 (choose your preference, multiple of chronon)
    #   forever   = "999/12/31 23:59:59.999999"
    # BEWARE: that .999999 stuff should be exactly the last possible clock-tick at the
    # granularity you are choosing to use. (and to understand this, you need to know
    # about the concepts of 'atomic clock tick' ('chronon'), 'clock tick' and the finer
    # points about their interection).

    Whinge = "Do not use Allens::Interval directly. Subclass it, and define class methods 'chronon', 'clocktick' and 'forever' returning non-nil values"

    def self.chronon;   raise Allens::Interval::Whinge; end
    def self.clocktick; raise Allens::Interval::Whinge; end
    def self.forever;   raise Allens::Interval::Whinge; end


    attr_reader :starts, :ends


    def initialize(starts, ends = nil)
      # Passing in a nil 'ends' (ie not passing) manufactures a forever Interval.
      # Programmers may pass the forever value of their particular subclass; cope with that too
      #
      ends ||= self.class.forever
      ends.nil?                 and raise Allens::Inteval::Whinge
      starts < ends              or raise ArgumentError, "Expected starts < ends. Got starts=#{starts}, ends=#{ends}"
      ends <= self.class.forever or raise ArgumentError, "Expected ends <= 'FOREVER' (#{self.class.forever}). Got starts=#{starts}, ends=#{ends}"

      @starts, @ends = starts, ends
    end


    def hash
      return @starts.hash ^ @ends.hash
    end


    def eql?(other)
      return @starts == other.starts && @ends == other.ends
    end


    ##################################################################
    # Utility functions
    def to_s(*args)
      return "[" + @starts.to_s(*args) + "," + (forever? ? "-" : @ends.to_s(*args)) + ")"
    end


    def foreverValue    # convenience
      return self.class.forever
    end


    def forever?
      return @ends == self.class.forever
    end

    def limited?
      return @ends != self.class.forever
    end


    ##################################################################
    # TODO: temporal use has strong opinions about how points relate to
    # periods. Check chapter 3, build some tests and go for gold (or green...)
    # hint: see how metBy? has a theoretically useless "starts > y.starts"
    # clause? That may be what's needed to fix things; or it might need to be removed!
    # Consider the granularity effect of the clocktick, and hope that it won't
    # need subtracting from one of the values with changes from (eg) < to <= or whatever...

    def before?(y);       return @ends   <  y.starts;                                        end
    def meets?(y);        return @ends   == y.starts;                                        end
    def overlaps?(y);     return @starts <  y.starts && @ends >  y.starts && @ends < y.ends; end
    def starts?(y);       return @starts == y.starts && @ends <  y.ends;                     end
    def during?(y);       return @starts >  y.starts && @ends <  y.ends;                     end
    def finishes?(y);     return @starts >  y.starts && @ends == y.ends;                     end
    def equals?(y);       return @starts == y.starts && @ends == y.ends;                     end
    def finishedBy?(y);   return @starts <  y.starts && @ends == y.ends;                     end
    def includes?(y);     return @starts <  y.starts && @ends >  y.ends;                     end
    def startedBy?(y);    return @starts == y.starts && @ends >  y.ends;                     end
    def overlappedBy?(y); return @starts >  y.starts && @starts < y.ends && @ends > y.ends;  end
    def metBy?(y);        return @starts == y.ends;                                          end
    def after?(y);        return @starts >  y.ends;                                          end


    ##################################################################
    # Combinatoral operators - See chapter 3's taxonomy.
    # TODO: expand the nested calls, and simplify the expressions,
    # but ONLY after the unit tests are solid!!!
    #
    def before!(y);     return before?(y)   || after?(y);        end
    def meets!(y);      return meets?(y)    || metBy?(y);        end
    def overlaps!(y);   return overlaps?(y) || overlappedBy?(y); end
    def starts!(y);     return starts?(y)   || startedBy?(y);    end
    def during!(y);     return during?(y)   || includes?(y);     end
    def finishes!(y);   return finishes?(y) || finishedBy?(y);   end
    def equals!(y);     return equals?(y);                       end

    def aligns!(y);     return starts!(y)   || finishes!(y);     end
    def occupies!(y);   return aligns!(y)   || during!(y);       end
    def fills!(y);      return occupies!(y) || equals!(y);       end
    def intersects!(y); return fills!(y)    || overlaps!(y);     end
    def excludes!(y);   return before!(y)   || meets!(y);        end



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

