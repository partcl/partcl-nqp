# Copyright (C) 2007, The Parrot Foundation.

source lib/test_more.tcl
plan 14

eval_is {subst} \
  {wrong # args: should be "subst ?-nobackslashes? ?-nocommands? ?-novariables? string"} \
  {too few args} {TODO NQPRX}

eval_is {subst foo bar} \
  {bad switch "foo": must be -nobackslashes, -nocommands, or -novariables} \
  {too many args} {TODO NQPRX}

set foo ba
is [subst                {{$foo}}]   {{ba}} {subst: variable} \
  {TODO NQPRX}
is [subst -nobackslashes {{$foo}}]   {{ba}} {subst -nobackslashes: variable} \
  {TODO NQPRX}
is [subst -nocommands    {{$foo}}]   {{ba}} {subst -nocommands: variable} \
  {TODO NQPRX}
is [subst -novariables   {{$foo}}] {{$foo}} {subst -novariables: variable} \
  {TODO NQPRX}

is [subst                {{[set foo]}}] {{ba}} {subst: command} \
  {TODO NQPRX}
is [subst -nobackslashes {{[set foo]}}] {{ba}} {subst -nobackslashes: command} \
  {TODO NQPRX}
is [subst -nocommands    {{[set foo]}}] {{[set foo]}} {subst -nocommands: command} \
  {TODO NQPRX}
is [subst -novariables   {{[set foo]}}] {{ba}} {subst -novariables: command} \
  {TODO NQPRX}

is [subst {{\$foo \[set foo]}}]          {{$foo [set foo]}} {subst: backslash} \
  {TODO NQPRX}
is [subst -nobackslashes {{\$foo \[set foo]}}]  {{\ba \ba}} {subst -nobackslashes: backslash} \
  {TODO NQPRX}
is [subst -nocommands    {{\$foo}}]                {{$foo}} {subst -nobackslashes: backslash} \
  {TODO NQPRX}
is [subst -novariables   {{\[set foo]}}]      {{[set foo]}} {subst -nobackslashes: backslash} \
  {TODO NQPRX}

# vim: filetype=tcl:
