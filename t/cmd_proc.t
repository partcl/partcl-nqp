# Copyright (C) 2004-2007, The Parrot Foundation.

source lib/test_more.tcl
plan 18; # +1 skip

eval_is {
 set a [proc me {} {
  return 2
 }]
 list [me] [set a]
} {2 {}} {return value}

eval_is {
 proc foo {} {
   append x {foo bar}
 }
 foo
} {foo bar} {return value from user-defined command}

eval_is {
 proc me {} {
  return 2
 }
 me
} 2 {no args}

eval_is {
 proc me {a} {
  return $a
 }
 me 2
} 2 {one arg}

eval_is {
 proc me {a b} {
  list $a $b
 }
 me 2 3
} {2 3} {two args}

eval_is {
 proc me {a b} {
  list $a $b
 }
 me 2 3 4
} {wrong # args: should be "me a b"} {too many args} {TODO NQPRX}

eval_is {
 proc me {a b} {
  list $a $b
 }
 me 2
} {wrong # args: should be "me a b"} {too few args} {TODO NQPRX}

eval_is {
  proc test {} {}
  test foo bar
} {wrong # args: should be "test"} {bad args - expected none} {TODO NQPRX}

eval_is {
 proc me {a b args} {
  list $a $b
 }
 me 2
} {wrong # args: should be "me a b ..."} {bad varargs} {TODO NQPRX}

eval_is {
 proc me {a args} {
  list $a $args
 }
 me 2 3 4 5 6
} {2 {3 4 5 6}} {vararg} {TODO NQPRX}

eval_is {
 proc me {a args} {
  list $a $args
 }
 me 2
} {2 {}} {vararg empty} {TODO NQPRX}

if 0 { # SKIP NQPRX - breaks test_more.tcl

eval_is {
  rename incr incr_old
  proc incr {varName} {return $varName}
  proc test {} { incr a }
  set a [test]
  rename incr {}
  rename incr_old incr
  set a
} {a} {using a renamed builtin} {TODO NQPRX}

}

eval_is {
  proc a::b {} {puts a::b}
  a::b
} {can't create procedure "a::b": unknown namespace} {unknown namespace} {TODO NQPRX}

eval_is {
 proc me {{a 2}} {
  return $a
 }
 list [me] [me 7]
} {2 7} {default args}

eval_is {
 proc me {{a 2 3}} {
  return $a
 }
} {too many fields in argument specifier "a 2 3"} {bad default arg spec} {TODO NQPRX}

eval_is {
  proc test {{a 2} b} {list $a $b}
  test 3
} {wrong # args: should be "test ?a? b"} {default arg with too few args} {TODO NQPRX}

eval_is {
  proc test {{a 2}} {return $a}
  test 3 4
} {wrong # args: should be "test ?a?"} {default too many args} {TODO NQPRX}

eval_is {
  proc test {} {}
  set a 4
  catch {test foo}
  set a
} 4 {reset call_level on bad args}

eval_is {
 proc nothing {} {
    # empty proc
 }
} {} {empty procs are ok}

# vim: filetype=tcl:
