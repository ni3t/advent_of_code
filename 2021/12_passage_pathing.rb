require 'pry'
require 'pry-nav'
require 'ostruct'
require 'set'

# --- Day 12: Passage Pathing ---
#
# With your submarine's subterranean subsystems subsisting suboptimally, the only way
# you're getting out of this cave anytime soon is by finding a path yourself. Not just
# a path - the only way to know if you've found the best path is to find all of them.
#
# Fortunately, the sensors are still mostly working, and so you build a rough map of
# the remaining caves (your puzzle input). For example:
#
ex1 = <<~T
  start-A
  start-b
  A-c
  A-b
  b-d
  A-end
  b-end
T
#
# This is a list of how all of the caves are connected. You start in the cave named
# start, and your destination is the cave named end. An entry like b-d means that cave
# b is connected to cave d - that is, you can move between them.
#
# So, the above cave system looks roughly like this:
#
ex2 = <<~T
      start
      /   \
  c--A-----b--d
      \   /
       end
T
#
# Your goal is to find the number of distinct paths that start at start, end at end,
# and don't visit small caves more than once. There are two types of caves: big caves
# (written in uppercase, like A) and small caves (written in lowercase, like b). It
# would be a waste of time to visit any small cave more than once, but big caves are
# large enough that it might be worth visiting them multiple times. So, all paths you
# find should visit small caves at most once, and can visit big caves any number of
# times.
#
# Given these rules, there are 10 paths through this example cave system:
#
ex3 = <<~T
  start,A,end
  start,b,end
  start,A,b,end
  start,b,A,end
  start,A,c,A,end
  start,A,b,A,end
  start,A,c,A,b,end
  start,b,A,c,A,end
  start,A,c,A,b,A,end
  start,A,b,A,c,A,end
T
#
# (Each line in the above list corresponds to a single path; the caves visited by that
# path are listed in the order they are visited and separated by commas.)
#
# Note that in this cave system, cave d is never visited by any path: to do so, cave
# b would need to be visited twice (once on the way to cave d and a second time when
# returning from cave d), and since cave b is small, this is not allowed.
#
# Here is a slightly larger example:
#
ex4 = <<~T
  dc-end
  HN-start
  start-kj
  dc-start
  dc-HN
  LN-dc
  HN-end
  kj-sa
  kj-HN
  kj-dc
T
#
# The 19 paths through it are as follows:
#
ex5 = <<~T
  start,HN,dc,HN,end
  start,HN,dc,HN,kj,HN,end
  start,HN,dc,end
  start,HN,dc,kj,HN,end
  start,HN,end
  start,HN,kj,HN,dc,HN,end
  start,HN,kj,HN,dc,end
  start,HN,kj,HN,end
  start,HN,kj,dc,HN,end
  start,HN,kj,dc,end
  start,dc,HN,end
  start,dc,HN,kj,HN,end
  start,dc,end
  start,dc,kj,HN,end
  start,kj,HN,dc,HN,end
  start,kj,HN,dc,end
  start,kj,HN,end
  start,kj,dc,HN,end
  start,kj,dc,end
T
#
# Finally, this even larger example has 226 paths through it:
#
ex6 = <<~T
  fs-end
  he-DX
  fs-he
  start-DX
  pj-DX
  end-zg
  zg-sl
  zg-pj
  pj-he
  RW-he
  fs-DX
  pj-RW
  zg-RW
  start-pj
  he-WI
  zg-he
  pj-fs
  start-RW
T
#
# How many paths through this cave system are there that visit small caves at most once?

# part2

@data = DATA.each_line.map(&:chomp)
@ex1 = ex6.each_line.map(&:chomp)

class Graph
  attr_reader :nodes, :edges

  def initialize
    @nodes = Set.new
    @edges = Set.new
  end

  def add(a, b)
    @nodes << a
    @nodes << b
    @edges << [a, b].sort
  end

  def neighbors(a)
    edges.filter { _1.include? a }.flatten.difference([a, 'start']).uniq
  end

  def paths(start, finish)
    p = []
    to_check = [[start]]
    # puts 'pre'
    # pp to_check
    i = 0
    until to_check.empty?
      checking = to_check.shift
      # puts 'c'
      # pp checking
      neighbors(checking.last).each do |n|
        to_add = checking.dup.push(n)
        tallied = to_add.tally.filter { _1 =~ /[a-z]/}
        if tallied.values.any? { _1 > 2 } || tallied.values.filter { _1 == 2 }.count >= 2
          # puts "found dup in #{to_add}"
        else
          to_check << to_add
        end
      end
      i += 1
      # puts 'post'
      # pp to_check
      closed, to_check = to_check.partition { _1.last == finish }
      p = p.concat(closed)
      closed.map do |c|
        puts "#{c.join(',')} - count=#{p.count} - to_check=#{to_check.count}"
      end
      # puts i
    end
    p
  end
end

graph = Graph.new

@data.each do |line|
  a, b = line.split('-')
  graph.add(a, b)
end

pp graph.paths('start', 'end').count

__END__
start-qs
qs-jz
start-lm
qb-QV
QV-dr
QV-end
ni-qb
VH-jz
qs-lm
qb-end
dr-fu
jz-lm
start-VH
QV-jz
VH-qs
lm-dr
dr-ni
ni-jz
lm-QV
jz-dr
ni-end
VH-dr
VH-ni
qb-HE

