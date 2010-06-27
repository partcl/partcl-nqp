# Copyright (C) 2006, The Parrot Foundation.

source lib/test_more.tcl
plan 2

set some_var 3

proc tracer {args} {
  global some_var
  set some_var x
}

set a(1) 2
trace variable a r tracer
set a(1) 3
is $a(1) 3 {set should still work} ;## TODO NQPRX - this is working because there IS no trace
is $some_var x {trigger should have hit} \
   {TODO NQRPX}

# vim: filetype=tcl:
