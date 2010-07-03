# Copyright (C) 2006-2007, The Parrot Foundation.

source lib/test_more.tcl
plan 5; # +1 skip

eval_is {::set a ok}      {ok} {explicit global command} {TODO NQPRX}
eval_is {:::::::set b ok} {ok} {explicit global command, extra colons} {TODO NQPRX}

if 0 { ## PARSEFAIL NQPRX
proc ::: {} {return ok}
is [{}] ok {command name, all colons}
}

eval_is {
  :set c ok
} {invalid command name ":set"}\
{not enough colons, explicit global command} {TODO NQPRX}

eval_is {
  foo::bar
} {invalid command name "foo::bar"} \
{invalid ns command} {TODO NQPRX}

eval_is {
  proc test {} {return ok1}
  set a [namespace eval lib {test}]
  proc ::lib::test {} {return ok2}
  list $a [namespace eval lib {test}]
} {ok1 ok2} {relative namespace} {TODO NQPRX}

# vim: filetype=tcl:
