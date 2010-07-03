# Copyright (C) 2005-2008, The Parrot Foundation.

source lib/test_more.tcl
plan 23

eval_is {switch} \
  {wrong # args: should be "switch ?switches? string pattern body ... ?default body?"} \
  {too few args, 0}

eval_is {switch a} \
  {wrong # args: should be "switch ?switches? string pattern body ... ?default body?"} \
  {too few args, 1}

eval_is {switch -monkey a} \
  {extra switch pattern with no body} \
  {bad flag, -monkey} {TODO NQPRX}

eval_is {switch a {    }} \
  {wrong # args: should be "switch ?switches? string {pattern body ... ?default body?}"} \
  {empty body} {TODO NQPRX}

eval_is {
 set q 1
 switch a a {set q 2}
 set q
} 2 {implied exact, singleton}

eval_is {
 set q 1
 switch b a {
   set q 2
 } b {
   set q 3
 }
 set q
} 3 {implied exact, two choices}

eval_is {
 set q 1
 switch -- -a -a {set q 2}
 set q
} 2 {implied exact, --}

eval_is {
 set q 1
 switch -- -b -a {
   set q 2
 } -b {
   set q 3
 }
 set q
} 3 {implied exact, --, two choices}

eval_is {
  set q 1
  switch ab {
    ab { set q 2 }
  }
  set q
} 2 {implied exact, single choice in list} {TODO NQPRX}

eval_is {
  set q 1
  switch ab {
    *b { set q 2 }
    a* { set q 3 }
    ab { set q 4 }
    ba { set q 5 }
  }
  set q
} 4 {implied exact, no globbing} {TODO NQPRX}

eval_is {
  set q 1
  switch abc {
    *b { set q 2 }
    a* { set q 3 }
    ab { set q 4 }
    ba { set q 5 }
    default { set q 6 }
  }
  set q
} 6 {implied exact, default} {TODO NQPRX}

eval_is {
  set q 1
  switch ab {
    *b { set q 2 }
    a* { set q 3 }
    ab { set q 4 }
    ba { set q 5 }
    default { set q 6 }
  }
  set q
} 4 {implied exact, match before default} {TODO NQPRX}

eval_is {
  set q 1
  switch abc {
    *b { set q 2 }
    a* { set q 3 }
    ab { set q 4 }
    ba { set q 5 }
  }
  set q
} 1 {implied exact, no match, no default} {TODO NQPRX}

eval_is {
  set q 1
  switch ab {
    b  { set q 2 }
    ab { set q 3 }
    ba { set q 4 }
  }
  set q
} 3 {implied exact, choices in list} {TODO NQPRX}

eval_is {
   switch -nocase C {
     c       {set ok 1}
     default {set ok 0}
   }
   set ok
} 1 {implied exact, nocase subject} {TODO NQPRX}

eval_is {
  switch a {
    a       -
    b       {set ok 1}
    default {set ok 0}
  }
  set ok
} 1 {implied exact, fall-through} {TODO NQPRX}

eval_is {
  switch a {
    a {set ok 1}
    b -
    c -
  }
} {no body specified for pattern "c"} \
  {implied exact, fall through the end} {TODO NQPRX}

eval_is {switch a {a 1 b}} \
  {extra switch pattern with no body} \
  {implied exact, pattern with no body} {TODO NQPRX}

eval_is {
  set q 1
  switch -glob ab {
    b  { set q 2 }
    a* { set q 3 }
    ab { set q 4 }
  }
  set q
} 3 {-glob, three choices} {TODO NQPRX}

eval_is {
  set q 1
  switch -glob abc {
    b  { set q 2 }
    a? { set q 3 }
    *a { set q 3 }
  }
  set q
} 1 {-glob, no match, no default} {TODO NQPRX}

eval_is {
  set q 1
  switch abc {
    b  { set q 2 }
    a? { set q 3 }
    *a { set q 4 }
    default { set q 5 }
  }
  set q
} 5 {-glob, no match, default} {TODO NQPRX}

eval_is {switch -glob a {a 1 b}} \
  {extra switch pattern with no body} \
  {-glob, pattern with no body}

eval_is {switch -regexp a {a 1 b}} \
  {extra switch pattern with no body} \
  {-regexp, pattern with no body}

# vim: filetype=tcl:
