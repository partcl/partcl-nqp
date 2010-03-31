# Copyright (C) 2004-2006, The Parrot Foundation.

source lib/test_more.tcl

plan 24

is [list]     {}    {no elements}
is [list a]   {a}   {one element}
is [list a b] {a b} {two elements}

is [list a b {c {d e}}] {a b {c {d e}}} {spaces with braces}
is [list a b "c {d e}"] {a b {c {d e}}} {spaces with quotes}
is [list {1 2} {3 4}]   {{1 2} {3 4}}   {spaces in two elements}

is [list "} {"] {\}\ \{} {braces with spaces} {TODO NQPRX}
is [list \{ \}] {\{ \}}  {braces} {TODO NQPRX}

is [list "\n"]  "{\n}" {newline}
is [list ";"]   {{;}}  {semicolon}
is [list "\t"]  "{\t}" {tab}
is [list "$"]   {{$}}  {dollar}
is [list "\\"]  {\\}   {backslash} {TODO NQPRX}
is [list \[]    {{[}}  {open bracket}
is [list \]]    {\]}   {close bracket}

# hashes are protected only if they're the first char in the first element.
is [list #]     {{#}}    {comment hash}
is [list #foo]  {{#foo}} {comment hash}
is [list #foo #bar]  {{#foo} #bar} {comment hash}

# hairy one that catches us on subst.test
is [list "\x\$x\[foo bar]\\"] {x\$x\[foo\ bar\]\\} {trailing backslash} {TODO NQPRX}

# from list.test
is [list {"}] {{"}} {single quote}
is [list "{ab}xy"] "{{ab}xy}" {braces that don't wrap exactly}
is [list "{ab}\\"] "\\{ab\\}\\\\" {braces that don't wrap exactly, trailing backslash}
is [list \{\r] "\\\{\\r" {use standard \foo escapes when stringifying a list}
is [list \{"] {\{\"} {escape quotes} {TODO NQP}

# vim: filetype=tcl:
