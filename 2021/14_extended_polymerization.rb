require 'pry'
require 'pry-nav'
require 'ostruct'
require 'set'

# --- Day 14: Extended Polymerization ---
#
# The incredible pressures at this depth are starting to put a strain on your submarine.
# The submarine has polymerization equipment that would produce suitable materials to
# reinforce the submarine, and the nearby volcanically-active caves should even have
# the necessary input elements in sufficient quantities.
#
# The submarine manual contains instructions for finding the optimal polymer formula;
# specifically, it offers a polymer template and a list of pair insertion rules (your
# puzzle input). You just need to work out what polymer would result after repeating
# the pair insertion process a few times.
#
# For example:
#
ex1 = <<~T
  NNCB
  
  CH -> B
  HH -> N
  CB -> H
  NH -> C
  HB -> C
  HC -> B
  HN -> C
  NN -> C
  BH -> H
  NC -> B
  NB -> B
  BN -> B
  BB -> N
  BC -> B
  CC -> N
  CN -> C
T
#
# The first line is the polymer template - this is the starting point of the process.
#
# The following section defines the pair insertion rules. A rule like AB -> C means
# that when elements A and B are immediately adjacent, element C should be inserted
# between them. These insertions all happen simultaneously.
#
# So, starting with the polymer template NNCB, the first step simultaneously considers
# all three pairs:
#
# - The first pair (NN) matches the rule NN -> C, so element C is inserted between the first N and the second N.
# - The second pair (NC) matches the rule NC -> B, so element B is inserted between the N and the C.
# - The third pair (CB) matches the rule CB -> H, so element H is inserted between the C and the B.
#
# Note that these pairs overlap: the second element of one pair is the first element
# of the next pair. Also, because all pairs are considered simultaneously, inserted
# elements are not considered to be part of a pair until the next step.
#
# After the first step of this process, the polymer becomes NCNBCHB.
#
# Here are the results of a few steps using the above rules:
#
ex2 = <<~T
  Template:     NNCB
  After step 1: NCNBCHB
  After step 2: NBCCNBBBCBHCB
  After step 3: NBBBCNCCNBBNBNBBCHBHHBCHB
  After step 4: NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB
T
#
# This polymer grows quickly. After step 5, it has length 97; After step 10, it has
# length 3073. After step 10, B occurs 1749 times, C occurs 298 times, H occurs 191
# times, and N occurs 865 times; taking the quantity of the most common element (B,
# 1749) and subtracting the quantity of the least common element (H, 161) produces 1749
# - 161 = 1588.
#
# Apply 10 steps of pair insertion to the polymer template and find the most and least
# common elements in the result. What do you get if you take the quantity of the most
# common element and subtract the quantity of the least common element?

# --- Part Two ---
#
# The resulting polymer isn't nearly strong enough to reinforce the submarine. You'll
# need to run more steps of the pair insertion process; a total of 40 steps should do
# it.
#
# In the above example, the most common element is B (occurring 2192039569602 times)
# and the least common element is H (occurring 3849876073 times); subtracting these
# produces 2188189693529.
#
# Apply 40 steps of pair insertion to the polymer template and find the most and least
# common elements in the result. What do you get if you take the quantity of the most
# common element and subtract the quantity of the least common element?

@data = DATA.each_line.map(&:chomp)
@ex1 = ex1.each_line.map(&:chomp)

template = nil
instructions = {}

@data.each do |line|
  next if line == ''

  if template.nil?
    template ||= line.strip.chars
  else
    two, third = line.split(' -> ').map(&:strip)
    first, second = two.split('')
    instructions[[first, second]] = third
  end
end

def ans(c, tm)
  t = Hash.new(0)
  c.each { t[_1.first] += _2 }
  t[tm[-1]] += 1
  p t.values.max - t.values.min
end

counts = Hash.new(0)
template.each_cons(2) { counts[[_1, _2]] += 1 }
40.times.each do |i|
  old = counts.dup
  counts = Hash.new(0)
  old.each do |(a, b), v|
    found = instructions[[a, b]]
    counts[[a, found]] += v
    counts[[found, b]] += v
  end
  ans(counts, template) if i + 1 == 10 || i + 1 == 40
end

__END__
VOKKVSKKPSBVOOKVCFOV

PK -> P
BB -> V
SO -> O
OO -> V
PV -> O
CB -> H
FH -> F
SC -> F
KF -> C
VS -> O
VP -> V
FS -> K
SP -> C
FC -> N
CF -> C
BF -> V
FN -> K
NH -> F
OB -> F
SV -> H
BN -> N
OK -> K
NF -> S
OH -> S
FV -> B
OC -> F
VF -> V
HO -> H
PS -> N
NB -> N
NS -> B
OS -> P
CS -> S
CH -> N
PC -> N
BH -> F
HP -> P
HH -> V
BK -> H
HC -> B
NK -> S
SB -> C
NO -> K
SN -> H
VV -> N
ON -> P
VN -> H
VB -> P
BV -> O
CV -> N
HV -> C
SH -> C
KV -> F
BC -> O
OF -> P
NN -> C
KN -> F
CO -> C
HN -> P
PP -> V
FP -> O
CP -> S
FB -> F
CN -> S
VC -> C
PF -> F
PO -> B
KB -> H
HF -> P
SK -> P
SF -> H
VO -> N
HK -> C
HB -> C
OP -> B
SS -> V
NV -> O
KS -> N
PH -> H
KK -> B
HS -> S
PN -> F
OV -> S
PB -> S
NC -> B
BS -> N
KP -> C
FO -> B
FK -> N
BP -> C
NP -> C
KO -> C
VK -> K
FF -> C
VH -> H
CC -> F
BO -> S
KH -> B
CK -> K
KC -> C

