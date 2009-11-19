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

token word { 
   [
   | <WORD=braced_word>
   | <WORD=quoted_word>
   | <WORD=bare_word>
   ]
}

token braced_word { 
    '{' 
    $<val>=[ [ <.braced_word> | <-[{}]>+ ]* ]
    '}' 
}

token quoted_word { '"' <quoted_atom>* '"' }

proto token quoted_atom { <...> }
token quoted_atom:sym<[ ]> { '[' ~ ']' <command> }
token quoted_atom:sym<var> { <variable> }
token quoted_atom:sym<$>   { '$' }
token quoted_atom:sym<\\>  { <backslash> }
token quoted_atom:sym<chr> { <-[ \[ " \\ $]>+ }

token bare_word { <bare_atom>+ }

proto token bare_atom { <...> }
token bare_atom:sym<[ ]> { '[' ~ ']' <command> }
token bare_atom:sym<var> { <variable> }
token bare_atom:sym<$>   { '$' }
token bare_atom:sym<\\>  { <backslash> }
token bare_atom:sym<chr> { <-[ \[ \\ $ \] ; ]-space>+ }

proto token backslash { <...> }
token backslash:sym<nl> { '\n' }
token backslash:sym<chr> { \\ $<chr>=[.] }

token identifier { <ident> ** '::' }
token variable { '$' <identifier> }

# expression parsing

INIT {
    PmTcl::Grammar.O(':prec<13>', '%multiplicative');
    PmTcl::Grammar.O(':prec<12>', '%additive');
}

token term:sym<integer> { <integer> }
token term:sym<variable> { <variable> }

token infix:sym<*> { <sym> <O('%multiplicative, :pirop<mul>')> }
token infix:sym</> { <sym> <O('%multiplicative, :pirop<div>')> }

token infix:sym<+> { <sym> <O('%additive, :pirop<add>')> }
token infix:sym<-> { <sym> <O('%additive, :pirop<sub>')> }


