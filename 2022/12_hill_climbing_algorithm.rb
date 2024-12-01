require 'pry'
require 'pry-nav'
require 'ostruct'
require 'set'

# --- Day 12: Hill Climbing Algorithm ---
#
# You try contacting the Elves using your handheld device, but the river you're following
# must be too low to get a decent signal.
#
# You ask the device for a heightmap of the surrounding area (your puzzle input). The
# heightmap shows the local area from above broken into a grid; the elevation of each
# square of the grid is given by a single lowercase letter, where a is the lowest elevation,
# b is the next-lowest, and so on up to the highest elevation, z.
#
# Also included on the heightmap are marks for your current position (S) and the location
# that should get the best signal (E). Your current position (S) has elevation a, and
# the location that should get the best signal (E) has elevation z.
#
# You'd like to reach E, but to save energy, you should do it in as few steps as possible.
# During each step, you can move exactly one square up, down, left, or right. To avoid
# needing to get out your climbing gear, the elevation of the destination square can
# be at most one higher than the elevation of your current square; that is, if your
# current elevation is m, you could step to elevation n, but not to elevation o. (This
# also means that the elevation of the destination square can be much lower than the
# elevation of your current square.)
#
# For example:
#
ex1 = <<~T
  Sabqponm
  abcryxxl
  accszExk
  acctuvwj
  abdefghi
T
#
# Here, you start in the top-left corner; your goal is near the middle. You could start
# by moving down or right, but eventually you'll need to head toward the e at the bottom.
# From there, you can spiral around to the goal:
#
ex2 = <<~T
  v..v<<<<
  >v.vv<<^
  .>vv>E^^
  ..v>>>^^
  ..>>>>>^
T
#
# In the above diagram, the symbols indicate whether the path exits each square moving
# up (^), down (v), left (<), or right (>). The location that should get the best signal
# is still E, and . marks unvisited squares.
#
# This path reaches the goal in 31 steps, the fewest possible.
#
# What is the fewest steps required to move from your current position to the location
# that should get the best signal?

# part2

@data = DATA.each_line.map(&:chomp)
@ex1 = ex1.each_line.map(&:chomp)

@ex1.each_line.map(&:chomp).each do |line|
  _, *args = line.match(//).to_a
  _ = *args
end

__END__
abcccccccaaaaaccccaaaaaaaccccccccccccccccccccccccccccccccccccaaaaa
abaacccaaaaaaccccccaaaaaaaaaaaaaccccccccccccccccccccccccccccaaaaaa
abaacccaaaaaaaccccaaaaaaaaaaaaaacccccccccccccaacccccccccccccaaaaaa
abaacccccaaaaaacaaaaaaaaaaaaaaaacccccccccccccaacccccccccccccacacaa
abaccccccaaccaacaaaaaaaaaacccaacccccccccccccaaacccccccccccccccccaa
abcccccccaaaacccaaaaaaaaacccccccccccccaaacccaaacccccccccccccccccaa
abccccccccaaaccccccccaaaacccccccccccccaaaaacaaaccacacccccccccccccc
abccccccccaaacaaacccccaaacccccccccccccaaaaaaajjjjjkkkcccccaacccccc
abcccccaaaaaaaaaacccccaaccccccccccciiiiiijjjjjjjjjkkkcaaaaaacccccc
abcccccaaaaaaaaacccccccccccccccccciiiiiiijjjjjjjrrkkkkaaaaaaaacccc
abcccccccaaaaaccccccccccccccccccciiiiiiiijjjjrrrrrppkkkaaaaaaacccc
abcccaaccaaaaaacccccccccccaacaaciiiiqqqqqrrrrrrrrpppkkkaaaaaaacccc
abccaaaaaaaaaaaaccccacccccaaaaaciiiqqqqqqrrrrrruuppppkkaaaaacccccc
abcccaaaaaaacaaaacaaacccccaaaaaahiiqqqqtttrrruuuuupppkkaaaaacccccc
abcaaaaaaaccccaaaaaaacccccaaaaaahhqqqtttttuuuuuuuuuppkkkccaacccccc
abcaaaaaaaaccccaaaaaacccccaaaaaahhqqqtttttuuuuxxuuuppkklcccccccccc
abcaaaaaaaacaaaaaaaaaaacccccaaachhhqqtttxxxuuxxyyuuppllllccccccccc
abcccaaacaccaaaaaaaaaaaccccccccchhhqqtttxxxxxxxyuupppplllccccccccc
abaacaacccccaaaaaaaaaaaccccccccchhhqqtttxxxxxxyyvvvpppplllcccccccc
abaacccccccccaaaaaaacccccccccccchhhpppttxxxxxyyyvvvvpqqqlllccccccc
SbaaccccccaaaaaaaaaaccccccccccchhhppptttxxxEzzyyyyvvvqqqlllccccccc
abaaaaccccaaaaaaaaacccccccccccchhhpppsssxxxyyyyyyyyvvvqqqlllcccccc
abaaaacccccaaaaaaaacccccccccccgggpppsssxxyyyyyyyyyvvvvqqqlllcccccc
abaaacccaaaacaaaaaaaccccccccccgggpppsswwwwwwyyyvvvvvvqqqllllcccccc
abaaccccaaaacaaccaaaacccccccccgggppssswwwwwwyyywvvvvqqqqmmmccccccc
abaaccccaaaacaaccaaaaccaaaccccggpppssssswwswwyywvqqqqqqmmmmccccccc
abcccccccaaacccccaaacccaaacaccgggpppssssssswwwwwwrqqmmmmmccccccccc
abcccccccccccccccccccaacaaaaacgggppooosssssrwwwwrrrmmmmmcccccccccc
abcccccccccccccccccccaaaaaaaacggggoooooooorrrwwwrrnmmmdddccaaccccc
abaccccccccccccaacccccaaaaaccccggggoooooooorrrrrrrnmmddddcaaaccccc
abaccccccccaaaaaaccccccaaaaaccccggfffffooooorrrrrnnndddddaaaaccccc
abaacccccccaaaaaacccccaaaaaacccccffffffffoonrrrrrnnndddaaaaaaacccc
abaaccccccccaaaaaaaccacaaaacccccccccffffffonnnnnnnndddaaaaaaaacccc
abccccccccccaaaaaaaaaaaaaaaccccccccccccfffennnnnnnddddccaaaccccccc
abcccccccccaaaaaaacaaaaaaaaaacccccccccccffeennnnnedddccccaaccccccc
abcccccccccaaaaaaccaaaaaaaaaaaccccccccccaeeeeeeeeeedcccccccccccccc
abccccccccccccaaaccaaaaaaaaaaaccccccccccaaaeeeeeeeecccccccccccccaa
abcccccccaaccccccccaaaaaaaacccccccccccccaaaceeeeecccccccccccccccaa
abaaccaaaaaaccccccccaaaaaaaacccccccccccccaccccaaacccccccccccaaacaa
abaaccaaaaacccccaaaaaaaaaaacccccccccccccccccccccacccccccccccaaaaaa
abaccaaaaaaaaccaaaaaaaaaaaaaacccccccccccccccccccccccccccccccaaaaaa

