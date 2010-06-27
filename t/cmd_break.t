# Copyright (C) 2004-2006, The Parrot Foundation.

source lib/test_more.tcl

plan 4

eval_is {
 for {set a 0} {$a < 20} {incr a} {
   if {$a > 10} { break }
 }
 set a
} 11 {break from for} {TODO NQPRX}

eval_is {
 set a 20
 while {$a} {
   incr a -1
   if {$a < 10} { break }
 }
 set a
} 9 {break from while} {TODO NQPRX}

eval_is {
  proc test {} {break}
  test
} {invoked "break" outside of a loop} \
  {break outside of a loop} {TODO NQPRX}

eval_is {
  proc test {} {break}
  for {set i 0} {$i < 5} {incr i} {test}
} {invoked "break" outside of a loop} \
  {break in a proc called in a loop} {TODO NQPRX}

# vim: filetype=tcl:
