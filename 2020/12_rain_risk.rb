require 'pry'
require 'pry-nav'
require 'ostruct'
# --- Day 12: Rain Risk ---Your ferry made decent progress toward the island, but the
# storm came in faster than anyone expected. The ferry needs to take evasive actions!
#
# Unfortunately, the ship's navigation computer seems to be malfunctioning; rather than
# giving a route directly to safety, it produced extremely circuitous instructions.
# When the captain uses the PA system to ask if anyone can help, you quickly volunteer.
#
# The navigation instructions (your puzzle input) consists of a sequence of single-character
# actions paired with integer input values. After staring at them for a few minutes,
# you work out what they probably mean:
#
# Action N means to move north by the given value.
# Action S means to move south by the given value.
# Action E means to move east by the given value.
# Action W means to move west by the given value.
# Action L means to turn left the given number of degrees.
# Action R means to turn right the given number of degrees.
# Action F means to move forward by the given value in the direction the ship is currently
# facing.
#
# The ship starts by facing east. Only the L and R actions change the direction the
# ship is facing. (That is, if the ship is facing east and the next instruction is N10,
# the ship would move north 10 units, but would still move east if the following action
# were F.)
#
# For example:
ex1 = <<~T
  F10
  N3
  F7
  R90
  F11
T
#
# These instructions would be handled as follows:
#
#
# F10 would move the ship 10 units east (because the ship starts by facing east) to
# east 10, north 0.
# N3 would move the ship 3 units north to east 10, north 3.
# F7 would move the ship another 7 units east (because the ship is still facing east)
# to east 17, north 3.
# R90 would cause the ship to turn right by 90 degrees and face south; it remains at
# east 17, north 3.
# F11 would move the ship 11 units south to east 17, south 8.
#
# At the end of these instructions, the ship's Manhattan distance (sum of the absolute
# values of its east/west position and its north/south position) from its starting position
# is 17 + 8 = 25.
#
# Figure out where the navigation instructions lead. What is the Manhattan distance
# between that location and the ship's starting position?
#

Ship = Struct.new(:x, :y, :dir, :wpx, :wpy) do
  LEFT_DIR = %w[E N W S].freeze
  RIGHT_DIR = %w[E S W N].freeze

  def move_in_dir(dir, len)
    if dir == 'N'
      self.y += len
    elsif dir == 'S'
      self.y -= len
    elsif dir == 'E'
      self.x += len
    else
      self.x -= len
    end
  end

  def moveforward(len)
    move_in_dir(dir, len)
  end

  def setdir(rot, deg)
    arr = rot == 'R' ? RIGHT_DIR : LEFT_DIR
    res = arr.rotate(arr.index(dir))
             .rotate(deg / 90)
             .first
    self.dir = res
  end

  def man
    x.abs + y.abs
  end

  def reset!
    self.x = 0
    self.y = 0
    self.dir = 'E'
    self.wpx = 10
    self.wpy = 1
  end

  def wpmove(len)
    self.x += len * wpx
    self.y += len * wpy
  end

  def movewp(dir, len)
    if dir == 'N'
      self.wpy += len
    elsif dir == 'S'
      self.wpy -= len
    elsif dir == 'E'
      self.wpx += len
    else
      self.wpx -= len
    end
  end

  def rotwp(rot, deg)
    if rot == 'R'
      (deg / 90).times do
        self.wpx, self.wpy = [self.wpy, (self.wpx * -1)]
      end
    else
      (deg / 90).times do
        self.wpx, self.wpy = [(self.wpy * -1), self.wpx]
      end
    end
  end
end
SHIP = Ship.new(0, 0, 'E', 10, 1)

ex1.each_line.map do |line|
  _, instruction, degree = line.match(/(\w)(\d+)/).to_a
  degree = degree.to_i
  SHIP.move_in_dir(instruction, degree) if %w[N S E W].include?(instruction)
  SHIP.setdir(instruction, degree) if %w[L R].include?(instruction)
  SHIP.moveforward(degree) if instruction == 'F'
end

puts SHIP.man
SHIP.reset!

# --- Part Two ---Before you can give the destination to the captain, you realize that
# the actual action meanings were printed on the back of the instructions the whole
# time.
#
# Almost all of the actions indicate how to move a waypoint which is relative to the
# ship's position:
#
#
# Action N means to move the waypoint north by the given value.
#
# Action S means to move the waypoint south by the given value.
#
# Action E means to move the waypoint east by the given value.
#
# Action W means to move the waypoint west by the given value.
#
# Action L means to rotate the waypoint around the ship left (counter-clockwise) the
# given number of degrees.
#
# Action R means to rotate the waypoint around the ship right (clockwise) the given
# number of degrees.
#
# Action F means to move forward to the waypoint a number of times equal to the given
# value.
#
#
# The waypoint starts 10 units east and 1 unit north relative to the ship. The waypoint
# is relative to the ship; that is, if the ship moves, the waypoint moves with it.
#
# For example, using the same instructions as above:
#
#
# F10 moves the ship to the waypoint 10 times (a total of 100 units east and 10 units
# north), leaving the ship at east 100, north 10. The waypoint stays 10 units east and
# 1 unit north of the ship.
#
# N3 moves the waypoint 3 units north to 10 units east and 4 units north of the ship.
# The ship remains at east 100, north 10.
#
# F7 moves the ship to the waypoint 7 times (a total of 70 units east and 28 units north),
# leaving the ship at east 170, north 38. The waypoint stays 10 units east and 4 units
# north of the ship.
#
# R90 rotates the waypoint around the ship clockwise 90 degrees, moving it to 4 units
# east and 10 units south of the ship. The ship remains at east 170, north 38.
#
# F11 moves the ship to the waypoint 11 times (a total of 44 units east and 110 units
# south), leaving the ship at east 214, south 72. The waypoint stays 4 units east and
# 10 units south of the ship.
#
#
# After these operations, the ship's Manhattan distance from its starting position is
# 214 + 72 = 286.
#
# Figure out where the navigation instructions actually lead. What is the Manhattan
# distance between that location and the ship's starting position?
#

DATA.each_line do |line|
  _, instruction, degree = line.match(/(\w)(\d+)/).to_a
  degree = degree.to_i
  SHIP.movewp(instruction, degree) if %w[N S E W].include?(instruction)
  SHIP.rotwp(instruction, degree) if %w[L R].include?(instruction)
  SHIP.wpmove(degree) if instruction == 'F'
end

puts SHIP.man

__END__
R180
S4
L90
S2
R90
W3
F30
R90
W3
L90
F68
L90
E5
F88
S1
L90
F46
W5
F51
S2
L90
F53
S5
F19
W2
L90
F91
E2
S3
F83
N5
F79
W1
S3
F11
E4
F53
W4
S5
R90
E1
F76
R90
F47
E5
R90
W3
R90
S5
L180
W5
N4
F10
S2
R90
S4
W4
F29
S5
F34
E2
S4
R90
F73
N2
F43
W1
N4
R90
S3
F26
S5
W1
N5
R90
W3
F29
R90
W4
F81
R90
E5
S4
W1
F73
N2
E1
F66
L90
E4
S4
E3
N2
F34
L90
W1
F13
S4
E2
F21
N5
E5
N2
F65
L90
N3
R270
F49
E5
L90
E5
R90
F20
S4
F99
W3
N2
E5
L90
F94
R90
S2
R90
S3
F47
S3
R90
F71
W1
R90
N4
E5
S1
F72
L90
F18
E5
F94
L270
F80
W5
R180
N1
F40
R180
N1
E3
N5
F29
R90
E1
R90
E3
L180
E3
R90
S2
L90
E3
L180
F80
E2
S5
E1
N2
L180
F25
N2
L90
F66
R90
F48
N3
L180
N3
R90
E5
R90
F52
R180
S5
L270
S4
L90
F53
S4
W3
W4
F36
W2
N2
N4
L90
W1
R90
E4
F30
N5
W1
S2
W5
F98
W1
N1
F92
L180
N2
R90
S4
L90
F66
N3
L90
F33
W2
S2
E4
F8
W2
L180
F15
S1
E1
F14
S1
W2
L270
F86
E1
R180
W5
R90
N3
L90
N5
E1
F78
N1
L90
F1
F73
R90
F68
W4
F79
F34
N5
R180
E5
L180
S3
W5
F27
R180
F70
R90
S4
F62
L180
N3
R90
S5
F4
R90
S5
W2
N5
R90
F81
L90
N1
F32
E2
N1
W2
L180
E5
R180
S3
E3
R90
S3
F1
N5
E3
F60
W2
F58
L180
S2
E3
L90
F36
L90
E4
E1
F29
W2
R90
R180
N3
L90
R180
S5
W1
F13
R90
W5
S2
R180
F16
W4
L90
W2
S5
F25
R90
F40
L90
L90
F76
S2
R180
N2
R180
W4
S5
F61
N4
E1
F57
E5
F72
W4
F61
R90
S4
F52
W2
N1
F30
L90
F59
N1
L90
W2
N2
F51
E5
F16
S1
W3
L90
F92
E3
N2
F22
L180
N3
F10
E4
N2
F43
R90
F99
S3
R180
E1
S1
W2
L180
F56
N3
F6
N4
F21
L90
N4
L180
N4
F15
E5
S3
W1
F57
E3
S4
W3
L90
S3
L90
F41
E1
S5
L90
F63
N4
F89
F57
S1
L90
S4
L180
F96
L180
N5
E4
L90
E1
S1
F77
S3
L90
E4
L90
E5
L90
N3
L180
S1
N2
L90
N3
R90
F45
R180
F57
N3
R90
E4
L180
F37
L90
W2
R90
S1
R90
N3
F77
W5
F80
S1
S5
R90
N5
E5
S3
L270
F15
L180
W5
F48
E1
L180
S4
E1
S4
W5
F76
S1
E1
S1
F55
L90
F70
R180
R90
E4
R90
S3
E2
S3
F84
S4
W3
F100
R90
S1
L90
F37
W4
F3
R180
N3
R90
L90
W2
F28
R270
N5
R180
S2
E4
F54
L90
W5
R90
F79
N3
R90
F34
W1
N3
F76
W3
F2
W1
L90
R90
F72
N1
E3
F79
W1
L90
F8
E4
F87
E2
F4
S3
L90
F100
F94
E4
R270
S1
E2
F70
E4
L90
S2
W5
L90
S5
W2
S2
W5
F19
E2
E1
F62
L90
F55
E3
R180
F74
S3
W2
F66
L180
F32
W5
F66
W1
F48
S3
R90
N5
W2
N2
F18
E3
F41
L90
N4
F56
L90
R90
F42
R90
S3
L90
E2
S2
F7
W3
N5
L180
L90
L90
N5
L90
W4
F82
W2
F68
S1
E3
S2
F87
L90
F93
L90
F16
L90
S4
L90
N3
E2
R90
S2
R180
F94
W1
S3
F68
S2
F70
S3
W4
F29
E5
R180
S2
F63
L180
F65
R90
W1
F64
E1
L180
L90
S5
F65
L90
N3
N4
L270
S1
E2
S3
W3
N1
E5
F16
E2
L90
N1
L90
E1
S4
W2
R180
F27
N1
R180
E2
L90
F20
N1
W3
N1
R90
W5
R90
E3
S2
F48
N1
R180
N3
W1
S4
F92
S3
R90
S5
E1
W5
R90
S2
W1
L90
R180
E3
N3
E1
R180
E4
L90
E5
L90
W3
L270
E1
S5
W5
L180
W3
S2
F16
W5
S4
R90
N3
L90
N4
F43
N2
F83
S2
W5
F58
W4
N5
R180
E3
F81
L90
F61
L90
W4
F41
E3
N2
F74
R90
F6
R90
W1
F18
R90
R90
N2
F87
S4
F16
S3
E3
F67
R90
E2
L90
S4
R90
F5
W1
R90
W4
F54
S1
W1
F100
S5
E2
L90
W3
F61
L180
W2
S3
F68
F35
N3
R180
E4
R270
S5
E4
L180
S3
R90
N5
E4
F60
W4
S1
L90
L180
N5
L180
W3
S1
E3
S1
N2
E4
R180
N4
F7
N3
W4
F89
N4
E3
L90
F97

