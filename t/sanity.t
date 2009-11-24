#! ./pmtcl
# Run enough to get partcl's lib/test_more.tcl running.

puts 1..5

set a 2
if $a==2 {
  puts "ok 1 # assignment, simple if, expressions, var substitution..."
} else {
  puts "not ok 1 # assignment, simple if, expressions, var substitution..."
}

if {$a==2} {
  puts "ok 2 # as above plus var scoping."
} else {
  puts "not ok 2 # as above plus var scoping."
}


proc b {} {
  return 2
}
if [b]==2 {
  puts "ok 3 # proc/return/command substitution"
} else {
  puts "not ok 3 # proc/return/command substitution"
}

set a 4
proc c {} {
  global a
  if {$a==4} {
    puts "ok 4 # global"
  } else {
    puts "not ok 4 # global"
  }
}
c

if {[set a]==4} {
  puts "ok 5 # set as get"
} else {
  puts "not ok 5 # set as get"
}
