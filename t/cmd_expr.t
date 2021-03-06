# Copyright (C) 2006-2008, The Parrot Foundation.

source lib/test_more.tcl
plan 350; # XXX  1 deliberate skip and 25 missing

# namespace
namespace eval test { variable x 5 }

if 0 { ## SKIP NQP-RX

is [namespace eval test {expr {$x}}] 5 {correct namespace} {TODO NQPRX}

}

# simple scalars
is [expr 42]     42   {int}
is [expr 4.2]     4.2 {float} {TODO NQPRX}
is [expr 4.0]     4.0 {float stays float} {TODO NQPRX}
is [expr 3e2]   300.0 {scientific} {TODO NQPRX}
is [expr 3e0]     3.0 {scientific with 0 exponent} {TODO NQPRX}
is [expr 2.3e2] 230.0 {scientific with float base} {TODO NQPRX}
is [expr 2.3E2] 230.0 {scientific with float base (upper E)} {TODO NQPRX}
is [expr 2e17]  2e+17 {scientific in, scientific out} {TODO NQPRX}
is [expr 1.1e-05] 1.1e-5 {scientific, negative exponent, removes 0} {TODO NQPRX}

eval_is {expr 3e2.0} \
 {missing operator at _@_
in expression "3e2_@_.0"} \
 {can only e with an integer exponent} {TODO NQPRX}

# booleans
is [expr TrUe]    TrUe  {true}
is [expr !!TrUe]  1  {true}
is [expr !!TrU]   1  {tru}
is [expr !!Tr]    1  {tr}
is [expr !!T]     1  {t}
is [expr !!FaLsE] 0  {false} {TODO NQPRX}
is [expr !!FaLs]  0  {fals} {TODO NQPRX}
is [expr !!FaL]   0  {fal} {TODO NQPRX}
is [expr !!Fa]    0  {fa} {TODO NQPRX}
is [expr !!F]     0  {f} {TODO NQPRX}
is [expr !!On]    1  {on}
is [expr !!OfF]   0  {off} {TODO NQPRX}
is [expr !!Of]    0  {of} {TODO NQPRX}
is [expr !!YeS]   1  {yes}
is [expr !!Ye]    1  {ye}
is [expr !!Y]     1  {y}
is [expr !!No]    0  {no} {TODO NQPRX}
is [expr !!N]     0  {n} {TODO NQPRX}

eval_is {expr trues} \
 {invalid bareword "trues"
in expression "trues";
should be "$trues" or "{trues}" or "trues(...)" or ...} {trues} {TODO NQPRX}
eval_is {expr falses} \
 {invalid bareword "falses"
in expression "falses";
should be "$falses" or "{falses}" or "falses(...)" or ...} {falses} {TODO NQPRX}

is [expr 0b1001]    9 {binary} {TODO NQPRX}
is [expr 0b10]      2 {binary}  {TODO NQPRX}
is [expr 0b101010] 42 {binary} {TODO NQPRX}

eval_is {expr {}} {empty expression
in expression ""} {empty expr}

# simple unary ops.
is [expr -2]   -2   {unary -}
is [expr +2]    2   {unary +}
is [expr +2.0]  2.0 {unary + (float)} {TODO NQPRX}
is [expr ~0]   -1   {unary ~}
is [expr !2]    0   {unary !}
is [expr !true] 0   {unary ! - boolean}
is [expr !!2]   1   {double unary !}

# simple unary ops - stringified args
eval_is {expr {-"2"}}  -2 {unary -} {TODO NQPRX}
eval_is {expr {+"2"}}   2 {unary +} {TODO NQPRX}
is [expr {~"0"}]  -1 {unary ~}
is [expr {!"2"}]   0 {unary !}
is [expr {!!"2"}]  1 {double unary !}

# simple unary ops  - octal

# simple binary ops - integer
is [expr 2 ** 3]   8 {pow}
is [expr 0 ** 1]   0 {pow}
is [expr 0 ** 0]   1 {pow} 
eval_is {expr 0 ** -1} {exponentiation of zero by negative power} \
  {pow of 0 with neg exp} {TODO NQPRX}

is [expr 2 * 3]    6 {mul}
is [expr 6 / 2]    3 {int div}
is [expr 4 / -3]  -2 {int div, negative} {TODO NQPRX}
is [expr 3 % 2]    1 {remainder} {TODO NQPRX}
is [expr 2 + 3]    5 {plus}
is [expr 2 - 3]   -1 {minus}
is [expr 16 << 2] 64 {left shift}
is [expr 16 >> 2]  4 {right shift}
is [expr 5 & 6]    4 {&} {TODO NQPRX}
is [expr 5 | 6]    7 {|} {TODO NQPRX}
is [expr 5 ^ 6]    3 {^} {TODO NQPRX}

set j 7
is [expr {${j}}]      7 {braced variable names}
is [expr {"$j"}]      7 {variables in quotes}
is [expr {"#$j"}]    #7 {variables in quotes after literal}
is [expr {"$"}]       $ {dollar-sign in quotes}
is [expr {"[set j]"}] 7 {commands in quotes}

if 0 { # TODO NQPRX

is [
  set foo a
  set hash(abar) 5
  expr {$hash(${foo}bar)}
] 5 {variables - complex array index}

}

# precedence
eval_is {expr 2*3+4*2} 14 {precedence}
eval_is {expr 2*(3+4)*2} 28 {parens}


is [expr {1 ? 14 : [expr {}]}] 14 \
  {make sure expr errors happen at runtime} {TODO NQPRX}


# non-numeric doesn't numify
is [expr {"foo"}] foo {non-numeric string}

# octal
is [expr {"0001234"}] 668 {string octal} {TODO NQPRX}
is [expr {"0o1234"}]  668 {string 0o octal} {TODO NQPRX}
set j 0001234
is [expr {$j}] 668 {variable octal} {TODO NQPRX}
is [expr 000012345] 5349 {octal}
is [expr -000012345] -5349 {neg octal}
is [expr +000012345] 5349 {pos octal}
eval_is {expr 0000912345} \
{missing operator at _@_
in expression "0000_@_912345";
looks like invalid octal number} \
  {bad octal} {TODO NQPRX}

is [expr 000012345.0] 12345.0 {floats aren't octal} {TODO NQPRX}

# hex
is [expr {0xf}] 15 {hex}
is [expr  {0xf*0xa}] 150 {hex with op}
eval_is {
  expr 0xg
} {invalid bareword "xg"
in expression "0_@_xg";
should be "$xg" or "{xg}" or "xg(...)" or ...} \
{bad hex} {TODO NQRPX}

# simple binary ops - stringified integers
is [expr {2 ** "3"}]   8 {pow "}
is [expr {"2" ** 3}]   8 {pow "}
is [expr {2 * "3"}]    6 {mul "}
is [expr {"2" * 3}]    6 {mul "}
is [expr {6 / "2"}]    3 {times "}
is [expr {"6" / 2}]    3 {times "}
is [expr {3 % "2"}]    1 {remainder "} {TODO NQRPX}
is [expr {"3" % 2}]    1 {remainder "} {TODO NQRPX}
is [expr {2 + "3"}]    5 {plus "}
is [expr {"2" + 3}]    5 {plus "}
is [expr {2 - "3"}]   -1 {minus "}
is [expr {"2" - 3}]   -1 {minus "}
is [expr {16 << "2"}] 64 {left shift "}
is [expr {"16" << 2}] 64 {left shift "}
is [expr {16 >> "2"}]  4 {right shift "}
is [expr {"16" >> 2}]  4 {right shift "}
is [expr {5 & "6"}]    4 {& "} {TODO NQRPX}
is [expr {"5" & 6}]    4 {& "} {TODO NQRPX}
is [expr {5 | "6"}]    7 {| "} {TODO NQRPX}
is [expr {"5" | 6}]    7 {| "} {TODO NQRPX}
is [expr {5 ^ "6"}]    3 {^ "} {TODO NQRPX}
is [expr {"5" ^ 6}]    3 {^ "} {TODO NQRPX}

# comparison ops.
is [expr 10<9] 0 {lt, numeric, not alpha}
is [expr 2<3]  1 {lt, true}
is [expr 3<2]  0 {lt, false}
is [expr 3>2]  1 {gt, true}
is [expr 2>3]  0 {gt, false}
is [expr 2<=3] 1 {lte, lt}
is [expr 3<=2] 0 {lte, gt}
is [expr 3<=3] 1 {lte, eq}
is [expr 3>=2] 1 {gte, gt}
is [expr 2>=3] 0 {gte, lt}
is [expr 3>=3] 1 {gte, eq}
is [expr 2==2] 1 {==, eq}
is [expr 2==1] 0 {==, ne}
is [expr 1!=1] 0 {!=, eq}
is [expr 2!=1] 1 {!=, ne}

eval_is {expr {[list \;] == {{;}}}} 1 {==, string and list} {TODO NQPRX}
eval_is {expr {[list \;] != {{;}}}} 0 {!=, string and list} {TODO NQPRX}

# short circuiting ops with constants
is [expr 2&&2] 1 {&&} {TODO NQPRX}
is [expr {2>=2 && 2>=2}] 1 {&&}
is [expr 2&&0] 0 {&&} {TODO NQPRX}
is [expr 0&&2] 0 {&&}
is [expr 0&&0] 0 {&&}
is [expr 2||2] 1 {||} {TODO NQPRX}
is [expr 2||0] 1 {||} {TODO NQPRX}
is [expr 0||2] 1 {||} {TODO NQPRX}
is [expr 0||0] 0 {||}
is [expr 1?"whee":"cry"] whee {simple ternary} {TODO NQPRX}

# actual short circuiting.
proc yes   {} {global a; incr a 2; return 1}
proc no    {} {global a; incr a 1; return 0}
is [set a 0; list [expr {[yes] && [no]}] $a] {0 3} {&&, both sides} {TODO NQPRX}
is [set a 0; list [expr {[no] || [yes]}] $a] {1 3} {||, both sides} {TODO NQPRX}
is [set a 0; list [expr {[no] && [yes]}] $a] {0 1} {&&, short circuit}
is [set a 0; list [expr {[yes] || [no]}] $a] {1 2} {||, short circuit}
is [set a 0; expr {1?[yes]:[no]}; set a] 2 {ternary, true only} {TODO NQPRX}
is [set a 0; expr {0?[yes]:[no]}; set a] 1 {ternary, false only} {TODO NQPRX}

# invalid (string) operands for some unary ops
set ops_list [list - + ~ !]
foreach operator $ops_list {
  eval_is "expr {${operator}\"a\"}" \
    "can't use non-numeric string as operand of \"$operator\"" \
    "string unary $operator" {TODO NQPRX}
  eval_is "expr {${operator}\"\"}" \
    "can't use empty string as operand of \"$operator\"" \
    "string unary $operator" {TODO NQPRX}
}


# invalid (string) operands for some binary ops
set ops_list [list ** * / % + - << >> & | ^]
foreach operator $ops_list {
  eval_is "expr {\"a\" $operator \"b\"}" \
    "can't use non-numeric string as operand of \"$operator\"" \
    "string $operator" {TODO NQPRX}
  eval_is "expr {\"\" $operator \"\"}" \
    "can't use empty string as operand of \"$operator\"" \
    "string $operator" {TODO NQPRX}
}

# invalid (string) operands for logical ops
set logic_ops_list [list && ||]
foreach operator $logic_ops_list {
  eval_is "expr {\"a\" $operator \"b\"}" \
    {expected boolean value but got "a"} \
    "string $operator" {TODO NQPRX}
  eval_is "expr {\"\" $operator \"\"}" \
    {expected boolean value but got ""} \
    "string $operator" {TODO NQPRX}
}


eval_is {expr bool(4)}       1 {bool - true} {TODO NQPRX}
eval_is {expr bool("yes")}   1 {bool - yes} {TODO NQPRX}
eval_is {expr bool(0)}       0 {bool - false} {TODO NQPRX}
eval_is {expr bool("no")}    0 {bool - no} {TODO NQPRX}
eval_is {expr bool("foo")} {expected boolean value but got "foo"} {bool - bad value} {TODO NQPRX}
eval_is {expr entier("foo")} {expected number but got "foo"} {entier - bad value} {TODO NQPRX}

# math functions, happy path
eval_is {expr abs(-1)}       1 {} {TODO NQPRX}
eval_is {expr abs(1)}        1 {} {TODO NQPRX}
eval_is {expr abs(1.0)}      1.0 {} {TODO NQPRX}
eval_is {expr abs(-1.0)}     1.0 {} {TODO NQPRX}
eval_is {expr acos(0)}       1.5707963267948966 {} {TODO NQPRX}
eval_is {expr asin(1)}       1.5707963267948966 {} {TODO NQPRX}
eval_is {expr atan(1)}       0.7853981633974483 {} {TODO NQPRX}
eval_is {expr atan2(4,5)}    0.6747409422235526 {0.6747409422235527 with cygwin} {TODO NQPRX}
eval_is {expr ceil(4.6)}     5.0 {} {TODO NQPRX}
eval_is {expr ceil(-1.6)}   -1.0 {} {TODO NQPRX}
eval_is {expr cos(0)}        1.0 {} {TODO NQPRX}
eval_is {expr cosh(1)}       1.5430806348152437 {} {TODO NQPRX}
eval_is {expr double(5)}     5.0 {} {TODO NQPRX}
eval_is {expr entier(3)}     3 {} {TODO NQPRX}
eval_is {expr entier(3.5)}   3 {} {TODO NQPRX}
eval_is {expr exp(1)}        2.718281828459045 {} {TODO NQPRX}
eval_is {expr floor(0.1)}    0.0 {} {TODO NQPRX}
eval_is {expr floor(0.0)}    0.0 {} {TODO NQPRX}
eval_is {expr floor(-0.1)}   -1.0 {} {TODO NQPRX}
eval_is {expr fmod(3,2)}     1.0 {} {TODO NQPRX}
eval_is {expr fmod(-4, -1)} -0.0 {} {TODO NQPRX}
eval_is {expr hypot(3,4)}    5.0 {} {TODO NQPRX}
eval_is {expr hypot(-3,4)}   5.0 {} {TODO NQPRX}
eval_is {expr int(4.6)}      4 {} {TODO NQPRX}
eval_is {expr log(32)}       3.4657359027997265 {} {TODO NQPRX}
eval_is {expr log10(32)}     1.505149978319906 {} {TODO NQPRX}
eval_is {expr max(1,4,2)}    4 {} {TODO NQPRX}
eval_is {expr min(1,4,2)}    1 {} {TODO NQPRX}
eval_is {expr pow(2,10)}  1024.0 {} {TODO NQPRX}
eval_is {expr round(4.5)}    5 {} {TODO NQPRX}
eval_is {expr round(5.5)}    6 {} {TODO NQPRX}
eval_is {expr round(4.4)}    4 {} {TODO NQPRX}
eval_is {expr round(2)}      2 {} {TODO NQPRX}
eval_is {expr sin(1)}        0.8414709848078965 {} {TODO NQPRX}
eval_is {expr sinh(1)}       1.1752011936438014 {} {TODO NQPRX}
eval_is {expr sqrt(64)}      8.0 {} {TODO NQPRX}
eval_is {expr tan(1)}        1.5574077246549023 {} {TODO NQPRX}
eval_is {expr tanh(1)}       0.7615941559557649 {} {TODO NQPRX}

# math functions, stringified numeric args
eval_is {expr abs("-1")}       1 {} {TODO NQPRX}
eval_is {expr acos("0")}       1.5707963267948966 {} {TODO NQPRX}
eval_is {expr asin("1")}       1.5707963267948966 {} {TODO NQPRX}
eval_is {expr atan("1")}       0.7853981633974483 {} {TODO NQPRX}
eval_is {expr atan2("4",5)}    0.6747409422235526 {0.6747409422235527 with cygwin} {TODO NQPRX}
eval_is {expr atan2(4,"5")}    0.6747409422235526 {0.6747409422235527 with cygwin} {TODO NQPRX}
eval_is {expr atan2("4","5")}  0.6747409422235526 {0.6747409422235527 with cygwin} {TODO NQPRX}
eval_is {expr ceil("4.6")}     5.0 {} {TODO NQPRX}
eval_is {expr ceil("-1.6")}   -1.0 {} {TODO NQPRX}
eval_is {expr cos("0")}        1.0 {} {TODO NQPRX}
eval_is {expr cosh("1")}       1.5430806348152437 {} {TODO NQPRX}
eval_is {expr double("5")}     5.0 {} {TODO NQPRX}
eval_is {expr entier("3.4")}   3 {} {TODO NQPRX}
eval_is {expr exp("1")}        2.718281828459045 {} {TODO NQPRX}
eval_is {expr fmod("3",2)}     1.0 {} {TODO NQPRX}
eval_is {expr fmod(3,"2")}     1.0 {} {TODO NQPRX}
eval_is {expr fmod("3","2")}   1.0 {} {TODO NQPRX}
eval_is {expr hypot("3",4)}    5.0 {} {TODO NQPRX}
eval_is {expr hypot(3,"4")}    5.0 {} {TODO NQPRX}
eval_is {expr hypot("3","4")}  5.0 {} {TODO NQPRX}
eval_is {expr int("4.6")}      4 {} {TODO NQPRX}
eval_is {expr log("32")}       3.4657359027997265 {} {TODO NQPRX}
eval_is {expr log10("32")}     1.505149978319906 {} {TODO NQPRX}
eval_is {expr pow("2",10)}  1024.0 {} {TODO NQPRX}
eval_is {expr pow(2,"10")}  1024.0 {} {TODO NQPRX}
eval_is {expr pow("2","10")} 1024.0 {} {TODO NQPRX}
eval_is {expr round("4.5")}    5 {} {TODO NQPRX}
eval_is {expr sin("1")}        0.8414709848078965 {} {TODO NQPRX}
eval_is {expr sinh("1")}       1.1752011936438014 {} {TODO NQPRX}
eval_is {expr sqrt("64")}      8.0 {} {TODO NQPRX}
eval_is {expr tan("1")}        1.5574077246549023 {} {TODO NQPRX}
eval_is {expr tanh("1")}       0.7615941559557649 {} {TODO NQPRX}

eval_is {expr exp(exp(50))} Inf Inf {TODO NQPRX}

# unary math functions, invalid string ops.
set function_list \
  [list acos asin atan cos cosh exp floor log log10 sin sinh sqrt tan tanh]
foreach function $function_list {
  eval_is "expr ${function}(\"a\")" \
    {expected floating-point number but got "a"} \
    "string $function" {TODO NQPRX}
}
eval_is {expr {~2.0}} {can't use floating-point value as operand of "~"} \
  {can't use floating-point value as operand of "~"} {TODO NQPRX}

# test namespaces with operators
is [namespace eval lib {if {+2} {}}] {} {[expr] in a namespace}

eval_is {expr inf} Inf {infinity lc} {TODO NQPRX}
eval_is {expr iNf} Inf {infinity mixed case} {TODO NQPRX}
eval_is {expr inf + inf} Inf {infinity add} {TODO NQPRX}
eval_is {expr inf - inf} \
  {domain error: argument not in valid range} {infinity subtract} {TODO NQPRX}
eval_is {expr sin(inf)} \
  {domain error: argument not in valid range} {infinity function} {TODO NQPRX}
eval_is {expr inf/0} Inf {infinity trumps div by 0} {TODO NQPRX}
eval_is {expr 0/inf} 0.0 {div by infinity} {TODO NQPRX}
eval_is {expr 0 < inf} 1 {infinite comparison} {TODO NQPRX}

eval_is {expr 3/0} {divide by zero} {divide by zero} {TODO NQPRX}
eval_is {expr 3%0} {divide by zero} {mod by zero} {TODO NQPRX}

eval_is {expr nan} \
  {domain error: argument not in valid range} {NaN lc} {TODO NQPRX}
eval_is {expr nAn} \
  {domain error: argument not in valid range} {NaN mixed case} {TODO NQPRX}
eval_is {expr nan/0} \
  {can't use non-numeric floating-point value as operand of "/"} \
  {nan trumps div by 0} {TODO NQPRX}

# not a number tests.
foreach function $function_list {
  eval_is "expr ${function}(nan)" \
    {floating point value is Not a Number} \
    "${function}(nan)" {TODO NQPRX}
}

foreach operator $ops_list {
  eval_is "expr nan $operator nan" \
    "can't use non-numeric floating-point value as operand of \"$operator\"" \
    "nan $operator nan" {TODO NQPRX}
}

# variable expansions..
is [
  set q(1) 2
  expr {$q(1)}
] 2 {array variables}
is [
  set under_score0 3
  expr {$under_score0}
] 3 {_, 0 in varnames}

#command expansions
is [expr {[]}] {} {empty command}
is [
  expr {[list a] eq [list a]}
] 1 {command expansion inside, list types.}
is [
  expr {[set a a] eq [set b a]}
] 1 {command expansion inside, string types}


# XXX  add tests for ::tcl::mathfunc

# tcl_precision
is [set tcl_precision 3; expr 1/3.] 0.333 { precision 3} {TODO NQPRX}
is [set tcl_precision 7; expr 1/3.] 0.3333333 { precision 7} {TODO NQPRX}
is [set tcl_precision 12; expr 1/3.] 0.333333333333 { precision 12} {TODO NQPRX}

# blocker bugs for t_tcl/expr.t parsing.
eval_is {expr (1<<63)-1} 9223372036854775807 {expr-32.4} {TODO NQPRX}
eval_is {expr -2147483648} -2147483648 {expr-46.17}
eval_is {expr 9223372036854775808} 9223372036854775808 {expr-46.19} {TODO NQPRX}

eval_is {expr {(!
0)}} 1 {newline in parenthetical expressions ok} {TODO NQPRX}

# misc.
set a 10
is [expr $a < 9] 0 {comparison with var}
is [expr {$a < 9}] 0 {comparison with var in braces}
set a 1; eval_is {expr {$a * 10}} 10 {string mul - don't confuse variables for strings} {TODO NQPRX}

eval_is {
  expr atan2(3,"a")
} {expected floating-point number but got "a"} {bad atan arg 1} {TODO NQPRX}
eval_is {
  expr atan2("a",3)
} {expected floating-point number but got "a"} {bad atan arg 2} {TODO NQPRX}

eval_is {
  expr fink()
} {invalid command name "tcl::mathfunc::fink"} {unknown function} {TODO NQPRX}

eval_is {
  expr atan2("a")
} {too few arguments for math function "atan2"} {arity trumps invalid arg} {TODO NQPRX}

eval_is {
  expr abs(1,2)
} {too many arguments for math function "abs"} {arity, too many} {TODO NQPRX}

eval_is {
  expr hypot(1)
} {too few arguments for math function "hypot"} {arity, too few} {TODO NQPRX}

eval_is {
  expr ceil(a)
} {invalid bareword "a"
in expression "ceil(a)";
should be "$a" or "{a}" or "a(...)" or ...} {barewords bad} {TODO NQPRX}

# string args invalid to math funcs.
foreach mathfunc {ceil double} {
  eval_is "expr $mathfunc\(\"a\"\)" \
    {expected floating-point number but got "a"} \
    "string arg to $mathfunc" {TODO NQPRX}
}
foreach mathfunc {int round} {
  eval_is "expr $mathfunc\(\"a\"\)" \
    {expected number but got "a"} \
    "string arg to $mathfunc" {TODO NQPRX}
}

# domain errors
eval_is {
  expr fmod(3,0)
} {domain error: argument not in valid range} {fmod domain} {TODO NQPRX}

eval_is {
  expr log(-4)
} {domain error: argument not in valid range} {log domain} {TODO NQPRX}

eval_is {
  expr sqrt(-49)
} {domain error: argument not in valid range} {sqrt domain} {TODO NQPRX}


# string args to math funcs
eval_is {
  expr fmod("a",-4)
} {expected floating-point number but got "a"} {fmod string arg 1} {TODO NQPRX}

eval_is {
  expr fmod(-4,"a")
} {expected floating-point number but got "a"} {fmod string arg 2} {TODO NQPRX}

eval_is {
  expr hypot("a",-3)
} {expected floating-point number but got "a"} {hypot string arg 1} {TODO NQPRX}

eval_is {
  expr hypot(-3,"a")
} {expected floating-point number but got "a"} {hypot string arg 2} {TODO NQPRX}

eval_is {
  expr pow("a",2)
} {expected floating-point number but got "a"} {pow string arg 1} {TODO NQPRX}

eval_is {
  expr pow(2,"a")
} {expected floating-point number but got "a"} {pow string arg 2} {TODO NQPRX}

# misc.
eval_is {
  expr "("
} {unbalanced open paren
in expression "("} {missing )} {TODO NQPRX}

eval_is {expr {2 * [expr {2 - 1}]}} 2 {nested expr (braces)}
set n 1; eval_is {expr {$n * 1}} 1 {braced operands} {TODO NQPRX}

# string comparators
eval_is  {expr {"foo"eq{foo}}} 1 {eq, extra characters after quotes} {TODO NQPRX}
eval_is {expr {{foo}eq"foo"}} 1 {eq, extra characters after brace} {TODO NQPRX}
eval_is {expr {"foo"eq{baz}}} 0 {eq, false} {TODO NQPRX}
eval_is {expr {{foo}ne{baz}}} 1 {ne, true} {TODO NQPRX}
eval_is {expr {{foo}ne{foo}}} 0 {ne, false} {TODO NQPRX}
eval_is {expr {"foo"=="foo"}} 1 {string ==, true}
eval_is {expr {"foo"=="baz"}} 0 {string ==, false}
eval_is {expr {"foo" != "baz"}} 1 {string !=, true} {TODO NQPRX}
eval_is {expr {"foo" != "foo"}} 0 {string !=, false}
eval_is {expr {"abb"<="abc"}} 1 {string <=, <}
eval_is {expr {"abc"<="abb"}} 0 {string <=, >} {TODO NQPRX}
eval_is {expr {"abc"<="abc"}} 1 {string <=, =}
eval_is {expr {"abb" >= "abc"}} 0 {string >=, <} {TODO NQPRX}
eval_is {expr {"abc" >= "abb"}} 1 {string >=, >}
eval_is {expr {"abc" >= "abc"}} 1 {string >=, =}
eval_is {expr {"abb"<="abc"}} 1 {string <, <}
eval_is {expr {"abc"<="abb"}} 0 {string <, >} {TODO NQPRX}
eval_is {expr {"abc"<="abc"}} 1 {string <, =}
eval_is {expr {"abb" >= "abc"}} 0 {string >, <} {TODO NQPRX}
eval_is {expr {"abc" >= "abb"}} 1 {string >, >}
eval_is {expr {"abc" >= "abc"}} 1 {string >, =}

# invalid usage of float.
foreach op {% << >> & | ^} {
  eval_is "expr 3.2 $op 2" \
    "can't use floating-point value as operand of \"$op\"" \
    "invalid float arg for $op" {TODO NQPRX}
}

is [expr {"a" > 10}] 1 {string > int} {TODO NQPRX}
is [expr {"2" < 10}] 1 {string int < int}
is [expr {"2" < "10"}] 1 {string int < string int}

# list operators
set my_list {b c d f}
is [expr {"b" in $my_list}] 1 {in true}
is [expr {"e" in $my_list}] 0 {in false}
is [expr {"e" ni $my_list}] 1 {ni true}
is [expr {"b" ni $my_list}] 0 {ni false}

# regressions
is [expr {"[eval {set a "aok"}]" ne "bork"}] 1 {test_more.tcl regression}
is [expr 1eq4>3] 1 {no whitespace needed after eq op}

# vim: filetype=tcl:
