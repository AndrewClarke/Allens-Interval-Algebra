
require 'allens/interval'
require 'allens/scalar_mixin'

class Fixnum
  include Allens::ScalarMixin
end

class Float
  include Allens::ScalarMixin
end

class Date
  include Allens::ScalarMixin
end

class Time
  include Allens::ScalarMixin
end

