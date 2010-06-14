# Copyright (C) 2004-2007, The Parrot Foundation.

source lib/test_more.tcl
plan 13

eval_is {
  catch {
    error dead
  }
  set a ""
} {} {discard error}

eval_is {
  catch {
    error dead
  } var
  set var
} {dead} {error messsage}

eval_is {
  catch {
    set b 0
  }
} 0 {error type: none}

eval_is {
  catch {
    error dead
  }
} 1 {error type: error}

eval_is {
  catch {
    return
  }
} 2 {error type: return} {
  TODO { nqp-rx is eating the return exception. }
}

eval_is {
  catch {
    break
  }
} 3 {error type: break}

eval_is {
  catch {
    continue
  }
} 4 {error type: continue}

eval_is {
  set a [catch blorg var]
  list $a $var
} {1 {invalid command name "blorg"}} {error, invalid command} {TODO NQPRX}

eval_is {catch} \
  {wrong # args: should be "catch script ?resultVarName? ?optionVarName?"} \
  {too few args}

eval_is {
  list [catch {incr} msg] $msg
} {1 {wrong # args: should be "incr varName ?increment?"}} \
  {catch {incr} msg}

eval_is {
  namespace eval abc {
    proc a {} {return "ok"}
    proc b {} {catch {a} msg; return $msg }
    b
  }
} ok {catch should respect the namespace it is invoked in} {TODO NQPRX}

eval_is {
  set a 3
  catch {
    set a 2
    set a [
  }
  set a
} 2 {execute code as soon as possible, don't wait until the end of the block} {TODO NQPRX}

eval_is {
  catch { return -errorcode 1 -errorinfo boo -code error -level 1 "eek" } msg opts
  list $msg \
    [dict get $opts -errorcode] \
    [dict get $opts -errorinfo] \
    [dict get $opts -code] \
    [dict get $opts -level]
} {eek 1 boo 1 1} {basic opts handling} {TODO NQPRX}

# vim: filetype=tcl:
