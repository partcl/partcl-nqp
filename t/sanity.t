# Run enough to get partcl's lib/test_more.tcl running.

puts 1..10

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

proc d {{msg {hello world}}} {
  return $msg
}
if {[d] eq "hello world"} {
  puts "ok 6 # default values for parameters"
} else {
  puts "not ok 6 # default values for parameters"
}

if {[llength "a b c" ] == 3} {
  puts "ok 7 # llength"
} else {
  puts "not ok 7 # llength"
}

if {[lindex "a b c" 1] eq "b"} {
  puts "ok 8 # lindex"
} else {
  puts "not ok 8 # lindex"
}

if {[string toupper foo] eq "FOO"} {
  puts "ok 9 # string upper"
} else {
  puts "not ok 9 # string upper"
}

if {[string compare -nocase foo FOO] eq 0} {
  puts "ok 10 # string compare -nocase"
} else {
  puts "not ok 10 # string compare -nocase"
}

# vim: filetype=tcl:
