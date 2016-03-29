Allens-Interval-Algebra
=======================

Implement the essential operators from Allens Interval Algebra, and also some
metaprogramming for combinatoral operators.
NOTE: I am very tempted to remove the metaprogrammed operators because they
don't appear to be needed by 'the book' (see below).

If you are interested in temporal databases, A very useful book to read is

    Managing Time in Relational Databases
    Tom Johnson, Randall Weis
    19-AUG-2010 Morgan-Kaufmann Publishing
    ISBN 978-0-12-375041-9

Throughout the code and documentation, "the book" refers to this book.

Defines a type representing a closed-open range from `[starts, ends)`, where ends
represents the first value NOT part of the range. The methods define the strict
definitions of the operators from Allens Interval Algebra, where a pair of intervals
can only satisfy exactly one operator.

The class must be sub-classed because you are required to define a 'forever' value
for your class, along with the size of the atomic clock and clock ticks in your
chosen resolution.
NOTE: currently, the two clock ticks are not used because I'm not sure if the clients
should be required to round to the tick granularities, or whether this library should
act like a nanny and perform/check roundings on your behalf. It is important to know,
however, that the code is always written to trust that the start and end values are
correctly rounded to appropriate granular ticks - ie no 'real' scale mentality allowed.

An early version of this code allowed nil to represent 'forever' BUT it has weaknesses
when inlining combinations of operators - many tests for nil were required to guard
the comparison operators within the methods. Using a genuine value from the ordinal
scale allows much simpler optimised expressions when inlined, not to mention simpler
expressions in the fundamental operators themselves.

Note that the clock tick must be some multiple of the 'atomic clock' which is the
smallest resolution possible for your chosen scalars, such as 1 microsecond if using
a native timestamp in your chosen language. I'm considering using 1 millisecond for
any work I do in Rails, since it would suit the sort of business applications I'm
likely to be involved in. Future code might support storing the clock tick value
in the database, and it would be seriously advanced to allow different columns to
support different clock ticks. The book says that is possible, albeit complex, but
I haven't got around to that chapter or section yet...

Pro Tip: choose a 'forever' value that is basically the maximum possible in your
chosen scalar, for example, timestamp '9999/12/31 23:59:59.999999' (or perhaps relax
a bit and use '9999/12/31 00:00:00' so you don't have to fuss around finding a value
that is one clock-tick shy of ultimate hugeness... The book chooses a clock tick of
1 month (!) simply because it's easier to fit the data when presenting tables in
printed form.

You can base your end-points on any ordinal scalar: fixnum, floats, timestamps, etc.
It is important to note that the code is definitely assuming a clock-tick, as opposed
to pretending to support the real number domain.

What does a clock tick really mean anyway? Glad you asked. It is the smallest distinct
delta between values that you choose to represent. If we were using the Real number
scale, for example, then [x, x) would represent a 'point' ie a span that starts at
x and has no length. When using clock-ticks, [x, x + c) is a 'point' since there is
no representable value between x and x+c, and the duration of any interval [s, e) is
defined as

    e - s - c

because, remember, e is not 'in' the span, for example, using c=1,

    [10, 12) encompasses timestamps 10 and 11, with 12 being excluded.
             length = 12 - 10 - 1 == 1

    [10, 11) encompasses only timestamp 10, which of course must have length 0
             length = 11 - 10 - 1 == 0

Note also that when using clock ticks, [x, x) is an illegal interval.

Choosing a certain sized clock tick means that you will never try to represent a
fraction of a clock-tick in your intervals. If you want to measure down to milliseconds,
choose 0.001 as the clock tick. For microseconds, choose 0.000001 and so on.

The book states:
    An atomic clock tick is the smallest interval of time recognized by the DBMS that
    can elapse between any two physical modifications to a database. We note that the
    standard computer science term for an atomic clock tick is a chronon. A clock tick
    is an interval of time defined on the basis of atomic clock ticks, and that is used
    in an Asserted Versioning database to delimit the two time periods of rows in asserted
    version tables, and also to indicate several important points in time. In asserted
    version tables, clock ticks are used for effective time begin and end dates and for
    episode begin dates; and atomic clock ticks are used for assertion time begin and end
    dates, and for row create dates.

## Overview of Allens Interval Algebra

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

NOTE: A number of higher-level operators exist, offering useful combinations:

    before!     = before?   | after?
    meets!      = meets?    | metBy?
    overlaps!   = overlaps? | overlappedBy?
    starts!     = starts?   | startedBy?
    during!     = during?   | includes?
    finishes!   = finishes? | finishedBy?
    equals!     = equals?                       N.B. defined for consistency

    aligns!     = starts!   | finishes!
    occupies!   = aligns!   | during!
    fills!      = occupies! | equals!
    intersects! = fills!    | overlaps!
    excludes!   = before!   | meets!

From the book:

> As we will see later, four of these Allen relationship categories are especially important. They will be discussed in later chapters, but we choose to mention them here.
> 1. The [intersects] relationship is important because for a temporal insert transaction to be valid, its effective time period cannot intersect that of any episode for the same object which is already in the target table. By the same token, for a temporal update or delete transaction to be valid, the target table must already contain at least one episode for the same object whose effective time period does [intersect] the time period designated by the transaction.
> 2. The [fills] relationship is important because violations of the temporal analog of referential integrity always involve the failure of a child time period to [fill] a parent time period. We will be frequently discussing this relationship from the parent side, and we would like to avoid having to say things like ".... failure of a parent time period to be filled by a child time period". So we will use the term "includes" as a synonym for "is filled by", i.e. as a synonym for [fills−1]. Now we can say "..... failure of a parent time period to include a child time period".
> 3. The [before] relationship is important because it distinguishes episodes from one another. Every episode of an object is non-contiguous with every other episode of the same object, and so for each pair of them, one of them must be [before] the other.
> 4. The [meets] relationship is important because it groups versions for the same object into episodes. A series of versions for the same object that are all contiguous, i.e. that all [meet], fall within the same episode of that object.


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
column, which is slightly more mnemonic while remaining very concise.

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


## Still to do, or discuss properly

* Account for chronons and clock-ticks.
* Given the existence of clock ticks, temporal database theory considers `[x, x + ct)`
to be a 'point'. There are clearly defined rules for how they compare with periods
and other points, as mentioned in chapter 3 of the book.
* Since `[x, x + ct)` is a point, temporal database theory considers `[x, x)` as illegal.


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

