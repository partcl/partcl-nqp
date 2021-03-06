# Copyright (C) 2004-2006, The Parrot Foundation.

source lib/test_more.tcl
plan 8

eval_is {eval} \
  {wrong # args: should be "eval arg ?arg ...?"} \
  {no args}

eval_is {
 eval "set a 2"
} 2 {single arg}

eval_is {
 eval set a 2
} 2 {multiple args}

eval_is {
 eval set a 2
 set a
} 2 {multiple args, verify side effects}

eval_is {eval "set a \{"}  {missing close-brace}   {close brace} {TODO NQPRX}
eval_is {eval "set a \["}  {missing close-bracket} {close bracket} {TODO NQPRX}
eval_is {eval {set a "}}   {missing "}             {close quote} {TODO NQPRX}

eval_is {eval {set a "
bar"}} {
bar} {keep whitespace inside quotes}

# vim: filetype=tcl:
