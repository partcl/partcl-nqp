INIT { pir::load_bytecode('HLL.pbc'); }

grammar PmTcl::Grammar is HLL::Grammar;

token TOP { <body> }

token PROC { <body(1)> }

token body($*NEWPAD = 0) { <script> [ $ || <.panic: 'Confused' > ] }

token script {
    [ \h* [ <.comment> | <command> | <?> ] ] ** <.command_sep>
    \s*
}

token comment { '#' [ \\ \n \h* | \N ]* }
token command { <word> ** [\h+] }
token command_sep { ';' | \n }

proto token word { <...> }

token word:sym<{*}> { '{*}' <word> }

token word:sym<{ }> {
    <braced_word>
    [ <?before \S> <.panic: 'extra characters after close-brace'> ]?
}

token word:sym<" "> {
    '"' <quoted_atom>* '"'
    [ <?before \S> <.panic: 'extra characters after close-quote'> ]?
}

token word:sym<bare> { <bare_atom>+ }

token braced_word { 
    '{' 
    $<val>=[ [ <.braced_word> | <-[{}]>+ ]* ]
    '}' 
}

proto token quoted_atom { <...> }
token quoted_atom:sym<[ ]> { '[' ~ ']' <script> }
token quoted_atom:sym<var> { <variable> }
token quoted_atom:sym<$>   { '$' }
token quoted_atom:sym<\\>  { <backslash> }
token quoted_atom:sym<chr> { <-[ \[ " \\ $]>+ }

proto token bare_atom { <...> }
token bare_atom:sym<[ ]> { '[' ~ ']' <script> }
token bare_atom:sym<var> { <variable> }
token bare_atom:sym<$>   { '$' }
token bare_atom:sym<\\>  { <backslash> }
token bare_atom:sym<chr> { <-[ \[ \\ $ \] ; ]-space>+ }

proto token backslash { <...> }
token backslash:sym<nl> { '\n' }
token backslash:sym<chr> { \\ $<chr>=[.] }

token list { 
    \s* 
    [
    | <EXPR=.braced_word>
        [ \S+ <.panic: 'list element in braces followed by extra charcters'> ]?
    | <EXPR=.list_word>
    ] ** [\s+]
}
token list_word { <list_atom>+ }
proto token list_atom { <...> }
token list_atom:sym<\\>  { <backslash> }
token list_atom:sym<chr> { <-[ \\ ]-space>+ }

token identifier { <ident> ** '::' }
token variable { '$' <identifier> }

# expression parsing

INIT {
    PmTcl::Grammar.O(':prec<13>', '%multiplicative');
    PmTcl::Grammar.O(':prec<12>', '%additive');
    PmTcl::Grammar.O(':prec<9>',  '%compare_numeric');
    PmTcl::Grammar.O(':prec<8>',  '%compare_string');
}

token term:sym<integer> { <integer> }
token term:sym<variable> { <variable> }

token infix:sym<*> { <sym> <O('%multiplicative, :pirop<mul>')> }
token infix:sym</> { <sym> <O('%multiplicative, :pirop<div>')> }

token infix:sym<+> { <sym> <O('%additive, :pirop<add>')> }
token infix:sym<-> { <sym> <O('%additive, :pirop<sub>')> }

token infix:sym<==> { <sym> <O('%compare_numeric, :pirop<iseq I++>')> }
token infix:sym<!=> { <sym> <O('%compare_numeric, :pirop<isne I++>')> }

token infix:sym<eq> { <sym> <O('%compare_string, :pirop<iseq I~~>')> }
token infix:sym<ne> { <sym> <O('%compare_string, :pirop<isne I~~>')> }
