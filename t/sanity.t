#! ./pmtcl
# Run enough to get partcl's lib/test_more.tcl running.

puts 1..1

set a 2
if {$a == 2} {
  puts "ok 1 # assignment, simple if, expressions, var substitution..."
} else {
  puts "not ok 1 # assignment, simple if, expressions, var substitution..."
}
