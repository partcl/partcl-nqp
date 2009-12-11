# Copyright (C) 2004-2007, The Parrot Foundation.

source lib/test_more.tcl
plan 5

eval_is {
 proc joe {} {
   set a 10
   return $a
   set a 20
 }
 joe
} 10 {simple return with value}

eval_is {
 proc joe {} {
   return
 }
 joe
} {} {simple return with no value}

eval_is {
  proc joe {} { return -code error "bad args" }
  joe
} {bad args} {-code error}

eval_is {
  proc joe {} { return -level 1 "same as nothing" }
  joe
} {same as nothing} {-level 1 support}

eval_is {
  proc foo {} {
    return -options {-code error} "bad args"
  }
  set a [catch {foo} bar]
  list $a $bar
} {1 {bad args}} {-options handling}

# vim: filetype=tcl:
