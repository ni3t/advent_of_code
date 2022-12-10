require 'pry'
require 'pry-nav'
require 'ostruct'
require 'set'

# --- Day 9: Rope Bridge ---
#
# This rope bridge creaks as you walk along it. You aren't sure how old it is, or whether
# it can even support your weight.
#
# It seems to support the Elves just fine, though. The bridge spans a gorge which was
# carved out by the massive river far below you.
#
# You step carefully; as you do, the ropes stretch and twist. You decide to distract
# yourself by modeling rope physics; maybe you can even figure out where not to step.
#
# Consider a rope with a knot at each end; these knots mark the head and the tail of
# the rope. If the head moves far enough away from the tail, the tail is pulled toward
# the head.
#
# Due to nebulous reasoning involving Planck lengths, you should be able to model the
# positions of the knots on a two-dimensional grid. Then, by following a hypothetical
# series of motions (your puzzle input) for the head, you can determine how the tail
# will move.
#
# Due to the aforementioned Planck lengths, the rope must be quite short; in fact, the
# head (H) and tail (T) must always be touching (diagonally adjacent and even overlapping
# both count as touching):
#
ex1 = <<~T
  ....
  .TH.
  ....
  
  ....
  .H..
  ..T.
  ....
  
  ...
  .H. (H covers T)
  ...
T
#
# If the head is ever two steps directly up, down, left, or right from the tail, the
# tail must also move one step in that direction so it remains close enough:
#
ex2 = <<~T
  .....    .....    .....
  .TH.. -> .T.H. -> ..TH.
  .....    .....    .....
  
  ...    ...    ...
  .T.    .T.    ...
  .H. -> ... -> .T.
  ...    .H.    .H.
  ...    ...    ...
T
#
# Otherwise, if the head and tail aren't touching and aren't in the same row or column,
# the tail always moves one step diagonally to keep up:
#
ex3 = <<~T
  .....    .....    .....
  .....    ..H..    ..H..
  ..H.. -> ..... -> ..T..
  .T...    .T...    .....
  .....    .....    .....
  
  .....    .....    .....
  .....    .....    .....
  ..H.. -> ...H. -> ..TH.
  .T...    .T...    .....
  .....    .....    .....
T
#
# You just need to work out where the tail goes as the head follows a series of motions.
# Assume the head and the tail both start at the same position, overlapping.
#
# For example:
#
ex4 = <<~T
  R 4
  U 4
  L 3
  D 1
  R 4
  D 1
  L 5
  R 2
T
#
# This series of motions moves the head right four steps, then up four steps, then left
# three steps, then down one step, and so on. After each step, you'll need to update
# the position of the tail if the step means the head is no longer adjacent to the tail.
# Visually, these motions occur as follows (s marks the starting position as a reference
# point):
#
ex5 = <<~T
  == Initial State ==
  
  ......
  ......
  ......
  ......
  H.....  (H covers T, s)
  
  == R 4 ==
  
  ......
  ......
  ......
  ......
  TH....  (T covers s)
  
  ......
  ......
  ......
  ......
  sTH...
  
  ......
  ......
  ......
  ......
  s.TH..
  
  ......
  ......
  ......
  ......
  s..TH.
  
  == U 4 ==
  
  ......
  ......
  ......
  ....H.
  s..T..
  
  ......
  ......
  ....H.
  ....T.
  s.....
  
  ......
  ....H.
  ....T.
  ......
  s.....
  
  ....H.
  ....T.
  ......
  ......
  s.....
  
  == L 3 ==
  
  ...H..
  ....T.
  ......
  ......
  s.....
  
  ..HT..
  ......
  ......
  ......
  s.....
  
  .HT...
  ......
  ......
  ......
  s.....
  
  == D 1 ==
  
  ..T...
  .H....
  ......
  ......
  s.....
  
  == R 4 ==
  
  ..T...
  ..H...
  ......
  ......
  s.....
  
  ..T...
  ...H..
  ......
  ......
  s.....
  
  ......
  ...TH.
  ......
  ......
  s.....
  
  ......
  ....TH
  ......
  ......
  s.....
  
  == D 1 ==
  
  ......
  ....T.
  .....H
  ......
  s.....
  
  == L 5 ==
  
  ......
  ....T.
  ....H.
  ......
  s.....
  
  ......
  ....T.
  ...H..
  ......
  s.....
  
  ......
  ......
  ..HT..
  ......
  s.....
  
  ......
  ......
  .HT...
  ......
  s.....
  
  ......
  ......
  HT....
  ......
  s.....
  
  == R 2 ==
  
  ......
  ......
  .H....  (H covers T)
  ......
  s.....
  
  ......
  ......
  .TH...
  ......
  s.....
