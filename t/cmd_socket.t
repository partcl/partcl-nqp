# Copyright (C) 2006-2007, The Parrot Foundation.

source lib/test_more.tcl
plan 3

eval_is {socket host} \
  {wrong # args: should be "socket ?-myaddr addr? ?-myport myport? ?-async? host port" or "socket -server command ?-myaddr addr? port"} \
  {too few args}

eval_is {socket host port foo} \
  {wrong # args: should be "socket ?-myaddr addr? ?-myport myport? ?-async? host port" or "socket -server command ?-myaddr addr? port"} \
  {too many args}

set SKIP {SKIP "awaiting socket implementation"}

eval_is {socket a 80} \
  {couldn't open socket: host is unreachable} \
  {unreachable host} \
  $SKIP

# vim: filetype=tcl:
