# Copyright (C) 2004-2008, The Parrot Foundation.

source lib/test_more.tcl
# 16, but 2 are skipped.
plan 14

eval_is {foreach} \
  {wrong # args: should be "foreach varList list ?varList list ...? command"} \
  {no args}

eval_is {foreach a b q {puts $a}} \
  {wrong # args: should be "foreach varList list ?varList list ...? command"} \
  {even # of args}

eval_is {foreach {} {a b c} {puts foo}} \
  {foreach varlist is empty} \
  {empty varList}

if 0 { # XXX drastic TODO
eval_is {
    array set a {}
    foreach a {1 2 3 4} {puts $a}
} {can't set "a": variable is array} \
  {couldn't set loop variable}
}

unset -nocomplain a
is [foreach a {1 2 3 4} {set a}] {} {return value}

eval_is {
  set r ""
  foreach a {a b c} {append r $a}
  set r
} {abc} {single var/list}

eval_is {
  set r ""
  foreach a {a b c} b {d e f} {append r "$a $b:"}
  set r
} {a d:b e:c f:} {double var/list}

eval_is { 
  set r ""
  foreach a {a b c} b {d e f g h} {append r "$a $b:"}
  set r
} {a d:b e:c f: g: h:} {double var/list, uneven}

eval_is {
  set r ""
  foreach a [list a b c] {append r $a}
  set r
} {abc} {single var/list, list object}

eval_is {
  set r ""
  foreach a [list a b c] b [list d e f] {append r "$a $b:"}
  set r
} {a d:b e:c f:} {double var/list, list objects}

eval_is {
  set r ""
  foreach a [list a b c] {append r $a; break}
  set r
} a {break}


eval_is {
  set r ""
  foreach a [list 1 2 3] {if {$a <2} {continue} ; append r $a}
  set r
} 23 {continue}

eval_is {
  proc test {} {
      set r ""
      foreach name {a b c d} {
          append r $name
      }
      return $r
  }
  test
} abcd {lexicals}

eval_is {
  foreach name {a b c d} { aputs }
} {invalid command name "aputs"} {inner exception} {TODO NQPRX}

is [
    set x {}
    foreach {c n} {a 1 b 2 c} {append x "$c = $n;"}
    set x
] {a = 1;b = 2;c = ;} \
  {multiple index variables}

if 0 { # XXX drastic TODO
eval_is {
  namespace eval lib {
    set val {}
    proc a {} {error ok}
    foreach n 1 a
  }
} ok {namespace resolution in body}
}
# vim: filetype=tcl:
