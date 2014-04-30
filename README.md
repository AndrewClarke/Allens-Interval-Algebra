Allens-Interval-Algebra
=======================

Implement the essential operators from Allens Interval Algebra,
and also some metaprogramming for combinatoral operators

Defines a type representing a [closed, open) range from [starts, ends) where ends
represents the first value NOT part of the range. The methods define the strict
definitions of the operators from Allens Interval Algebra, where a pair of intervals
can only satisfy exactly one operator.

To understand AIA, consider the comparison relations of ordinary numbers for a moment.
Just as, for any specific values in x and y, only one of the following relations
will be true:

    x < y
    x == y
    x > y

In Allens Interval Algebra, only one of the following relations will be true,
as the sample pairs show. Notice the symmetry of the operators on either side
of the equals? operator.

    x.before?(y)            [1,3)   [4,10)      B   <   B
    x.meets?(y)             [1,4)   [4,10)      M   m   M
    x.overlaps?(y)          [2,6)   [4,10)      O   o   O
    x.starts?(y)            [4,6)   [4,10)      S   s   S
    x.during?(y)            [6,8)   [4,10)      D   d   D
    x.finishes?(y)          [6,10)  [4,10)      F   f   F
    x.equals?(y)            [4,10)  [4,10)      E   =   E
    x.finishedBy?(y)        [4,10)  [6,10)      Fi  f^  Fby
    x.includes?(y)          [4,10)  [6,8)       Di  d^  I
    x.startedBy?(y)         [4,10)  [4,6)       Si  s^  Sby
    x.overlappedBy?(y)      [4,10)  [2,6)       Oi  o^  Oby
    x.metBy?(y)             [4,10)  [1,4)       Mi  m^  Mby
    x.after?(y)             [4,10)  [1,3)       Bi  >   A

(ignore the last columns of letters and symbols, they will be referred to later)

With ordinary numbers, the operators <=, >= and != exist; you might be wondering
why they were not considered. These extra operators are derived from the core operators:

    x <= y      (x < y) OR (x == y)
    x <= y      NOT (x > y)
    etc

therefore the derived operators are not part of the core defintions.
Similarly, in AIA by definition:

    if x.before?(y) then NOT x.meets?(y)
    if x.meets?(y) then NOT x.before?(y)

and so on.

When it comes to the basic 13 operators, exactly one is true for any particular x and y.

The extra columns of letters and symbols above show some of the alternative notations that
have been dreamt up to represent the operators; mathematicians don't like words so much...
The trailing i in the 3rd-last column is supposed to mean "inverse" - eg if

    x S y

is true, then the following is also true:

    y Si x

or in plainer English (or at least plainer Ruby), if

    x.starts?(y)

then

    y.startedBy?(x)

The next column shows a symbolism which uses ^ for inverse, and symbols < = > where possible.
This appears to be the original Allens symbolism or near enough, but is clearly not suitable
for Ruby meta-programming.

In order to support meta-programming in Ruby, this module will use the notation of the last
column, which is slighlty more mnemonic while remaining very concise.

The algebra goes on to define a notation supporting more than one operator in the expressions.
The Wikipedia entry provides the following sample, converting a pair of assertions:

    During dinner, Peter reads the newspaper.
    Afterwards, he goes to bed.

becomes

    newspaper {D,S,F} dinner
    dinner {B,M} bed

Personally, I would have thought

    newspaper E dinner
    dinner M bed

would be a better representation, so either:

    1/ I don't understand all the intricacies (quite likely!)
    2/ It is a poor example (even Wikipedia etc etc)
    3/ It is just a simple example showing the sort of questions we may ask of a database:

eg for 3:

    database, please give me the events that are before, meet or overlap dinner.

For a hypothetical Ruby-esque approach, I'll be aiming for something like:

    dinner = SOMETHING
    events.select { |ev| ev.BMO?(dinner) }

Read up on the algebra to understand how sets of operators can be used in expressions.
Further work will be required to implement that algebra.

From a programming perspective (eg aimed at Temporal Databases), higher level operators
could usefully be defined, similar to the way (<=) is defined as (< or =) Once again,
that's better performed in a separate package which uses this one for it's raw materials.
This package should always remain clean and true to the Algebra.

If you're lucky, this package may end up augmented by suggestions, or even actual packages.

## Installation

TODO: FIX THE FOLLOWING TO SUIT THE NEW NAME!!!

Add this line to your application's Gemfile:

    gem 'allens_interval_algebra'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install allens_interval_algebra

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
