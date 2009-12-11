#!perl

# Copyright (C) 2005-2006, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); #\
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 5

eval_is {flush} \
  {wrong # args: should be "flush channelId"} \
  {no args}

eval_is {flush the monkeys} \
  {wrong # args: should be "flush channelId"} \
  {too many args}

eval_is {flush toilet} \
  {can not find channel named "toilet"} \
  {invalid channel name}

is [flush stdout] {} out
is [flush stderr] {} err

