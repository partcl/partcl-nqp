# Copyright (C) 2010, The Parrot Foundation.

source lib/test_more.tcl
plan 36

eval_is {dict} \
    {wrong # args: should be "dict subcommand ?argument ...?"}\
    {dict, no args}

eval_is {dict amaphone} \
    {unknown or ambiguous subcommand "amaphone": must be append, create, exists, filter, for, get, incr, info, keys, lappend, merge, remove, replace, set, size, unset, update, values, or with}\
    {dict, bad subcommand}

set msg {wrong # args: should be "dict append varName key ?value ...?"}
eval_is {dict append} $msg {append 0 args}
eval_is {dict append a} $msg {append 1 arg}

set msg {wrong # args: should be "dict create ?key value ...?"}
eval_is {dict create a} $msg {create 1 arg}

set msg {wrong # args: should be "dict exists dictionary key ?key ...?"}
eval_is {dict exists} $msg {exists 0 args}
eval_is {dict exists a} $msg {exists 1 arg}

set msg {wrong # args: should be "dict filter dictionary filterType ..."}
eval_is {dict filter} $msg {filter 0 args}
eval_is {dict filter a} $msg {filter 1 arg}

set msg {wrong # args: should be "dict for {keyVar valueVar} dictionary script"}
eval_is {dict for} $msg {for 0 args}
eval_is {dict for a} $msg {for 1 arg}
eval_is {dict for a b} $msg {for 2 args}
eval_is {dict for a b c d} $msg {for 4 args}

set msg {wrong # args: should be "dict get dictionary ?key key ...?"}
eval_is {dict get} $msg {get 0 args}

set msg {wrong # args: should be "dict incr varName key ?increment?"}
eval_is {dict incr} $msg {incr 0 args}
eval_is {dict incr a} $msg {incr 1 args}
eval_is {dict incr a b c d} $msg {incr 4 args}

set msg {wrong # args: should be "dict info dictionary"}
eval_is {dict info} $msg {info 0 args}
eval_is {dict info a b} $msg {info 2 args}

set msg {wrong # args: should be "dict keys dictionary ?pattern?"}
eval_is {dict keys} $msg {keys 0 args}
eval_is {dict keys a b c} $msg {keys 3 args}

set msg {wrong # args: should be "dict lappend varName key ?value ...?"}
eval_is {dict lappend} $msg {lappend 0 args}
eval_is {dict lappend a} $msg {lappend 1 arg}

# merge

set msg {wrong # args: should be "dict remove dictionary ?key ...?"}
eval_is {dict remove} $msg {remove 0 args}

set msg {wrong # args: should be "dict replace dictionary ?key value ...?"}
eval_is {dict replace} $msg {replace 0 args}

set msg {wrong # args: should be "dict set varName key ?key ...? value"}
eval_is {dict set} $msg {set 0 args}
eval_is {dict set a} $msg {set 1 arg}

set msg {wrong # args: should be "dict size dictionary"}
eval_is {dict size} $msg {size 0 args}
eval_is {dict size a b} $msg {size 2 args}

set msg {wrong # args: should be "dict unset varName key ?key ...?"}
eval_is {dict unset} $msg {unset 0 args}

set msg {wrong # args: should be "dict update varName key varName ?key varName ...? script"}
eval_is {dict update} $msg {update 0 args}
eval_is {dict update a} $msg {update 1 arg}
eval_is {dict update a b} $msg {update 2 args}

set msg {wrong # args: should be "dict values dictionary ?pattern?"}
eval_is {dict values} $msg {values 0 args}
eval_is {dict values a b c} $msg {values 3 args}

set msg {wrong # args: should be "dict with dictVar ?key ...? script"}
eval_is {dict with} $msg {with 0 args}

# vim: filetype=tcl:
