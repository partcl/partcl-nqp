# Copyright (C) 2007, The Parrot Foundation.

source lib/test_more.tcl
plan 14

eval_is {binary} {wrong # args: should be "binary option ?arg arg ...?"} \
  {binary: no args}

eval_is {binary foo} {bad option "foo": must be format or scan} \
  {binary: bad subcommand}

# we test the default precision (which is special) elsewhere
# so just set a precision to work around a bug
set tcl_precision 17

binary scan [binary format dccc -1.3 6 7 8] dcc* d c c*
is $d    -1.3  {binary: reversible d} {TODO NQPRX}
is $c       6  {binary: reversible c} {TODO NQPRX}
is ${c*} {7 8} {binary: scan [format cc] c*} {TODO NQPRX}

binary scan [binary format f -1.3] f f
is $f -1.2999999523162842  {binary: reversible f} {TODO NQPRX}

binary scan [binary format n 9] n n
is $n 9 {binary: reversible n} {TODO NQPRX}

binary scan {foo bar} aa* first rest
is [list $first $rest] {f {oo bar}} {binary: scan aa*} {TODO NQPRX}

binary scan [binary format A6A foo bar] A* string
eval_is {set string} {foo   b} {binary: format A6A, scan A*} {TODO NQPRX}

binary scan [binary format A* {foo bar}] A7 string
is $string {foo bar} {binary: format A*, scan A7} {TODO NQPRX}

binary scan [binary format a4a foo bar] a3ca string1 c string2
is $string1 foo {binary: format a4a, scan a3ca} {TODO NQPRX}
is $c       0   {binary: format a4a, scan a3ca} {TODO NQPRX}
is $string2 b   {binary: format a4a, scan a3ca} {TODO NQPRX}

# segfault misc.
is [proc a {} { binary scan \x80 d joe } ; a] {0} {BOOM?} {TODO NQPRX}

# vim: filetype=tcl:
