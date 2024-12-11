require 'pry'
require 'pry-nav'
require 'ostruct'
require 'set'

# --- Day 11: Plutonian Pebbles ---
#
# The ancient civilization on Pluto was known for its ability to manipulate spacetime,
# and while the Historians explore their infinite corridors, you've noticed a strange
# set of physics-defying stones.
#
# At first glance, they seem like normal stones: they're arranged in a perfectly straight
# line, and each stone has a number engraved on it.
#
# The strange part is that every time you blink, the stones change.
#
# Sometimes, the number engraved on a stone changes. Other times, a stone might split
# in two, causing all the other stones to shift over a bit to make room in their perfectly
# straight line.
#
# As you observe them for a while, you find that the stones have a consistent behavior.
# Every time you blink, the stones each simultaneously change according to the first
# applicable rule in this list:
#
# - If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
# - If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone. (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
# - If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.
#
# No matter how the stones change, their order is preserved, and they stay on their
# perfectly straight line.
#
# How will the stones evolve if you keep blinking at them? You take a note of the number
# engraved on each stone in the line (your puzzle input).
#
# If you have an arrangement of five stones engraved with the numbers 0 1 10 99 999
# and you blink once, the stones transform as follows:
#
# - The first stone, 0, becomes a stone marked 1.
# - The second stone, 1, is multiplied by 2024 to become 2024.
# - The third stone, 10, is split into a stone marked 1 followed by a stone marked 0.
# - The fourth stone, 99, is split into two stones marked 9.
# - The fifth stone, 999, is replaced by a stone marked 2021976.
#
# So, after blinking once, your five stones would become an arrangement of seven stones
# engraved with the numbers 1 2024 1 0 9 9 2021976.
#
# Here is a longer example:
#
ex1 = <<~T
  Initial arrangement:
  125 17
  
  After 1 blink:
  253000 1 7
  
  After 2 blinks:
  253 0 2024 14168
  
  After 3 blinks:
  512072 1 20 24 28676032
  
  After 4 blinks:
  512 72 2024 2 0 2 4 2867 6032
  
  After 5 blinks:
  1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32
  
  After 6 blinks:
  2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2
T
#
# In this example, after blinking six times, you would have 22 stones. After blinking
# 25 times, you would have 55312 stones!
#
# Consider the arrangement of stones in front of you. How many stones will you have
# after blinking 25 times?

# part2

data = "2 54 992917 5270417 2514 28561 0 990"
stones = data.split

MAP = {}

def how_many_eventually(x, iters)
  x = x.to_i.to_s
  return MAP[[x,iters]] if MAP[[x,iters]]
  if iters == 0
    1
  elsif x.to_i == 0
    res = how_many_eventually("1", iters - 1)
    MAP[[x,iters]] = res
    res
  elsif x.length % 2 == 0
    a = x[0..x.length/2-1]
    b = x[x.length/2..-1]
    res = [
      how_many_eventually(a, iters - 1),
      how_many_eventually(b, iters - 1)
    ]
    MAP[[x,iters]] = res.flatten.sum
    res.flatten.sum
  else
    res = how_many_eventually((x.to_i * 2024).to_s, iters - 1)
    MAP[[x,iters]] = res
    res
  end
end

puts stones.map {|s| how_many_eventually(s, 25)}.flatten.sum
puts stones.map {|s| how_many_eventually(s, 75)}.flatten.sum

__END__
2 54 992917 5270417 2514 28561 0 990
