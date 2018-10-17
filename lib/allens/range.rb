
# Monkey-patch the Ruby Range class to support AIA. Unlike the Allens::Interval,
# these methods do not deal with clock ticks - they simply implement the conditions
# for whatever type the Range is over. Handling open and closed Ruby Ranges is a
# minor but essential complication.
# No meta-programming is provided. Forever is irrelevant.

class Range
  def before?(y);       return self.end   <  y.begin;                                            end
  def meets?(y);        return self.end   == y.begin;                                            end
  def overlaps?(y);     return self.begin <  y.begin && self.end >  y.begin && self.end < y.end; end
  def starts?(y);       return self.begin == y.begin && self.end <  y.end;                       end
  def during?(y);       return self.begin >  y.begin && self.end <  y.end;                       end
  def finishes?(y);     return self.begin >  y.begin && self.end == y.end;                       end
  def equals?(y);       return self.begin == y.begin && self.end == y.end;                       end
  def finishedBy?(y);   return self.begin <  y.begin && self.end == y.end;                       end
  def includes?(y);     return self.begin <  y.begin && self.end >  y.end;                       end
  def startedBy?(y);    return self.begin == y.begin && self.end >  y.end;                       end
  def overlappedBy?(y); return self.begin >  y.begin && self.begin < y.end && self.end > y.end;  end
  def metBy?(y);        return self.begin == y.end;                                              end
  def after?(y);        return self.begin >  y.end;                                              end


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
end

