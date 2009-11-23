#! ./pmtcl
# Run enough to get partcl's lib/test_more.tcl running.

puts 1..2

set a 2
if $a==2 {
  puts "ok 1 # assignment, simple if, expressions, var substitution..."
} else {
  puts "not ok 1 # assignment, simple if, expressions, var substitution..."
}

proc b {} {
  return 2
}
if [b]==2 {
  puts "ok 2 # proc/return/command substitution"
} else {
  puts "not ok 2 # proc/return/command substitution"
}