T
#
# After simulating the rope, you can count up all of the positions the tail visited
# at least once. In this diagram, s again marks the starting position (which the tail
# also visited) and # marks other positions the tail visited:
#
ex6 = <<~T
  ..##..
  ...##.
  .####.
  ....#.
  s###..
T
#
# So, there are 13 positions the tail visited at least once.
#
# Simulate your complete hypothetical series of motions. How many positions does the
# tail of the rope visit at least once?

# part2

ex4 = <<~T
  R 4
  U 4
  L 3
  D 1
  R 4
  D 1
  L 5
  R 2
T

input = DATA

instructions = input.each_line(chomp: true).reject(&:empty?).map do |line|
  d,n = line.split
  n.to_i.times.map { d }
end.flatten

HXY = [0,0]
TXY = [0,0]
VISITED = [[0,0]]
GRID = -> { 10.times.map { 10.times.map { "." } } }

def move_head(dir)
  case dir
  when "R"
    HXY[0]+=1
  when "L"
    HXY[0]-=1
  when "U"
    HXY[1]+=1
  when "D"
    HXY[1]-=1
  end
end

def move_tail(dir)
  diffx, diffy = [HXY[0]-TXY[0], HXY[1]-TXY[1]]
  VISITED << TXY.dup
  case [diffx, diffy]
  when [2,0]
    TXY[0] += 1
  when [-2,0]
    TXY[0] -= 1
  when [0, 2]
    TXY[1] += 1
  when [0, -2]
    TXY[1] -= 1
  when [1, 2], [2, 1]
    TXY[0] += 1
    TXY[1] += 1
  when [-1, 2], [-2, 1]
    TXY[0] -= 1
    TXY[1] += 1
  when [1, -2], [2, -1]
    TXY[0] += 1
    TXY[1] -= 1
  when [-2, -1], [-1, -2]
    TXY[0] -= 1
    TXY[1] -= 1
  end
end

def print_grid
  puts "---"
  g = GRID.call
  pp [HXY,TXY]
  g[TXY[0]%100][TXY[1]%100] = "T"
  g[HXY[0]%100][HXY[1]%100] = "H"
    puts g.map(&:join).join("\n")
  sleep 0.01
end

instructions.each do |dir|
  move_head(dir)
  move_tail(dir)
  # print_grid
end

pp VISITED.uniq.count + 1

