require 'pry'
require 'pry-nav'
require 'ostruct'
require 'set'

# --- Day 10: Hoof It ---
#
# You all arrive at a Lava Production Facility on a floating island in the sky. As the
# others begin to search the massive industrial complex, you feel a small nose boop
# your leg and look down to discover a reindeer wearing a hard hat.
#
# The reindeer is holding a book titled "Lava Island Hiking Guide". However, when you
# open the book, you discover that most of it seems to have been scorched by lava! As
# you're about to ask how you can help, the reindeer brings you a blank topographic
# map of the surrounding area (your puzzle input) and looks up at you excitedly.
#
# Perhaps you can help fill in the missing hiking trails?
#
# The topographic map indicates the height at each position using a scale from 0 (lowest)
# to 9 (highest). For example:
#
ex1 = <<~T
  0123
  1234
  8765
  9876
T
#
# Based on un-scorched scraps of the book, you determine that a good hiking trail is
# as long as possible and has an even, gradual, uphill slope. For all practical purposes,
# this means that a hiking trail is any path that starts at height 0, ends at height
# 9, and always increases by a height of exactly 1 at each step. Hiking trails never
# include diagonal steps - only up, down, left, or right (from the perspective of the
# map).
#
# You look up from the map and notice that the reindeer has helpfully begun to construct
# a small pile of pencils, markers, rulers, compasses, stickers, and other equipment
# you might need to update the map with hiking trails.
#
# A trailhead is any position that starts one or more hiking trails - here, these positions
# will always have height 0. Assembling more fragments of pages, you establish that
# a trailhead's score is the number of 9-height positions reachable from that trailhead
# via a hiking trail. In the above example, the single trailhead in the top left corner
# has a score of 1 because it can reach a single 9 (the one in the bottom left).
#
# This trailhead has a score of 2:
#
ex2 = <<~T
  ...0...
  ...1...
  ...2...
  6543456
  7.....7
  8.....8
  9.....9
T
#
# (The positions marked . are impassable tiles to simplify these examples; they do not
# appear on your actual topographic map.)
#
# This trailhead has a score of 4 because every 9 is reachable via a hiking trail except
# the one immediately to the left of the trailhead:
#
ex3 = <<~T
  ..90..9
  ...1.98
  ...2..7
  6543456
  765.987
  876....
  987....
T
#
# This topographic map contains two trailheads; the trailhead at the top has a score
# of 1, while the trailhead at the bottom has a score of 2:
#
ex4 = <<~T
  10..9..
  2...8..
  3...7..
  4567654
  ...8..3
  ...9..2
  .....01
T
#
# Here's a larger example:
#
ex5 = <<~T
  89010123
  78121874
  87430965
  96549874
  45678903
  32019012
  01329801
  10456732
T
#
# This larger example has 9 trailheads. Considering the trailheads in reading order,
# they have scores of 5, 6, 5, 3, 1, 3, 5, 3, and 5. Adding these scores together, the
# sum of the scores of all trailheads is 36.
#
# The reindeer gleefully carries over a protractor and adds it to the pile. What is
# the sum of the scores of all trailheads on your topographic map?

# part2

def in_bounds(grid, x, y) = y >= 0 && y < grid.length && x >= 0 && x < grid[y].length

def find_trails(grid, v, x, y, steps=[[x,y]])
  return [] unless in_bounds(grid, x, y) && grid[y][x] == v
  return [steps] if v == 9

  return [[0,-1], [1,0], [0,1], [-1,0]]
    .map { |dx,dy| [x+dx, y+dy] }
    .flat_map { |nx, ny| find_trails(grid, v+1, nx, ny, [*steps, [nx,ny]]) }
end

input = DATA.each_line.map(&:chomp)
  .map { _1.chars.map &:to_i }

trails = input
  .each_with_index
  .flat_map { |row,y|
    row.each_index.flat_map { |x| find_trails(input, 0, x, y) }
  }

p trails.group_by(&:first).sum { |_,trail| trail.map(&:last).uniq.size }
p trails.size

__END__
43450121898101101123127821096542109876109701010178732100123
89543230767213210011018912987433234565018892121269823445674
76692145654300398322167903876323398934327743434454310538985
45781096890121497413456874565012367898456658945893239627876
34301587765432586504010567654101256787650167876761128716321
69212657654123677345623498903104345696543238945890029605430
78798748783014988932764567012254330165456783034321212567876
65671239692385976341873018898361221074325892103567103432987
54980178501096845320962129765470398983016783212458932121096
63056789432087730410434038654380147812705654426354345087125
12141010098121621562345549783491236503890123345243216190104
01632120127230541071076678892100345654387654216104507889213
34567836736549032987986323451215456789218943007897628974312
21456945845678123478967810560432365432100122106498710165403
10143210954321787561058927678101870122239231254327633258932
41014787665650196232347678879230989211078540760019824567541
32989690198754345145432589965447854302567659861278212345670
45676543282663232076501430012356967653438945876367109454981
12565654101078101089696321104321898301465438965454308763676
03443233210149230456787012765210147432378921087643214324565
12354104303230142367017633894323456343489012196543285614321
21067865496549651098198544565210769853458786787230198705210
30128956787678741287230133478901898762367698690124354306787
81434567874589230276541024321092432191056567547843265217895
98543210903270141125432011036786543087171256456950174307876
87690123210101432034545822345677604456980344323868789678921
76587434901219541002196953210578912347876501012879652541010
54106545890178654910087864321417823218985012508934541032781
67812656783267067823105675699101830105674327654325872305692
58923565654352158934234789788542987234501458965210987412543
45434565432543112985109898767653676543432569867105676543014
36585676501265003876501234650344567012569678458943489872101
23096987687652134561010105641256788656778323345432156789210
10187321098343458992876596030143299349865410236721005674321
43235497654210167783945987123232101238567892105875414565467
56986788323456434654834565696540342101056701458987323541058
67898129010987543210121078987661254322347892364379834432149
78107038895676695434010187545676765011056789875210778940430
69256546784987786543421296234989807652340676966901667651321
52347875273278987102210345101269218943401205457812567892343
41016934109109873201783210789878347892112312348903454987654
32105123258056724345694569650565756765089401232120123396323
65414014567145014566785478641214898706576587143089875431214
72343217654231123875073456732303743217434896054108566520301
81056108903210154965122109841012656198920125565211257015432
90087612112310568985431018956655654007611234474340348976301
87196456089423478976980167567743763014501765389478930985412
65280367176532032985873265498892892123349874210567321476323
74361298266541141034564972301281045891256103287656212389892
89450127347450230123455881214321236760961210196552101456701
30567255478978743789846790326760987654870300123467896565212
21498766967669652650176543439856101543065465410567887634343
12301457873456781043281012945347892032176978323436998325654
01232346122369897176895678876232103124987869835625213218745
78903498031078108985956589965109654435438932148714301009012
67612567948943267234898434453458789054323845089605687128321
56521019857654456110767021342167658167210756789598796437450
65430018767890301023456130256098943278130349823410145589869
78942123454321212154343210107897650129021231014543234676578