__END__
L 2
R 2
U 1
R 2
U 2
D 2
U 1
L 1
U 1
L 1
D 1
U 1
L 1
R 1
L 2
D 2
R 1
L 2
D 2
L 2
U 1
D 2
R 1
D 1
U 1
D 1
U 2
L 1
U 2
R 1
D 2
L 1
D 1
U 1
L 1
R 1
L 1
U 2
L 1
U 1
L 2
R 2
D 2
U 2
R 1
U 1
D 2
L 1
U 1
D 2
U 1
L 2
U 1
D 2
U 2
L 1
D 2
L 1
U 1
D 1
U 1
D 2
R 2
U 1
L 1
R 2
D 2
R 1
L 1
R 1
D 1
U 1
L 2
U 1
L 1
R 1
D 2
U 1
L 1
D 2
R 2
D 1
U 1
R 2
U 1
D 1
R 2
D 1
R 1
U 2
D 1
L 2
U 2
R 1
L 1
R 2
U 2
L 2
U 2
D 1
U 1
D 2
R 2
U 2
R 1
D 1
R 2
U 2
D 2
U 1
R 1
U 2
D 3
R 1
L 1
D 3
U 3
L 3
D 2
U 3
D 1
R 2
D 2
L 1
U 3
R 1
U 1
R 3
D 1
L 3
R 1
U 1
L 2
D 2
L 1
U 2
D 1
L 2
D 1
U 1
R 2
D 2
U 2
D 1
L 1
R 2
U 3
D 3
U 2
L 1
D 1
U 2
R 3
U 1
D 1
U 3
R 2
U 3
D 2
U 1
R 1
U 2
R 2
U 1
L 1
U 3
L 2
R 1
U 2
D 3
L 1
U 3
D 3
U 3
L 1
D 2
L 2
R 2
D 3
R 3
D 2
R 2
D 3
U 3
R 1
D 3
U 2
R 3
D 2
R 3
U 1
R 2
D 2
U 3
D 3
R 1
U 3
D 1
U 3
D 3
R 2
U 2
D 1
R 3
D 2
U 3
L 1
R 3
L 2
U 1
L 2
U 1
R 1
U 2
R 3
D 2
U 1
L 3
D 2
L 2
D 3
R 1
U 1
R 1
D 1
L 3
D 2
L 3
D 4
R 2
D 4
L 1
D 4
U 2
R 2
U 3
L 4
D 1
R 1
L 4
U 1
D 3
L 2
R 3
U 1
R 2
U 4
D 1
L 2
R 2
D 4
L 2
D 2
R 1
D 2
L 1
U 4
L 3
U 3
R 4
L 3
U 2
D 3
U 2
D 1
L 2
R 1
L 1
R 1
D 3
L 2
D 3
U 2
L 2
R 1
L 2
D 2
R 1
U 3
D 2
L 1
D 2
U 1
L 1
R 1
D 3
U 2
L 4
U 3
R 4
L 2
D 4
R 3
D 4
U 3
R 3
D 3
R 1
U 1
D 2
U 4
D 4
U 3
D 1
L 4
R 2
L 2
U 3
R 2
D 1
R 3
D 1
L 3
R 2
D 1
L 3
U 3
R 4
U 1
L 2
D 3
R 2
U 2
D 4
U 4
D 4
R 3
D 1
U 4
D 3
R 4
U 1
D 2
L 5
R 3
U 1
L 1
D 4
R 3
U 1
R 3
D 5
R 5
D 2
U 2
L 5
R 2
U 1
L 4
R 4
U 3
D 3
U 1
R 4
U 4
R 4
U 3
D 1
L 1
U 2
R 3
L 5
R 3
D 1
R 2
U 1
L 2
D 5
L 2
D 2
U 4
D 2
R 3
L 5
U 4
D 1
L 3
D 4
L 1
D 4
R 2
D 2
R 3
U 2
D 1
R 1
D 4
R 1
D 5
U 4
D 4
R 1
U 2
D 2
L 2
R 1
L 1
D 5
R 4
D 2
U 3
L 1
U 3
L 4
D 5
R 4
U 3
D 1
U 4
L 2
D 5
L 4
R 4
U 4
L 3
U 5
L 1
R 2
L 1
R 1
L 4
R 3
D 3
U 3
L 3
D 4
R 1
L 2
D 4
U 3
L 5
D 1
L 2
U 2
R 2
L 3
R 4
D 4
U 3
D 5
L 3
U 2
L 2
U 2
R 4
L 1
R 6
D 3
R 6
U 1
L 3
R 4
U 3
L 6
R 1
D 3
R 4
D 3
L 1
U 1
D 3
R 2
L 4
U 2
L 2
U 4
D 3
L 5
D 4
L 4
R 2
D 4
L 2
R 5
U 3
D 2
L 1
R 5
D 1
U 1
R 6
L 1
U 4
D 2
R 4
D 5
R 3
U 5
D 1
R 1
D 1
U 6
R 3
U 6
L 3
R 6
D 1
U 1
D 4
U 1
R 1
D 2
U 5
L 5
U 1
L 5
R 5
U 3
R 5
U 4
L 4
U 3
D 5
R 6
L 1
U 3
R 6
L 1
U 6
R 1
L 1
D 3
L 5
R 6
U 2
R 5
U 5
D 5
R 3
U 2
L 6
D 5
L 4
U 5
D 3
U 4
R 3
D 6
U 4
R 4
U 5
L 3
U 5
R 4
L 4
U 3
L 1
R 6
L 4
U 6
D 1
R 4
U 4
L 5
U 3
D 6
L 3
U 1
L 3
R 5
L 5
R 7
D 3
L 4
R 7
U 1
D 2
R 7
U 6
L 2
D 7
L 4
U 4
L 7
D 4
R 7
D 1
U 7
R 4
D 7
U 4
D 4
R 3
L 4
U 3
L 6
D 4
U 1
R 1
U 1
L 7
D 1
U 3
L 3
R 5
U 6
R 5
U 5
L 1
U 5
R 7
D 1
L 6
R 2
L 5
U 3
D 2
U 1
L 2
R 7
U 3
D 6
U 3
D 7
U 2
D 1
U 5
D 2
L 2
U 5
R 1
D 5
U 6
D 5
U 5
L 1
R 7
L 4
U 3
L 7
R 2
L 7
R 5
D 3
L 5
R 2
U 6
L 3
D 6
U 5
L 1
D 7
U 3
L 2
U 7
D 7
R 2
L 1
U 7
L 1
U 3
R 6
D 6
R 6
D 7
L 5
D 4
U 4
D 5
R 5
D 2
R 7
L 4
U 7
R 2
U 3
L 2
R 6
U 8
R 6
D 6
L 7
D 6
L 1
D 4
U 1
D 8
U 8
L 5
R 8
D 1
R 6
U 5
R 3
L 4
D 5
L 2
D 8
U 3
L 7
U 4
D 8
R 6
U 4
L 7
D 8
L 3
U 7
R 1
U 2
R 5
D 2
R 2
U 6
D 1
R 6
L 8
U 5
R 7
U 1
R 5
L 7
D 4
L 7
U 8
L 8
R 4
L 1
D 6
L 6
U 7
L 5
D 1
U 3
R 8
D 2
R 3
L 7
U 5
R 6
L 2
D 2
R 5
L 4
D 1
U 4
L 4
R 7
U 6
D 7
R 1
L 8
D 3
L 7
U 3
R 3
U 1
D 7
R 7
L 7
U 7
L 5
D 1
R 8
U 3
D 1
U 6
R 7
D 6
L 3
D 5
R 8
L 1
U 3
R 2
U 1
R 2
D 5
R 4
L 1
D 4
U 5
R 8
U 2
L 4
R 6
D 1
U 7
D 8
R 1
L 1
U 4
L 2
U 7
D 2
R 7
D 9
U 7
L 1
D 8
R 3
L 1
R 3
U 5
L 5
D 7
U 3
R 4
U 5
L 2
R 2
D 7
R 2
U 4
L 9
R 7
U 6
R 4
U 8
L 2
R 7
U 5
L 6
R 7
U 7
L 4
D 2
L 1
D 4
R 5
U 2
L 3
R 9
U 8
D 5
L 3
U 1
L 2
D 5
L 7
D 7
U 1
L 2
D 8
R 9
L 5
D 8
U 1
L 7
U 9
R 1
L 1
D 3
R 3
U 6
L 4
R 6
L 1
R 6
U 2
R 9
D 3
R 6
U 5
R 9
L 7
D 6
L 9
D 8
R 4
L 3
U 2
R 7
L 5
D 7
U 8
R 5
L 2
D 8
L 4
R 3
D 1
U 3
D 3
U 3
D 3
R 2
L 5
R 9
L 5
U 9
R 3
D 9
L 4
U 3
L 2
R 1
D 1
R 6
D 4
L 6
R 1
D 8
L 3
R 2
D 7
U 2
L 4
R 10
L 9
R 4
L 2
U 10
R 5
D 4
L 7
U 5
L 7
U 7
D 6
U 7
R 5
L 5
D 5
R 10
D 4
L 3
D 4
U 8
L 5
U 5
L 8
R 3
U 5
D 6
L 2
R 1
L 7
U 8
R 2
L 5
R 1
D 2
U 1
L 1
R 5
U 6
D 6
R 2
U 8
L 1
D 8
L 5
R 10
U 7
R 9
D 4
L 4
U 6
D 3
R 3
L 5
R 3
U 6
R 10
U 5
L 6
R 2
D 9
U 2
D 4
U 3
D 2
U 7
L 1
R 3
L 10
U 7
R 7
U 2
R 5
L 3
D 4
R 1
D 3
L 3
R 6
D 6
R 3
L 9
R 3
L 1
D 8
R 9
U 2
D 6
U 2
L 9
U 8
D 2
L 1
U 2
D 10
U 7
R 8
D 4
L 7
U 1
D 1
U 1
L 5
D 5
L 10
R 9
U 5
L 8
D 2
R 2
L 8
D 8
L 11
U 5
L 11
D 9
L 10
U 1
D 9
R 5
U 4
D 2
R 3
L 7
D 7
L 9
R 3
L 3
U 7
R 1
U 4
R 7
D 10
L 8
U 2
L 6
R 1
U 10
D 3
U 2
L 4
D 5
R 6
L 7
R 8
L 4
U 1
D 11
U 5
R 4
L 9
R 8
L 2
R 4
U 10
D 4
R 7
D 3
U 6
D 6
U 3
L 11
R 4
D 6
U 9
R 10
D 8
U 3
R 2
U 7
D 5
R 10
U 5
R 3
U 9
L 2
D 3
U 1
L 10
U 2
L 3
U 10
L 6
D 4
L 1
D 1
U 3
L 10
R 6
L 1
U 2
R 1
L 9
D 4
L 11
U 6
D 3
L 9
U 7
D 3
U 3
R 8
U 11
R 2
D 1
U 3
R 2
L 7
D 5
R 10
U 1
D 10
L 1
U 10
D 11
U 5
R 6
D 6
R 10
L 9
D 3
U 4
L 12
D 7
R 9
U 4
D 10
L 11
U 1
R 3
U 6
L 11
U 10
R 3
U 4
L 9
U 4
L 12
U 4
D 2
L 12
D 12
L 5
U 9
R 7
D 12
L 2
U 3
R 7
D 9
L 2
R 9
D 10
U 6
R 10
D 8
R 8
L 9
U 11
R 5
D 7
U 3
R 7
U 10
R 5
D 4
U 3
D 6
R 11
U 9
L 3
D 5
R 6
L 11
D 5
R 2
D 2
R 8
D 1
U 5
L 3
U 8
L 10
D 7
R 12
D 7
L 8
D 5
U 9
D 10
L 4
R 6
L 9
R 10
L 11
U 8
D 8
R 2
L 5
U 9
R 1
L 12
D 6
R 11
L 4
R 6
U 12
D 5
U 4
L 7
D 2
R 5
U 5
D 7
R 10
L 9
U 4
D 11
U 12
D 6
U 4
L 3
U 4
R 11
D 7
L 11
R 9
U 2
R 7
D 5
U 13
L 10
U 9
L 9
U 4
D 8
R 7
L 8
U 3
L 1
U 6
D 11
U 11
D 12
L 13
U 13
R 8
D 4
U 6
D 3
U 9
R 11
D 6
R 9
D 1
U 8
D 9
R 2
U 3
R 13
D 7
U 6
D 10
U 13
D 4
U 1
R 10
D 9
U 8
D 7
U 7
L 13
R 10
L 8
D 7
U 9
R 8
L 8
U 3
D 5
L 1
U 5
D 9
R 2
D 8
L 7
U 2
R 11
U 9
D 7
L 2
D 9
R 8
L 12
R 4
D 7
U 2
L 8
U 12
D 11
R 9
U 9
R 13
U 3
L 9
U 9
R 5
U 10
R 13
U 6
D 4
U 2
R 7
D 3
R 1
L 4
R 9
L 3
D 6
L 9
R 6
D 1
L 6
D 5
U 10
R 2
L 1
R 1
L 1
U 9
D 5
U 2
D 12
L 9
U 1
L 14
U 9
L 11
R 11
L 3
D 5
U 5
D 8
L 9
U 12
R 11
L 1
D 9
R 9
L 7
D 7
U 4
D 5
L 11
D 9
R 13
D 3
R 9
D 6
U 12
L 2
D 10
L 6
U 12
R 2
D 9
R 2
D 12
R 14
U 3
R 3
D 12
R 13
U 1
D 11
L 1
D 9
U 11
R 9
D 10
L 7
D 13
R 10
D 2
U 7
L 7
R 14
D 10
R 9
D 13
L 7
U 5
R 4
D 4
R 3
U 8
D 8
R 4
U 14
R 8
U 12
D 6
L 11
D 12
U 13
L 13
U 8
L 2
R 7
U 1
L 14
R 1
D 1
L 9
U 1
R 8
U 7
D 13
U 1
D 5
L 8
R 13
L 1
U 14
L 11
D 7
R 7
L 8
U 8
D 9
U 14
L 1
U 7
D 7
L 12
D 7
L 4
U 14
R 2
D 3
U 9
L 9
D 13
U 9
D 5
U 11
D 6
U 10
L 10
R 8
D 11
L 3
R 6
D 10
R 11
L 3
D 15
R 6
D 12
U 4
R 5
L 15
D 9
L 5
U 12
R 2
D 14
U 10
L 1
U 14
L 5
D 12
U 11
D 6
L 12
R 2
D 9
L 15
D 6
L 3
U 6
L 8
R 6
L 11
U 12
L 2
R 12
U 15
D 15
U 1
L 4
R 3
D 9
U 9
D 2
U 2
R 6
U 1
L 4
R 5
L 8
R 2
U 6
D 13
R 12
L 13
D 3
L 9
U 5
R 5
D 3
R 8
L 7
R 12
L 11
U 9
L 4
D 9
U 13
R 15
D 13
U 12
R 1
L 14
R 5
L 8
U 6
D 5
U 6
D 7
U 14
D 4
R 6
L 7
U 4
L 12
D 7
U 11
L 3
R 4
U 4
L 9
U 10
R 9
D 15
R 9
D 6
L 4
U 2
L 5
R 9
L 8
R 2
D 5
U 8
D 11
L 10
R 1
U 10
L 10
U 8
L 8
R 16
U 9
D 5
L 8
D 3
L 5
R 3
U 7
R 9
U 3
D 5
U 11
R 5
L 7
D 3
R 15
U 8
R 12
U 1
D 1
R 12
L 15
D 5
R 5
U 12
R 11
L 7
U 13
L 9
R 14
U 13
D 15
R 15
D 9
U 3
L 15
D 15
U 8
L 2
U 4
D 5
L 10
R 5
D 15
U 15
L 11
U 7
L 3
D 6
L 9
D 9
U 11
L 9
U 2
R 14
L 13
U 8
D 13
R 5
U 5
L 5
U 15
D 8
U 15
R 3
U 12
L 3
D 9
U 12
D 10
R 6
L 16
D 14
L 10
R 11
U 9
R 3
U 15
L 10
U 14
L 1
D 13
R 4
U 8
R 10
D 2
U 1
L 2
D 9
R 10
L 15
D 7
R 5
D 12
L 1
R 8
D 14
U 4
D 11
R 12
L 3
D 6
U 6
D 12
L 15
U 4
L 3
R 10
L 9
D 5
R 17
U 12
R 2
L 2
D 15
U 4
R 4
L 17
R 8
U 12
R 1
L 3
D 1
R 7
L 13
U 14
D 1
U 5
L 2
R 5
L 9
U 6
D 5
R 14
U 11
D 7
L 10
D 10
L 17
R 2
U 9
D 7
L 15
R 8
D 16
L 15
D 8
L 4
U 4
D 5
R 4
D 15
L 8
D 11
L 5
U 5
D 4
R 14
U 16
R 8
L 2
R 16
L 5
U 15
D 13
L 5
U 5
D 6
R 1
L 4
R 4
U 6
D 11
L 8
R 9
U 8
R 10
U 1
L 13
R 10
L 8
D 11
U 9
L 7
U 5
L 15
D 5
R 3
D 16
L 2
U 12
R 15
U 9
L 13
U 15
L 4
U 3
R 3
L 13
D 5
U 16
R 5
D 5
U 9
L 7
U 10
D 1
R 2
U 14
L 13
U 1
L 12
U 10
D 3
U 1
R 14
D 14
U 16
R 6
U 14
D 5
L 18
D 18
U 8
L 2
R 5
D 17
U 18
R 2
L 10
D 6
R 17
L 10
U 1
R 8
L 14
U 10
R 7
L 16
U 9
D 13
U 2
L 1
D 14
U 15
R 15
D 2
R 13
D 3
R 9
D 18
R 16
L 1
R 3
U 1
R 1
U 16
D 17
U 1
D 11
R 11
D 1
U 5
R 1
L 1
R 10
D 5
R 1
D 15
R 14
L 5
U 12
L 8
R 6
D 8
L 5
D 11
L 14
D 5
R 15
L 16
R 12
L 10
D 8
L 3
R 1
D 10
U 13
D 7
U 10
L 13
D 8
R 7
L 13
R 4
L 9
U 6
D 14
L 16
D 18
R 13
U 13
L 17
R 5
U 9
R 11
D 18
R 16
L 4
D 8
R 18
L 14
R 11
D 14
R 2
D 6
L 12
D 3
U 3
L 4
D 7
L 4
D 6
L 12
D 9
L 2
R 16
L 12
U 4
L 12
U 4
R 17
L 8
U 8
R 11
U 14
D 15
L 19
R 1
L 16
R 3
U 15
R 5
L 1
D 17
L 13
U 14
D 9
U 3
L 7
R 11
D 7
R 15
L 6
U 17
R 17
D 17
U 18
L 1
R 8
L 7
D 9
L 5
D 1
R 2
D 16
U 18
D 7
U 13
L 10
U 15
R 18
U 7
L 9
R 6
U 18
R 9
D 8
L 6
R 7
L 11
U 12
R 7
D 4
U 8
R 16
U 17
D 4
U 10
L 19
D 14
L 12
R 18
D 4
R 9
U 12
R 14
U 9
L 16
D 14
U 7
R 14
L 19
U 16
L 18
U 1
R 19
D 7
R 6
U 12
L 16
R 16
U 16
L 6
R 18
L 19
U 10
D 15
U 7
D 1
U 7
L 12
U 4
R 5
U 12
R 18
D 15
U 4
L 8
U 18
D 18
L 3
R 19
L 15
R 11
U 1
R 6
L 8
R 1
L 3